# cord-basecamp — Retro Log

## 2026-04-20 — Initial scaffold

**Implemented:**
- All 10 issues from the plan (scaffold through tests)
- C++ plugin: watchlist management, cursor tracking, dispatch log, config
- QML UI: watchlist panel, dispatch log panel, round-robin poll loop
- Unit tests covering addChannel/duplicate/remove, cursor, dispatch log, persistence, config

**Key decisions:**
- v1: cid_pin recorded only (no download) — blocked on logos_storage
- channel_announce: user prompt only, never auto-add
- Zone seq: read-only init (set_node_url only, no signing key)
- No --whole-archive (Qt 6.9.3 exception, same as beacon-basecamp)

**Deferred:**
- Issue #11: auto-download (needs logos_storage download-to-disk API)
- Issue #12: Cord_sidebar.png icon (28×28 PNG needed)
- Beacon Issue #13: channel_announce inscription type (prerequisite for discovery)
