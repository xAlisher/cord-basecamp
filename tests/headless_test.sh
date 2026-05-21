#!/usr/bin/env bash
# Headless smoke test for logos_cord via logoscore.
# No AppImage — exercises all Q_INVOKABLE methods callable through logoscore.
#
# Coverage:
#   getCordConfig / setNodeUrl / setPollInterval     → tested here
#   addChannel / removeChannel / getWatchlist        → tested here
#   updateCursor                                     → tested here
#   getDispatchLog                                   → structure verified here
#   recordDispatch (6 args)                          → unit tests only (exceeds logoscore -c arg limit)
#
# Usage:
#   bash tests/headless_test.sh
#   LOGOSCORE=/path/to/logoscore bash tests/headless_test.sh

set -uo pipefail

# ── Locate logoscore ──────────────────────────────────────────────────────────
if [[ -z "${LOGOSCORE:-}" ]]; then
    LOGOSCORE=$(find /nix/store -maxdepth 4 -name logoscore -path "*/bin/*" 2>/dev/null | head -1)
fi
if [[ -z "$LOGOSCORE" || ! -x "$LOGOSCORE" ]]; then
    echo "ERROR: logoscore not found — set LOGOSCORE env var" >&2
    exit 1
fi
echo "logoscore: $LOGOSCORE"

# ── Prepare isolated modules dir ─────────────────────────────────────────────
MDIR=$(mktemp -d)
trap 'rm -rf "$MDIR"' EXIT

SRC_DIR="$HOME/.local/share/Logos/LogosBasecamp/modules/logos_cord"
if [[ ! -d "$SRC_DIR" ]]; then
    echo "ERROR: logos_cord not installed at $SRC_DIR" >&2
    echo "       Run: cmake --install cord-basecamp/build" >&2
    exit 1
fi
mkdir -p "$MDIR/logos_cord"
cp -r "$SRC_DIR/." "$MDIR/logos_cord/"

# ── Helpers ───────────────────────────────────────────────────────────────────
PASS=0
FAIL=0

# call <method> [arg...]
# Single-invocation mode: logoscore -c "logos_cord.method(arg1,arg2,...)"
# Args are quoted in the expression string.
#
# Known logoscore -c limitations:
#  - All-digit quoted strings (e.g. "1234...") are coerced to numbers →
#    channel IDs must contain at least one hex letter (a-f)
#  - Max ~4 quoted string args; methods with 5+ args return "invalid result"
#    (recordDispatch has 6 args → tested via ctest unit tests only)
call() {
    local method="$1"; shift
    local expr
    if [[ $# -gt 0 ]]; then
        local args_joined
        args_joined=$(printf '"%s",' "$@")
        args_joined="${args_joined%,}"
        expr="logos_cord.${method}(${args_joined})"
    else
        expr="logos_cord.${method}()"
    fi
    local raw
    raw=$(XDG_CONFIG_HOME="$MDIR/.config" \
          "$LOGOSCORE" -m "$MDIR" -l logos_cord \
          -c "$expr" --quit-on-finish 2>/dev/null || true)
    echo "$raw" | sed 's/^Method call successful\. Result: //'
}

parse_field() {
    python3 -c "
import sys, json
r = sys.argv[1]
try:
    d = json.loads(r)
    if isinstance(d, str): d = json.loads(d)
    print(d.get(sys.argv[2], ''))
except:
    print('')" "$1" "$2" 2>/dev/null || true
}

assert_field() {
    local label="$1" json="$2" field="$3" expected="$4"
    local actual norm_a norm_e
    actual=$(parse_field "$json" "$field")
    norm_a=$(echo "$actual" | tr '[:upper:]' '[:lower:]')
    norm_e=$(echo "$expected" | tr '[:upper:]' '[:lower:]')
    if [[ "$norm_a" == "$norm_e" ]]; then
        echo "  PASS  $label"
        ((PASS++)) || true
    else
        echo "  FAIL  $label  (expected $field=$expected, got $field=$actual)"
        ((FAIL++)) || true
    fi
}

assert_has_key() {
    local label="$1" json="$2" key="$3"
    local present
    present=$(python3 -c "
import sys, json
r = sys.argv[1]
try:
    d = json.loads(r)
    if isinstance(d, str): d = json.loads(d)
    print('yes' if sys.argv[2] in d else 'no')
except:
    print('no')" "$json" "$key" 2>/dev/null || echo "no")
    if [[ "$present" == "yes" ]]; then
        echo "  PASS  $label"
        ((PASS++)) || true
    else
        echo "  FAIL  $label  (key '$key' missing in: $json)"
        ((FAIL++)) || true
    fi
}

assert_is_array() {
    local label="$1" json="$2"
    local ok
    ok=$(python3 -c "
import sys, json
r = sys.argv[1]
try:
    d = json.loads(r)
    if isinstance(d, str): d = json.loads(d)
    print('yes' if isinstance(d, list) else 'no')
except:
    print('no')" "$json" 2>/dev/null || echo "no")
    if [[ "$ok" == "yes" ]]; then
        echo "  PASS  $label"
        ((PASS++)) || true
    else
        echo "  FAIL  $label  (expected JSON array, got: $json)"
        ((FAIL++)) || true
    fi
}

# Test channel IDs — must contain letters (logoscore coerces all-digit strings to numbers)
CHAN_A="aabbccdd11223344aabbccdd11223344aabbccdd11223344aabbccdd11223344"
CHAN_B="bb22334455667788bb2233445566778811223344556677881122334455667788"

# ── Section 1: Config defaults ────────────────────────────────────────────────
echo
echo "=== 1. Config defaults ==="

R=$(call getCordConfig)
echo "  getCordConfig → $R"
assert_field "default nodeUrl"      "$R" "nodeUrl"      "http://127.0.0.1:8080"
assert_field "default pollInterval" "$R" "pollInterval" "30"

# ── Section 2: setNodeUrl ─────────────────────────────────────────────────────
echo
echo "=== 2. setNodeUrl ==="

R=$(call setNodeUrl "http://node.example.com:9000")
assert_field "setNodeUrl ok" "$R" "ok" "true"

R=$(call getCordConfig)
assert_field "nodeUrl updated" "$R" "nodeUrl" "http://node.example.com:9000"

# Reset
call setNodeUrl "http://127.0.0.1:8080" > /dev/null

# Empty URL → error: logoscore -c cannot pass empty-string args; covered by unit tests.
echo "  SKIP  setNodeUrl('') — empty-arg limitation in logoscore -c mode (unit test covers it)"

# ── Section 3: setPollInterval ────────────────────────────────────────────────
echo
echo "=== 3. setPollInterval (clamping) ==="

R=$(call setPollInterval 5)
assert_field "setPollInterval(5) ok" "$R" "ok" "true"
R=$(call getCordConfig)
assert_field "clamped to 15 (min)" "$R" "pollInterval" "15"

R=$(call setPollInterval 9999)
assert_field "setPollInterval(9999) ok" "$R" "ok" "true"
R=$(call getCordConfig)
assert_field "clamped to 300 (max)" "$R" "pollInterval" "300"

R=$(call setPollInterval 60)
R=$(call getCordConfig)
assert_field "in-range 60 accepted" "$R" "pollInterval" "60"

# Reset
call setPollInterval 30 > /dev/null

# ── Section 4: addChannel ─────────────────────────────────────────────────────
echo
echo "=== 4. addChannel ==="

# Clean state from any prior runs
call removeChannel "$CHAN_A" > /dev/null 2>&1 || true
call removeChannel "$CHAN_B" > /dev/null 2>&1 || true

R=$(call addChannel "$CHAN_A" "Alice")
assert_field "addChannel CHAN_A → ok" "$R" "ok" "true"

R=$(call addChannel "$CHAN_B" "Bob")
assert_field "addChannel CHAN_B → ok" "$R" "ok" "true"

R=$(call addChannel "$CHAN_A" "Alice again")
assert_field "duplicate → error=duplicate" "$R" "error" "duplicate"

R=$(call addChannel "not-hex!!!" "Bad")
assert_has_key "invalid hex → error" "$R" "error"

# ── Section 5: getWatchlist ───────────────────────────────────────────────────
echo
echo "=== 5. getWatchlist ==="

R=$(call getWatchlist)
assert_is_array "getWatchlist returns array" "$R"

COUNT=$(python3 -c "
import sys, json
r = sys.argv[1]
try:
    d = json.loads(r)
    if isinstance(d, str): d = json.loads(d)
    print(len(d))
except:
    print(0)" "$R" 2>/dev/null || echo 0)
if [[ "$COUNT" -ge 2 ]]; then
    echo "  PASS  getWatchlist >= 2 entries ($COUNT)"
    ((PASS++)) || true
else
    echo "  FAIL  getWatchlist: expected >= 2 entries, got $COUNT  ($R)"
    ((FAIL++)) || true
fi

# Verify CHAN_A label
FOUND_LABEL=$(python3 -c "
import sys, json
r = sys.argv[1]; cid = sys.argv[2]
try:
    d = json.loads(r)
    if isinstance(d, str): d = json.loads(d)
    entry = next((e for e in d if e.get('channelId') == cid), None)
    print(entry['label'] if entry else '')
except:
    print('')" "$R" "$CHAN_A" 2>/dev/null || true)
if [[ "$FOUND_LABEL" == "Alice" ]]; then
    echo "  PASS  CHAN_A label = Alice"
    ((PASS++)) || true
else
    echo "  FAIL  CHAN_A label: expected Alice, got '$FOUND_LABEL'"
    ((FAIL++)) || true
fi

# Verify required fields on first entry
ENTRY0=$(python3 -c "
import sys, json
r = sys.argv[1]
try:
    d = json.loads(r)
    if isinstance(d, str): d = json.loads(d)
    print(json.dumps(d[0]) if d else '{}')
except:
    print('{}')" "$R" 2>/dev/null || echo '{}')
assert_has_key "entry has channelId"    "$ENTRY0" "channelId"
assert_has_key "entry has label"        "$ENTRY0" "label"
assert_has_key "entry has cursorJson"   "$ENTRY0" "cursorJson"
assert_has_key "entry has pendingCount" "$ENTRY0" "pendingCount"
assert_has_key "entry has lastSeen"     "$ENTRY0" "lastSeen"

# ── Section 6: removeChannel ──────────────────────────────────────────────────
echo
echo "=== 6. removeChannel ==="

R=$(call removeChannel "$CHAN_B")
assert_field "removeChannel ok" "$R" "ok" "true"

R=$(call getWatchlist)
STILL=$(python3 -c "
import sys, json
r = sys.argv[1]; cid = sys.argv[2]
try:
    d = json.loads(r)
    if isinstance(d, str): d = json.loads(d)
    print('yes' if any(e.get('channelId') == cid for e in d) else 'no')
except:
    print('yes')" "$R" "$CHAN_B" 2>/dev/null || echo "yes")
if [[ "$STILL" == "no" ]]; then
    echo "  PASS  CHAN_B removed from watchlist"
    ((PASS++)) || true
else
    echo "  FAIL  CHAN_B still in watchlist after removal"
    ((FAIL++)) || true
fi

R=$(call removeChannel "$CHAN_B")
assert_has_key "remove non-existent → error" "$R" "error"

# ── Section 7: updateCursor ───────────────────────────────────────────────────
echo
echo "=== 7. updateCursor ==="

R=$(call updateCursor "$CHAN_A" "{}")
assert_field "updateCursor ok" "$R" "ok" "true"

R=$(call getWatchlist)
LAST_SEEN=$(python3 -c "
import sys, json
r = sys.argv[1]; cid = sys.argv[2]
try:
    d = json.loads(r)
    if isinstance(d, str): d = json.loads(d)
    entry = next((e for e in d if e.get('channelId') == cid), None)
    print(entry.get('lastSeen', 0) if entry else 0)
except:
    print(0)" "$R" "$CHAN_A" 2>/dev/null || echo 0)
if [[ "$LAST_SEEN" -gt 0 ]]; then
    echo "  PASS  lastSeen updated ($LAST_SEEN)"
    ((PASS++)) || true
else
    echo "  FAIL  lastSeen not updated: got $LAST_SEEN"
    ((FAIL++)) || true
fi

R=$(call updateCursor "$CHAN_B" "{}")
assert_has_key "updateCursor unknown channel → error" "$R" "error"

# ── Section 8: getDispatchLog ─────────────────────────────────────────────────
echo
echo "=== 8. getDispatchLog ==="
echo "  NOTE: recordDispatch (6 args) exceeds logoscore -c arg limit — covered by ctest"

R=$(call getDispatchLog)
assert_is_array "getDispatchLog returns array" "$R"

LOG_LEN=$(python3 -c "
import sys, json
r = sys.argv[1]
try:
    d = json.loads(r)
    if isinstance(d, str): d = json.loads(d)
    print(len(d))
except:
    print(-1)" "$R" 2>/dev/null || echo -1)
echo "  INFO  dispatch log has $LOG_LEN entries"

if [[ "$LOG_LEN" -le 200 ]]; then
    echo "  PASS  dispatch log within 200-entry cap"
    ((PASS++)) || true
else
    echo "  FAIL  dispatch log exceeds 200 entries ($LOG_LEN)"
    ((FAIL++)) || true
fi

# If there are existing entries, verify their structure
if [[ "$LOG_LEN" -gt 0 ]]; then
    ENTRY0=$(python3 -c "
import sys, json
r = sys.argv[1]
try:
    d = json.loads(r)
    if isinstance(d, str): d = json.loads(d)
    print(json.dumps(d[0]) if d else '{}')
except:
    print('{}')" "$R" 2>/dev/null || echo '{}')
    assert_has_key "log entry has channelId"   "$ENTRY0" "channelId"
    assert_has_key "log entry has messageId"   "$ENTRY0" "messageId"
    assert_has_key "log entry has type"        "$ENTRY0" "type"
    assert_has_key "log entry has cid"         "$ENTRY0" "cid"
    assert_has_key "log entry has ts"          "$ENTRY0" "ts"
    assert_has_key "log entry has result"      "$ENTRY0" "result"
    assert_has_key "log entry has dispatchedTs" "$ENTRY0" "dispatchedTs"
else
    echo "  SKIP  log entry structure (log is empty)"
fi

# ── Cleanup ───────────────────────────────────────────────────────────────────
echo
echo "=== Cleanup ==="
call removeChannel "$CHAN_A" > /dev/null && echo "  removed CHAN_A" || echo "  CHAN_A already gone"
call removeChannel "$CHAN_B" > /dev/null && echo "  removed CHAN_B" || echo "  CHAN_B already gone"

# ── Summary ───────────────────────────────────────────────────────────────────
echo
echo "================================"
echo "  $PASS passed  |  $FAIL failed"
echo "================================"
[[ $FAIL -eq 0 ]]
