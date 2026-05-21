import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    // ── Palette ───────────────────────────────────────────────────────────────
    readonly property color bgPrimary:     "#171717"
    readonly property color bgSecondary:   "#262626"
    readonly property color textPrimary:   "#FFFFFF"
    readonly property color textSecondary: "#A4A4A4"
    readonly property color textMuted:     "#666666"
    readonly property color accent:        "#FF5000"
    readonly property color accentHover:   "#FF6B1A"
    readonly property color accentPressed: "#CC4000"
    readonly property color successGreen:  "#4CAF50"
    readonly property color errorRed:      "#F44336"
    readonly property color warningAmber:  "#FFC107"
    readonly property color borderColor:   "#333333"

    // ── State ─────────────────────────────────────────────────────────────────
    property int    currentTab:      0   // 0 = Watchlist, 1 = Log
    property string nodeUrl:         "http://127.0.0.1:8080"
    property int    pollIntervalMs:  30000
    property bool   pollBusy:        false
    property int    pollIndex:       0
    property bool   zoneSeqReady:    false
    property string statusMsg:       ""

    // watchlist: JS array mirror of C++ watchlist for UI rendering
    property var watchlist: []
    // dispatchLog: JS array mirror for UI rendering
    property var dispatchLog: []
    // pendingAnnouncements: channel_announce payloads awaiting user decision
    property var pendingAnnouncements: []

    // ── Hidden clipboard helper ───────────────────────────────────────────────
    TextEdit {
        id: clipboardHelper
        visible: false
    }

    function copyToClipboard(text) {
        clipboardHelper.text = text
        clipboardHelper.selectAll()
        clipboardHelper.copy()
    }

    // ── callModuleParse — three-layer canonical form ──────────────────────────
    function callModuleParse(raw) {
        try {
            var tmp = JSON.parse(raw)
            if (typeof tmp === 'string') {
                try { return JSON.parse(tmp) } catch(e) { return tmp }
            }
            return tmp
        } catch(e) { return null }
    }

    // ── Init ──────────────────────────────────────────────────────────────────
    Component.onCompleted: {
        loadConfig()
        loadWatchlist()
        loadDispatchLog()
        initZoneSeq()
    }

    function loadConfig() {
        if (typeof logos === "undefined" || !logos.callModule) return
        var raw = logos.callModule("logos_cord", "getCordConfig", [])
        var cfg = callModuleParse(raw)
        if (!cfg) return
        root.nodeUrl        = cfg.nodeUrl        || "http://127.0.0.1:8080"
        root.pollIntervalMs = (cfg.pollInterval  || 30) * 1000
    }

    function loadWatchlist() {
        if (typeof logos === "undefined" || !logos.callModule) return
        var raw = logos.callModule("logos_cord", "getWatchlist", [])
        var arr = callModuleParse(raw)
        if (!Array.isArray(arr)) arr = []
        root.watchlist = arr
        watchlistModel.clear()
        for (var i = 0; i < arr.length; i++) {
            watchlistModel.append(arr[i])
        }
    }

    function loadDispatchLog() {
        if (typeof logos === "undefined" || !logos.callModule) return
        var raw = logos.callModule("logos_cord", "getDispatchLog", [])
        var arr = callModuleParse(raw)
        if (!Array.isArray(arr)) arr = []
        root.dispatchLog = arr
        dispatchLogModel.clear()
        // Display newest first
        for (var i = arr.length - 1; i >= 0; i--) {
            dispatchLogModel.append(arr[i])
        }
    }

    // ── Zone sequencer init (read-only — node URL only, no signing key) ────────
    function initZoneSeq() {
        if (typeof logos === "undefined" || !logos.callModule) return
        logos.callModule("liblogos_zone_sequencer_module", "set_node_url",
                         [root.nodeUrl])
        root.zoneSeqReady = true
    }

    // ── Poll timer ────────────────────────────────────────────────────────────
    Timer {
        id: pollTimer
        interval: root.pollIntervalMs
        running:  root.watchlist.length > 0 && root.zoneSeqReady
        repeat:   true
        onTriggered: pollNext()
    }

    // Also poll immediately when the watchlist gains its first entry
    onWatchlistChanged: {
        if (root.watchlist.length > 0 && root.zoneSeqReady && !root.pollBusy) {
            pollNext()
        }
    }

    // ── pollNext — round-robin over watchlist ─────────────────────────────────
    function pollNext() {
        if (root.pollBusy || root.watchlist.length === 0) return
        root.pollBusy = true

        var entry = root.watchlist[root.pollIndex % root.watchlist.length]
        root.pollIndex++

        var raw = logos.callModule("liblogos_zone_sequencer_module",
                                   "query_channel_paged",
                                   [entry.channelId, entry.cursorJson || "{}", 20])
        var res = callModuleParse(raw)

        if (!res || !Array.isArray(res.messages)) {
            root.pollBusy = false
            return
        }

        for (var i = 0; i < res.messages.length; i++) {
            dispatchMessage(entry, res.messages[i])
        }

        // Always save cursor (done=true means tail reached; must persist so next
        // poll starts from here to pick up NEW messages, not replay from start)
        if (res.cursor) {
            var cursorStr = JSON.stringify(res.cursor)
            logos.callModule("logos_cord", "updateCursor",
                             [entry.channelId, cursorStr])
            // Update local watchlist mirror
            for (var j = 0; j < root.watchlist.length; j++) {
                if (root.watchlist[j].channelId === entry.channelId) {
                    var wlEntry = root.watchlist[j]
                    wlEntry.cursorJson = cursorStr
                    root.watchlist[j] = wlEntry
                    break
                }
            }
        }

        root.pollBusy = false
    }

    // ── dispatchMessage ───────────────────────────────────────────────────────
    function dispatchMessage(entry, msg) {
        var payload = callModuleParse(msg.data)
        if (!payload || payload.v !== 1) return

        if (payload.type === "cid_pin") {
            // v1: record only — download deferred until logos_storage is ready
            var raw = logos.callModule("logos_cord", "recordDispatch",
                         [entry.channelId, msg.id, "cid_pin",
                          payload.cid || "", payload.source || "", "received"])
            var res = callModuleParse(raw)
            if (res && res.ok) {
                // Prepend to UI log (newest first)
                dispatchLogModel.insert(0, {
                    channelId:   entry.channelId,
                    label:       entry.label,
                    messageId:   msg.id,
                    cid:         payload.cid || "",
                    source:      payload.source || "",
                    type:        "cid_pin",
                    ts:          Math.floor(Date.now() / 1000),
                    result:      "received",
                    dispatchedTs: Math.floor(Date.now() / 1000)
                })
                // Trim UI model to 200
                while (dispatchLogModel.count > 200) {
                    dispatchLogModel.remove(dispatchLogModel.count - 1)
                }
            }
        } else if (payload.type === "channel_announce") {
            // Prompt user — never auto-add
            var announcement = {
                channelId: payload.channel_id || "",
                label:     payload.label      || "unnamed",
                module:    payload.module      || "unknown"
            }
            var alreadyPending = false
            for (var i = 0; i < root.pendingAnnouncements.length; i++) {
                if (root.pendingAnnouncements[i].channelId === announcement.channelId) {
                    alreadyPending = true
                    break
                }
            }
            if (!alreadyPending && announcement.channelId !== "") {
                root.pendingAnnouncements = root.pendingAnnouncements.concat([announcement])
                announcementModel.append(announcement)
            }
        } else if (payload.type === "channel_manifest") {
            // channel_manifest: module sub-channel discovery from Beacon PR #7
            var manifestAnnouncement = {
                channelId: payload.channelId || "",
                label:     (payload.module || "unknown") + " backup channel",
                module:    payload.module || "unknown"
            }
            var alreadyInWatchlist = false
            for (var k = 0; k < root.watchlist.length; k++) {
                if (root.watchlist[k].channelId === manifestAnnouncement.channelId) {
                    alreadyInWatchlist = true; break
                }
            }
            var alreadyPendingManifest = false
            for (var m = 0; m < root.pendingAnnouncements.length; m++) {
                if (root.pendingAnnouncements[m].channelId === manifestAnnouncement.channelId) {
                    alreadyPendingManifest = true; break
                }
            }
            if (!alreadyInWatchlist && !alreadyPendingManifest
                    && manifestAnnouncement.channelId !== "") {
                root.pendingAnnouncements = root.pendingAnnouncements.concat([manifestAnnouncement])
                announcementModel.append(manifestAnnouncement)
            }
        }
        // unknown types: silently skip
    }

    // ── Add channel from input ────────────────────────────────────────────────
    function addChannelFromInput() {
        var id    = addChannelIdInput.text.trim()
        var label = addChannelLabelInput.text.trim()
        if (id === "") return

        var raw = logos.callModule("logos_cord", "addChannel", [id, label])
        var res = callModuleParse(raw)
        if (!res) {
            root.statusMsg = "Failed to add channel"
            return
        }
        if (res.error) {
            root.statusMsg = res.error === "duplicate"
                ? "Channel already in watchlist"
                : "Error: " + res.error
            return
        }
        // Success
        addChannelIdInput.text    = ""
        addChannelLabelInput.text = ""
        root.statusMsg = ""
        Qt.callLater(loadWatchlist)
    }

    function removeChannel(channelId) {
        logos.callModule("logos_cord", "removeChannel", [channelId])
        Qt.callLater(loadWatchlist)
    }

    function acceptAnnouncement(announcement) {
        logos.callModule("logos_cord", "addChannel",
                         [announcement.channelId, announcement.label])
        dismissAnnouncement(announcement.channelId)
        Qt.callLater(loadWatchlist)
    }

    function dismissAnnouncement(channelId) {
        var updated = []
        for (var i = 0; i < root.pendingAnnouncements.length; i++) {
            if (root.pendingAnnouncements[i].channelId !== channelId)
                updated.push(root.pendingAnnouncements[i])
        }
        root.pendingAnnouncements = updated
        // Rebuild model
        announcementModel.clear()
        for (var j = 0; j < root.pendingAnnouncements.length; j++) {
            announcementModel.append(root.pendingAnnouncements[j])
        }
    }

    // ── Models ────────────────────────────────────────────────────────────────
    ListModel { id: watchlistModel }
    ListModel { id: dispatchLogModel }
    ListModel { id: announcementModel }

    // ── Root background ───────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: root.bgPrimary

        ColumnLayout {
            anchors.fill:   parent
            anchors.margins: 16
            spacing: 0

            // ── Header ────────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                ColumnLayout {
                    spacing: 2

                    Text {
                        text: "Cord"
                        color: root.textPrimary
                        font.pixelSize: 20
                        font.bold: true
                    }
                    Text {
                        text: "Receives CIDs from Beacon inscriptions"
                        color: root.textSecondary
                        font.pixelSize: 11
                    }
                }

                Text {
                    text: root.zoneSeqReady ? "connected" : "connecting…"
                    color: root.zoneSeqReady ? root.successGreen : root.warningAmber
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true }

                // Poll status dot
                Rectangle {
                    width: 8; height: 8
                    radius: 4
                    color: root.pollBusy ? root.warningAmber : root.successGreen
                    Layout.alignment: Qt.AlignVCenter
                    ToolTip.visible: hoverHandler.hovered
                    ToolTip.text: root.pollBusy ? "polling…" : "idle"
                    HoverHandler { id: hoverHandler }
                }
            }

            // ── Status message ────────────────────────────────────────────────
            Text {
                visible: root.statusMsg !== ""
                text: root.statusMsg
                color: root.errorRed
                font.pixelSize: 12
                Layout.fillWidth: true
                Layout.topMargin: 4
                wrapMode: Text.WordWrap
            }

            // ── Announcement banners ──────────────────────────────────────────
            Repeater {
                model: announcementModel
                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    height: 56
                    color: "#1A2A1A"
                    border.color: root.successGreen
                    border.width: 1
                    radius: 6

                    RowLayout {
                        anchors { fill: parent; margins: 8 }
                        spacing: 8

                        Column {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: "Channel announced: " + model.label
                                color: root.textPrimary
                                font.pixelSize: 13
                                font.bold: true
                            }
                            Text {
                                text: "Module: " + model.module + "  ·  " + model.channelId.substring(0, 16) + "…"
                                color: root.textSecondary
                                font.pixelSize: 11
                            }
                        }

                        // Add button
                        Rectangle {
                            width: 48; height: 28
                            color: addAnnouncementMa.containsPress ? root.accentPressed
                                 : addAnnouncementMa.containsMouse ? root.accentHover
                                 : root.accent
                            radius: 4
                            Text {
                                anchors.centerIn: parent
                                text: "Add"
                                color: root.textPrimary
                                font.pixelSize: 12
                                font.bold: true
                            }
                            MouseArea {
                                id: addAnnouncementMa
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.acceptAnnouncement({
                                    channelId: model.channelId,
                                    label:     model.label,
                                    module:    model.module
                                })
                            }
                        }

                        // Dismiss button
                        Rectangle {
                            width: 60; height: 28
                            color: dismissMa.containsPress ? "#444"
                                 : dismissMa.containsMouse ? "#3A3A3A"
                                 : "#2A2A2A"
                            radius: 4
                            Text {
                                anchors.centerIn: parent
                                text: "Dismiss"
                                color: root.textSecondary
                                font.pixelSize: 12
                            }
                            MouseArea {
                                id: dismissMa
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.dismissAnnouncement(model.channelId)
                            }
                        }
                    }
                }
            }

            // ── Tab bar ───────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 12
                spacing: 0

                Repeater {
                    model: ["Watchlist", "Dispatch Log"]
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        color:  root.currentTab === index ? root.bgSecondary : "transparent"
                        border.color: root.currentTab === index ? root.accent : "transparent"
                        border.width: root.currentTab === index ? 0 : 0

                        Rectangle {
                            visible: root.currentTab === index
                            anchors.bottom: parent.bottom
                            anchors.left:   parent.left
                            anchors.right:  parent.right
                            height: 2
                            color: root.accent
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: root.currentTab === index ? root.textPrimary : root.textMuted
                            font.pixelSize: 14
                            font.bold: root.currentTab === index
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.currentTab = index
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.borderColor
            }

            // ── Tab content ───────────────────────────────────────────────────
            Item {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                Layout.topMargin:  12

                // ── WATCHLIST TAB ─────────────────────────────────────────────
                ColumnLayout {
                    visible: root.currentTab === 0
                    anchors.fill: parent
                    spacing: 12

                    // Add channel form
                    Rectangle {
                        Layout.fillWidth: true
                        height: 96
                        color: root.bgSecondary
                        radius: 6
                        border.color: root.borderColor
                        border.width: 1

                        ColumnLayout {
                            anchors { fill: parent; margins: 10 }
                            spacing: 6

                            TextField {
                                id: addChannelIdInput
                                Layout.fillWidth: true
                                placeholderText: "Channel ID (hex)"
                                color: root.textPrimary
                                placeholderTextColor: root.textMuted
                                background: Rectangle {
                                    color: "#1E1E1E"
                                    radius: 4
                                    border.color: addChannelIdInput.activeFocus
                                        ? root.accent : root.borderColor
                                    border.width: 1
                                }
                                font.pixelSize: 13
                                font.family: "monospace"
                                onAccepted: root.addChannelFromInput()
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                TextField {
                                    id: addChannelLabelInput
                                    Layout.fillWidth: true
                                    placeholderText: "Label (optional)"
                                    color: root.textPrimary
                                    placeholderTextColor: root.textMuted
                                    background: Rectangle {
                                        color: "#1E1E1E"
                                        radius: 4
                                        border.color: addChannelLabelInput.activeFocus
                                            ? root.accent : root.borderColor
                                        border.width: 1
                                    }
                                    font.pixelSize: 13
                                    onAccepted: root.addChannelFromInput()
                                }

                                Rectangle {
                                    width: 80; height: 32
                                    color: addBtnMa.containsPress ? root.accentPressed
                                         : addBtnMa.containsMouse ? root.accentHover
                                         : root.accent
                                    radius: 4
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Add"
                                        color: root.textPrimary
                                        font.pixelSize: 13
                                        font.bold: true
                                    }
                                    MouseArea {
                                        id: addBtnMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: root.addChannelFromInput()
                                    }
                                }
                            }
                        }
                    }

                    // Watchlist items
                    ScrollView {
                        Layout.fillWidth:  true
                        Layout.fillHeight: true
                        clip: true

                        ListView {
                            id: watchlistView
                            anchors.fill: parent
                            model: watchlistModel
                            spacing: 6

                            delegate: Rectangle {
                                width:  watchlistView.width
                                height: 64
                                color:  itemMa.containsMouse ? "#2A2A2A" : root.bgSecondary
                                radius: 6
                                border.color: root.borderColor
                                border.width: 1

                                RowLayout {
                                    anchors { fill: parent; margins: 10 }
                                    spacing: 8

                                    // Status dot
                                    Rectangle {
                                        width: 8; height: 8; radius: 4
                                        color: model.lastSeen > 0
                                            ? root.successGreen : root.textMuted
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Column {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Text {
                                            text: model.label || model.channelId
                                            color: root.textPrimary
                                            font.pixelSize: 14
                                            font.bold: true
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }
                                        Text {
                                            text: model.channelId.substring(0, 24) + "…"
                                            color: root.textMuted
                                            font.pixelSize: 11
                                            font.family: "monospace"
                                        }
                                        Text {
                                            visible: model.lastSeen > 0
                                            text: "last seen: " + new Date(model.lastSeen * 1000).toLocaleString()
                                            color: root.textMuted
                                            font.pixelSize: 10
                                        }
                                    }

                                    // Pending badge — visible only when pendingCount > 0
                                    Rectangle {
                                        visible: model.pendingCount > 0
                                        width: 26
                                        height: 18
                                        color: root.accent
                                        radius: 9
                                        Layout.alignment: Qt.AlignVCenter

                                        Text {
                                            anchors.centerIn: parent
                                            text: model.pendingCount > 99 ? "99+" : model.pendingCount.toString()
                                            color: root.textPrimary
                                            font.pixelSize: 10
                                            font.bold: true
                                        }
                                    }

                                    // Copy channel ID
                                    Rectangle {
                                        width: 28; height: 28
                                        color: copyMa.containsMouse ? "#3A3A3A" : "transparent"
                                        radius: 4
                                        Text {
                                            anchors.centerIn: parent
                                            text: "⎘"
                                            color: root.textSecondary
                                            font.pixelSize: 14
                                        }
                                        MouseArea {
                                            id: copyMa
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: root.copyToClipboard(model.channelId)
                                        }
                                        ToolTip.visible: copyMa.containsMouse
                                        ToolTip.text: "Copy channel ID"
                                    }

                                    // Remove button
                                    Rectangle {
                                        width: 28; height: 28
                                        color: removeMa.containsMouse ? "#3A1A1A" : "transparent"
                                        radius: 4
                                        Text {
                                            anchors.centerIn: parent
                                            text: "✕"
                                            color: removeMa.containsMouse ? root.errorRed : root.textMuted
                                            font.pixelSize: 14
                                        }
                                        MouseArea {
                                            id: removeMa
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: root.removeChannel(model.channelId)
                                        }
                                        ToolTip.visible: removeMa.containsMouse
                                        ToolTip.text: "Remove from watchlist"
                                    }
                                }

                                MouseArea {
                                    id: itemMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.NoButton
                                }
                            }

                            // Empty state
                            Text {
                                visible:         watchlistModel.count === 0
                                anchors.centerIn: parent
                                text: "No channels in watchlist.\nPaste a channel ID above to subscribe."
                                color: root.textMuted
                                font.pixelSize: 13
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }

                // ── DISPATCH LOG TAB ──────────────────────────────────────────
                ColumnLayout {
                    visible: root.currentTab === 1
                    anchors.fill: parent
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: dispatchLogModel.count + " entries"
                            color: root.textMuted
                            font.pixelSize: 12
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            width: 60; height: 26
                            color: refreshMa.containsPress ? "#3A3A3A"
                                 : refreshMa.containsMouse ? "#2E2E2E"
                                 : "#252525"
                            radius: 4
                            border.color: root.borderColor
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: "Refresh"
                                color: root.textSecondary
                                font.pixelSize: 11
                            }
                            MouseArea {
                                id: refreshMa
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.loadDispatchLog()
                            }
                        }
                    }

                    ScrollView {
                        Layout.fillWidth:  true
                        Layout.fillHeight: true
                        clip: true

                        ListView {
                            id: logView
                            anchors.fill: parent
                            model: dispatchLogModel
                            spacing: 4

                            delegate: Rectangle {
                                width:  logView.width
                                height: 54
                                color:  logItemMa.containsMouse ? "#252525" : "#1E1E1E"
                                radius: 4
                                border.color: model.result === "received"
                                    ? "#1A3A2A" : root.borderColor
                                border.width: 1

                                RowLayout {
                                    anchors { fill: parent; margins: 8 }
                                    spacing: 8

                                    // Type indicator
                                    Rectangle {
                                        width: 4
                                        height: parent.height - 4
                                        radius: 2
                                        color: model.type === "cid_pin"
                                            ? root.successGreen
                                            : root.warningAmber
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Column {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        RowLayout {
                                            width: parent.width
                                            spacing: 6

                                            Text {
                                                text: model.type || "unknown"
                                                color: model.type === "cid_pin"
                                                    ? root.successGreen : root.warningAmber
                                                font.pixelSize: 12
                                                font.bold: true
                                            }

                                            Text {
                                                text: "from " + (model.label || model.channelId)
                                                color: root.textSecondary
                                                font.pixelSize: 12
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }

                                            Text {
                                                visible: model.source !== "" && model.source !== undefined
                                                text: "[" + (model.source || "") + "]"
                                                color: root.accent
                                                font.pixelSize: 11
                                                font.bold: true
                                            }

                                            Text {
                                                text: model.ts > 0
                                                    ? Qt.formatTime(new Date(model.ts * 1000), "hh:mm:ss")
                                                    : ""
                                                color: root.textMuted
                                                font.pixelSize: 11
                                            }
                                        }

                                        Text {
                                            visible: model.cid !== ""
                                            text: model.cid ? model.cid.substring(0, 32) + "…" : ""
                                            color: root.textMuted
                                            font.pixelSize: 11
                                            font.family: "monospace"
                                        }
                                    }

                                    // Copy CID button
                                    Rectangle {
                                        visible: model.cid !== ""
                                        width: 24; height: 24
                                        color: copyCidMa.containsMouse ? "#3A3A3A" : "transparent"
                                        radius: 3
                                        Text {
                                            anchors.centerIn: parent
                                            text: "⎘"
                                            color: root.textMuted
                                            font.pixelSize: 13
                                        }
                                        MouseArea {
                                            id: copyCidMa
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: root.copyToClipboard(model.cid)
                                        }
                                        ToolTip.visible: copyCidMa.containsMouse
                                        ToolTip.text: "Copy CID"
                                    }
                                }

                                MouseArea {
                                    id: logItemMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.NoButton
                                }
                            }

                            // Empty state
                            Text {
                                visible:          dispatchLogModel.count === 0
                                anchors.centerIn: parent
                                text: "No dispatched messages yet.\nAdd channels to the watchlist to start receiving."
                                color: root.textMuted
                                font.pixelSize: 13
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
            }

            // ── Config row ────────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.borderColor
                Layout.topMargin: 8
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 6
                spacing: 8

                Text {
                    text: "Node:"
                    color: root.textMuted
                    font.pixelSize: 11
                }

                TextField {
                    id: nodeUrlInput
                    text: root.nodeUrl
                    Layout.fillWidth: true
                    font.pixelSize: 11
                    color: root.textPrimary
                    placeholderTextColor: root.textMuted
                    background: Rectangle {
                        color: "#1E1E1E"
                        radius: 3
                        border.color: nodeUrlInput.activeFocus ? root.accent : root.borderColor
                        border.width: 1
                    }
                    onAccepted: {
                        logos.callModule("logos_cord", "setNodeUrl", [text.trim()])
                        root.nodeUrl = text.trim()
                        logos.callModule("liblogos_zone_sequencer_module",
                                         "set_node_url", [text.trim()])
                    }
                }

                Text {
                    text: "Poll:"
                    color: root.textMuted
                    font.pixelSize: 11
                }

                TextField {
                    id: pollIntervalInput
                    text: Math.round(root.pollIntervalMs / 1000).toString()
                    width: 48
                    font.pixelSize: 11
                    color: root.textPrimary
                    placeholderTextColor: root.textMuted
                    background: Rectangle {
                        color: "#1E1E1E"
                        radius: 3
                        border.color: pollIntervalInput.activeFocus ? root.accent : root.borderColor
                        border.width: 1
                    }
                    validator: IntValidator { bottom: 15; top: 300 }
                    onAccepted: {
                        var secs = parseInt(text) || 30
                        logos.callModule("logos_cord", "setPollInterval", [secs])
                        root.pollIntervalMs = secs * 1000
                    }
                }

                Text {
                    text: "s"
                    color: root.textMuted
                    font.pixelSize: 11
                }
            }
        }
    }
}
