# cord-basecamp — Codex Review Rules

## Senty review checklist (run before every PR merge)

### C++ (CordPlugin)

- [ ] All Q_INVOKABLE methods return `QString` (JSON), never `bool`/`int`/`QVariant`
- [ ] `logosAPI = api` in `initLogos` (not a private member)
- [ ] `instancePersistencePath` read from `property()` in `initLogos`
- [ ] `QDir().mkpath(m_persistencePath)` called in `initLogos`
- [ ] `saveWatchlist()` called after every mutation
- [ ] `saveDispatchLog()` called after every `recordDispatch`
- [ ] Dispatch log capped at 200 entries (trim before append)
- [ ] `pollInterval` clamped to [15, 300] in `setPollInterval`
- [ ] `addChannel` rejects empty or non-hex channel IDs
- [ ] `errorJson` / `okJson` helpers used consistently

### QML (Main.qml)

- [ ] `pollBusy` guard on all Timer callbacks (qml-callmodule-reentrancy-guard)
- [ ] `callModuleParse` three-layer canonical form present
- [ ] `Component.onCompleted` loads config + watchlist + dispatch log + inits zone seq
- [ ] Zone seq init: `set_node_url` only (Cord is read-only, no signing key)
- [ ] `channel_announce` → `pendingAnnouncements` (never auto-add)
- [ ] Clipboard TextEdit helper at root level (not nested)
- [ ] `ListModel` used for watchlist and dispatch log (not plain JS arrays for UI)
- [ ] `dispatchLogModel` prepend (newest first) on new entries

### Manifests

- [ ] `manifestVersion: "0.2.0"` in all manifest.json files
- [ ] `view: "Main.qml"` present in cord_ui manifest.json
- [ ] `variant` file contains `linux-amd64` in both module and plugin dirs
- [ ] `logos_cord` and `cord_ui` names consistent across all JSON files

### Build

- [ ] No `--whole-archive` around liblogos_sdk.a (Qt 6.9.3 compatibility)
- [ ] `configure_file` copies `plugin_metadata.json` to build dir for AUTOMOC
- [ ] patchelf RUNPATH patch present in CMakeLists.txt
- [ ] Mirror-to-LogosBasecamp install step present
- [ ] `logos_api.h` listed as source in test executable (staticMetaObject via AUTOMOC)
