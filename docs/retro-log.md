# cord-basecamp — Retro Log

## 2026-05-21 — Platform alignment (RC3 / new SDK)

**Win:** All 3 alignment fixes applied and tested (18/18 tests pass):
- CMakeLists: updated hardcoded Nix store paths to current module-builder hashes
- logos_api_stub.cpp: added `logos_object.h` + `logos_api_provider.h`; dropped `onEvent` stub (not used by CordPlugin)
- flake.nix: added `nixpkgs.follows = "logos-module-builder/nixpkgs"` + `...` in outputs destructuring

**Win:** Git repo initialised, remote pushed to GitHub, LGX built and installed.

**Fail → Recovered:** `git init` run before `.gitignore` existed — build/ (100+ files)
committed in init commit. Merging the fix branch back to main was blocked by
working-tree conflicts. Resolved by cherry-picking the two fix-branch commits onto
main instead of merging.

**Skill extracted:** `git-init-gitignore-first` — always write `.gitignore` before
`git add` when initialising a new module repo.

**Deferred (unchanged):**
- Issue #11: auto-download (needs logos_storage)
- Issue #12: Cord_sidebar.png icon

---

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
