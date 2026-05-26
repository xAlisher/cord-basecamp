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

| Module | Role |
|--------|------|
| `liblogos_zone_sequencer_module` | Queries zone channel pages |

No signing key required — Cord is read-only.

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
