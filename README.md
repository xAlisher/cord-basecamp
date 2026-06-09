# cord-basecamp

Channel subscription and discovery module for [Logos Basecamp](https://github.com/xAlisher/logos-basecamp).

Subscribe to any Logos zone channel and Cord will poll it, decode inscriptions, and surface them in the UI. The primary use case: follow someone's Keeper channel to see everything they've permanently archived on Logos.

## How it works

```
Channel ID (from Beacon/Keeper)
        │
        ▼
Cord watchlist ──30s poll──► zone_query_channel_paged
                                      │
                              decode cid_pin payload
                                      │
                              dispatch log (UI + C++ persistence)
```

1. **Subscribe** — add a channel ID + label to your watchlist
2. **Poll** — Cord queries the Logos zone node every 30 seconds per channel (round-robin)
3. **Decode** — `cid_pin` inscriptions are recorded; future types (announce, manifest) trigger discovery prompts
4. **Discover** — channel manifests from Beacon automatically surface new sub-channels to subscribe to

## Getting a channel ID

- **Your own Keeper channel** — shown in the Beacon UI → Channels section after Keycard auth
- **Someone else's** — they share their channel ID (64-char hex) directly

## Dispatch log

Every decoded inscription is stored in the local dispatch log with:
- channel label + ID
- CID and source module
- timestamp received

## Dependencies

| Module | Installed name | Repo | Release |
|--------|---------------|------|---------|
| **cord** (this) | `logos_cord` | [cord-basecamp](https://github.com/xAlisher/cord-basecamp) | [v1.0.0 LGX](https://github.com/xAlisher/cord-basecamp/releases/tag/v1.0.0) |
| **cord-ui** (this) | `cord_ui` (plugin) | [cord-basecamp](https://github.com/xAlisher/cord-basecamp) | [v1.0.0 LGX](https://github.com/xAlisher/cord-basecamp/releases/tag/v1.0.0) |
| **zone sequencer** | `liblogos_zone_sequencer_module` | [xAlisher/logos-zone-sequencer-module](https://github.com/xAlisher/logos-zone-sequencer-module) — **not in AppImage**, fork of jimmy-claw's with stale-checkpoint + fr_from_bytes fixes | [v0.1.3 LGX](https://github.com/xAlisher/logos-zone-sequencer-module/releases/tag/v0.1.3) |

No signing key required — Cord is read-only.

## Configuration — set your node URL first

Cord polls the Logos zone node to fetch channel inscriptions. **Nothing will be received until you point Cord at a reachable node.**

1. Launch Logos Basecamp — the **Cord** tab appears in the sidebar
2. Open the **Settings** panel → **Node URL**
3. Enter your node's RPC endpoint (e.g. `http://localhost:8080`) and press **Enter**
4. The same node URL is forwarded to `liblogos_zone_sequencer_module` automatically

> There is no default public node. You need either a local Logos node or a shared testnet endpoint from the Logos team.

## Build

```bash
cmake -B build
cmake --build build -j$(nproc)
cmake --install build
```

## Known issues

- [#1](https://github.com/xAlisher/cord-basecamp/issues/1) Node URL resets on restart — press Enter after typing URL
- [#2](https://github.com/xAlisher/cord-basecamp/issues/2) UI does not live-update on new inscription — close/reopen tab to refresh

## Status

`v0.1.0` — working on LEZ testnet.
