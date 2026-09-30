#!/usr/bin/env bash
#
# pi-credential-audit.sh — answer two questions with facts, not vibes:
#   1. did any real credential leak into this repo (working tree OR full history)?
#   2. did dotfiles-ization drop any credential pi still needs?
#
# Values are never printed. Only labels, counts, and redacted excerpts.
#
# Usage: scripts/pi-credential-audit.sh
# Exit:  0 clean | 1 findings | 2 environment problem

set -uo pipefail

REPO=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "not a git repo" >&2; exit 2; }
cd "$REPO" || exit 2
AGENT_DIR="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"

fail=0
say()  { printf '%s\n' "$*"; }
ok()   { printf '  \033[0;32mok\033[0m    %s\n' "$*"; }
bad()  { printf '  \033[0;31mLEAK\033[0m  %s\n' "$*"; fail=1; }
warn() { printf '  \033[1;33mwarn\033[0m  %s\n' "$*"; }

say "pi credential audit — $(date '+%F %T')"
say "repo:  $REPO"
say "agent: $AGENT_DIR"
say ""

# ---------------------------------------------------------------------------
# 1. Collect every credential value pi actually uses on this machine
# ---------------------------------------------------------------------------
# mktemp gives a 600 file in /tmp: this list holds real credential values briefly
COLLECT=$(mktemp) || { echo "cannot create temp value list" >&2; exit 2; }
trap 'rm -f "$COLLECT"' EXIT

python3 - "$AGENT_DIR" "$COLLECT" <<'PY'
import json, re, sys, pathlib
agent, out = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
vals = []

def add(label, value):
    if isinstance(value, str) and len(value) >= 12:
        vals.append((label, value))

auth = agent / "auth.json"
if auth.exists():
    for prov, cred in json.loads(auth.read_text()).items():
        if isinstance(cred, dict):
            for field in ("key", "access", "refresh"):
                add(f"auth.json:{prov}.{field}", cred.get(field))
else:
    print("note: auth.json absent (nothing signed in yet)", file=sys.stderr)

for name in ("mcp-auth.json", "antigravity-accounts.json"):
    p = agent / name
    if not p.exists():
        continue
    for m in re.finditer(r'"(access|refresh|token|id_token|api_key|key)"\s*:\s*"([^"]{12,})"', p.read_text()):
        add(f"{name}:{m.group(1)}", m.group(2))

secrets = agent / "secrets.env"
if secrets.exists():
    for line in secrets.read_text().splitlines():
        m = re.match(r"\s*export\s+([A-Za-z0-9_]+)=(.*)$", line)
        if not m:
            continue
        key, raw = m.group(1), m.group(2).strip().strip("'\"")
        add(f"secrets.env:{key}", raw)
        for inner in re.findall(r'"[^"]+":"([^"]{12,})"', raw):   # nested JSON blobs
            add(f"secrets.env:{key}.inner", inner)

seen, rows = set(), []
for label, value in vals:
    if value in seen:
        continue
    seen.add(value)
    rows.append((label, value))
out.write_text("".join(f"{label}\t{value}\n" for label, value in rows))
PY

COUNT=$(wc -l < "$COLLECT" | tr -d ' ')
say "credential values discovered on this machine: $COUNT"
say "  $(cut -f1 "$COLLECT" | sed 's/:.*//' | sort | uniq -c | tr '\n' ' ')"
say ""

# ---------------------------------------------------------------------------
# 2. Are any of them inside the repo (working tree, index, or any commit)?
# ---------------------------------------------------------------------------
say "[1/3] working tree (excluding .git/ and node_modules/)"
while IFS=$'\t' read -r label value; do
  [ -n "$value" ] || continue
  hits=$(grep -rlF --exclude-dir=.git --exclude-dir=node_modules -- "$value" . 2>/dev/null | tr '\n' ' ')
  if [ -n "$hits" ]; then bad "$label appears in: $hits"; fi
done < "$COLLECT"
ok "swept $COUNT values across the working tree"

say "[2/3] index (staged content)"
staged=$(git diff --cached --name-only | tr '\n' ' ')
if [ -n "$staged" ]; then
  while IFS=$'\t' read -r label value; do
    [ -n "$value" ] || continue
    for f in $staged; do
      if git show ":$f" 2>/dev/null | grep -qF -- "$value"; then bad "$label appears in staged $f"; fi
    done
  done < "$COLLECT"
else
  ok "nothing staged"
fi

say "[3/3] full history (every commit, every blob)"
revs=$(git rev-list --all)
nrevs=$(printf '%s\n' "$revs" | grep -c .)
# shellcheck disable=SC2046
while IFS=$'\t' read -r label value; do
  [ -n "$value" ] || continue
  # $revs is intentionally split: one argument per revision
  # shellcheck disable=SC2086
  found=$(git grep -I -l -F -- "$value" $revs 2>/dev/null | cut -d: -f2- | sort -u | tr '\n' ' ')
  if [ -n "$found" ]; then bad "$label appears in history: $found"; fi
done < "$COLLECT"
ok "swept $nrevs commits"
say ""

# ---------------------------------------------------------------------------
# 3. Nothing dropped: every config still resolves its credentials
# ---------------------------------------------------------------------------
say "restore readiness"

if [ -L "$AGENT_DIR/auth.json" ] || [ -L "$AGENT_DIR/mcp-auth.json" ] || [ -L "$AGENT_DIR/antigravity-accounts.json" ]; then
  bad "a credential file is symlinked INTO the repo — it must stay a real file"
else
  ok "credential files are real files under $AGENT_DIR, not repo links"
fi

for f in auth.json secrets.env; do
  if [ -f "$AGENT_DIR/$f" ]; then
    mode=$(stat -f '%Lp' "$AGENT_DIR/$f" 2>/dev/null || stat -c '%a' "$AGENT_DIR/$f")
    [ "$mode" = "600" ] || warn "$f is mode $mode (want 600)"
  else
    warn "$f absent"
  fi
done

missing=$(python3 - "$AGENT_DIR" <<'PY'
import json, re, sys, pathlib
agent = pathlib.Path(sys.argv[1])
tpl = (agent / "mcp.json").read_text()
refs = set(re.findall(r"\$\{([A-Za-z0-9_]+)\}", tpl))
env = set(re.findall(r"\s*export\s+([A-Za-z0-9_]+)=", (agent / "secrets.env").read_text())) if (agent / "secrets.env").exists() else set()
print(" ".join(sorted(refs - env)))
PY
)
if [ -n "$missing" ]; then
  bad "mcp.json references \${$missing} but secrets.env does not define it"
else
  ok "every \${VAR} in mcp.json is defined in secrets.env"
fi

if [ -f "$AGENT_DIR/settings.json" ]; then
  defaults=$(python3 -c "
import json,sys
s=json.load(open('$AGENT_DIR/settings.json'))
print(s.get('defaultProvider',''), s.get('defaultModel',''))
" 2>/dev/null)
  # shellcheck disable=SC2086
  set -- $defaults
  if [ -n "${1:-}" ]; then
    check=$(pi auth check --provider "$1" ${2:+--model "$2"} --no-refresh 2>&1 | head -1)
    case "$check" in
      *ready*) ok "startup model $1/${2:-?} authenticated" ;;
      *)       bad "startup model $1/${2:-?} not usable: $check" ;;
    esac
  fi
fi

say ""
if [ "$fail" -eq 0 ]; then
  printf '\033[0;32maudit clean\033[0m — no credential in repo/index/history, nothing dropped\n'
else
  printf '\033[0;31maudit FAILED\033[0m — act on the LEAK lines above\n'
fi
exit $fail
