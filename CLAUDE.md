# cord-basecamp — Claude Code Instructions

> Social layer: subscribe to other users' Beacon channels and dispatch their
> inscriptions to local modules.

## Identity & Protocols

You are **Fergie**. Protocols load via `.claude/rules/`. tmux-bridge labels:
`fergie@cord-basecamp`, `senty@cord-basecamp`.

**Alisher sign-off required for:**
- Destructive operations (rm -rf, force push, drop QSettings)
- API contract changes visible to other modules (e.g. `getWatchlist` / `getDispatchLog` return format)
- Major architectural pivots

Everything else: agents handle autonomously.

---

## Project Context

**cord-basecamp** — Reads other users' LEZ zone channels, parses `cid_pin` and
`channel_announce` payloads, and dispatches them to local modules.

- WatchList: persisted list of `{channelId, label, lastSeen, cursorJson, pendingCount}`
- Polls each watched channel via `query_channel_paged` every 30s (round-robin)
- `cid_pin` payloads → recorded in dispatch log (v1: no auto-download; blocked on logos_storage)
- `channel_announce` payloads → user prompt in UI (never auto-add)
- Dispatch log: last 200 entries, persisted to `instancePersistencePath/dispatch-log.json`

**Sibling modules this integrates with:**
- `liblogos_zone_sequencer_module` — reads channels via `query_channel_paged`
- `logos_beacon` — its `getBeaconConfig()` can be called to avoid self-subscription

**Bootstrap problem:** channel IDs shared manually for now. When Beacon adds
`channel_announce` (Issue #13), Cord can discover channels automatically.

---

## Code Style & Patterns

### Q_INVOKABLE — always return JSON strings

```cpp
Q_INVOKABLE QString getWatchlist() {
    return QJsonDocument(m_watchlist).toJson(QJsonDocument::Compact);
}
```

Never return `bool`, `int`, or QVariant.

### QSettings namespace: `cord/`

```cpp
static constexpr const char* kNodeUrlKey      = "cord/nodeUrl";
static constexpr const char* kPollIntervalKey = "cord/pollInterval";
```

### Persistence path

```cpp
QVariant prop = property("instancePersistencePath");
m_persistencePath = prop.isValid() ? prop.toString() : fallback;
```

Files stored there:
- `watchlist.json` — persisted watchlist
- `dispatch-log.json` — last 200 dispatched entries

### pollBusy guard (qml-callmodule-reentrancy-guard skill)

```qml
property bool pollBusy: false
function pollNext() {
    if (root.pollBusy || root.watchlist.length === 0) return
    root.pollBusy = true
    // ... do work ...
    root.pollBusy = false
}
```

### callModuleParse — three-layer form (callmoduleparse-canonical-form skill)

```javascript
function callModuleParse(raw) {
    try {
        var tmp = JSON.parse(raw)
        if (typeof tmp === 'string') {
            try { return JSON.parse(tmp) } catch(e) { return tmp }
        }
        return tmp
    } catch(e) { return null }
}
```

---

## Build & Test Workflow

```bash
# Build
cmake -B build && cmake --build build -j$(nproc)

# Test
cd build && ctest --output-on-failure

# Install to LogosBasecamp
cmake --install build

# Kill + relaunch Basecamp
pkill -9 -f "LogosBasecamp.elf"; sleep 1
~/logos-basecamp-current.AppImage &
```

---

## Module Install Paths

```
~/.local/share/Logos/LogosBasecamp/
├── modules/logos_cord/
│   ├── cord_plugin.so
│   ├── manifest.json / metadata.json / plugin_metadata.json / variant
└── plugins/cord_ui/
    ├── Main.qml / manifest.json / metadata.json / variant
```

---

## Zone Seq Usage (read-only)

Cord only reads from zone_seq — no signing key needed.

```javascript
// Init (call once at startup)
logos.callModule("liblogos_zone_sequencer_module", "set_node_url", [root.nodeUrl])

// Poll
var raw = logos.callModule("liblogos_zone_sequencer_module",
                           "query_channel_paged",
                           [channelId, cursorJson, 20])
// Returns: {"messages":[{"id":"hex","data":"text"},...],
//           "cursor":{...}, "done":bool}
```

---

## Download deferral (v1 decision)

Cord v1 records `cid_pin` entries in the dispatch log only. No download action.

Future: when `logos_storage` exposes a download-to-disk API, Stash gains a
"Received from Cord" tab. Cord's dispatch log is the handoff point.

Do NOT add download logic until logos_storage is ready.

---

## Common Pitfalls

- **`background: null` on TextEdit** — silent QML load failure. Only valid on TextField/TextArea.
- **Clipboard TextEdit helper must be at root level** — not inside nested Rectangle.
- **ListModel not JS array** — `model.get(i)` only works on ListModel.
- **variant file required** — `linux-amd64` must be in BOTH module and plugin dirs.
- **patchelf RUNPATH** — required so Qt libs resolve outside Nix environment.
- **pollBusy guard** — callModule blocks QML thread; Timer re-enters without guard.
- **No --whole-archive** — Qt 6.9.3 exception: see CMakeLists.txt comment.
- **channel_announce: never auto-add** — always prompt the user first.

---

## File Organization

```
cord-basecamp/
├── src/plugin/
│   ├── CordPlugin.h / CordPlugin.cpp
│   └── plugin_metadata.json
├── modules/logos_cord/
│   ├── manifest.json / metadata.json / plugin_metadata.json / variant
├── plugins/cord_ui/
│   ├── Main.qml / manifest.json / metadata.json / variant
├── tests/
│   ├── test_cord_plugin.cpp
│   └── logos_api_stub.cpp
├── docs/
│   └── retro-log.md
├── CMakeLists.txt
├── flake.nix
├── CLAUDE.md
└── CODEX.md
```

---

## Issue Tracking

| # | Epic | Title | Status |
|---|------|-------|--------|
| 1 | Scaffold | Project scaffold (CMake, manifests, flake.nix, CLAUDE.md) | done |
| 2 | Core | WatchList: addChannel / removeChannel / getWatchlist + persistence | done |
| 3 | Core | Cursor management: updateCursor, per-channel JSON cursor | done |
| 4 | Core | Dispatch log: recordDispatch / getDispatchLog, last 200 entries | done |
| 5 | Core | Config: nodeUrl, pollInterval in QSettings `cord/` | done |
| 6 | QML | Zone seq init + round-robin pollNext() with pollBusy guard | done |
| 7 | QML | dispatchMessage: cid_pin → recordDispatch; channel_announce → pendingAnnouncements | done |
| 8 | UI | Watchlist panel: add/remove channels, per-channel status, last-seen | done |
| 9 | UI | Dispatch log panel: activity feed with color-coded rows | done |
| 10 | Tests | Unit tests: addChannel/duplicate/remove, cursor update, dispatch log persistence | done |
| 11 | Future | Auto-download (blocked on logos_storage) | pending |
| 12 | Future | Cord icon (Cord_sidebar.png, 28×28) | pending |
