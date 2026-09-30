#!/usr/bin/env bash
#
# pi-secrets-scan.sh — guard the pi credential boundary in this repo.
#
# Why: ~/.pi/agent mixes shareable config (settings.json, models.json, extensions/)
# with real credentials (auth.json API keys, mcp-auth.json / antigravity-accounts.json
# OAuth tokens). The shareable entries are symlinked into this repo, so "back up my pi
# config" is one `git add -A` away from publishing a key.
#
# Usage:
#   scripts/pi-secrets-scan.sh              scan every file physically under pi/
#   scripts/pi-secrets-scan.sh <path>...    scan specific files/dirs (pre-copy gate)
#   scripts/pi-secrets-scan.sh --all        scan every tracked file in the repo
#
# A path fails when (a) its basename is a reserved credential filename, or (b) its
# content matches a credential shape. `${VAR}` references and REPLACE_ME placeholders
# do not match, so committed templates pass.
#
# Exit: 0 clean | 1 findings | 2 usage error

set -uo pipefail

cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" || exit 2

DENY_NAMES=(
    auth.json
    mcp-auth.json
    antigravity-accounts.json
    secrets.json
    secrets.env
    id_rsa
    id_ed25519
    '*.pem'
    '*.key'
)

# Credential-shaped content. Placeholders (REPLACE_ME, sk-your-..., ${VAR}) are excluded.
PATTERNS=(
    'sk-[A-Za-z0-9_-]{16,}'
    'ya29\.[A-Za-z0-9_-]{10,}'
    '"1//[A-Za-z0-9_-]{20,}"'
    'AQ\.[A-Za-z0-9_-]{16,}'
    'cfast_[A-Za-z0-9]{10,}'
    'ghp_[A-Za-z0-9]{20,}'
    'github_pat_[A-Za-z0-9_]{20,}'
    'AKIA[0-9A-Z]{12,}'
    'xox[baprs]-[A-Za-z0-9-]{10,}'
    '-----BEGIN [A-Z ]*PRIVATE KEY-----'
    '"(api_?[Kk]ey|apiKey|token|secret|client_secret|access_token|refresh_token)"[[:space:]]*:[[:space:]]*"[^$!"{[:space:]]{8,}'
)

# Lines carrying this marker are treated as reviewed placeholders, not secrets.
ALLOW_MARKER='allowsecret'

status=0
scanned=0

list_mode="pi"
targets=()
for arg in "$@"; do
    case "$arg" in
        --all) list_mode="all" ;;
        -h|--help) sed -n '2,22p' "$0"; exit 0 ;;
        --*) echo "unknown option: $arg" >&2; exit 2 ;;
        *) targets+=("$arg"); list_mode="explicit" ;;
    esac
done

candidates() {
    case "$list_mode" in
        pi) find pi -type f -not -path '*/node_modules/*' 2>/dev/null ;;
        all) git ls-files ;;
        explicit)
            for t in "${targets[@]}"; do
                if [ -d "$t" ]; then
                    find "$t" -type f -not -path '*/node_modules/*'
                elif [ -e "$t" ]; then
                    printf '%s\n' "$t"
                else
                    echo "not found: $t" >&2
                    status=1
                fi
            done
            ;;
    esac
}

mask() {
    # Never echo a credential verbatim into a terminal or CI log.
    sed -E 's/[A-Za-z0-9_+\/-]{12,}/<masked>/g'
}

report() {
    printf '\033[0;31mFAIL\033[0m %s\n' "$1"
    shift
    for blob in "$@"; do
        while IFS= read -r line; do
            [ -n "$line" ] || continue
            printf '       %s\n' "${line:0:160}" | mask
        done <<< "$blob"
    done
    status=1
}

while IFS= read -r file; do
    [ -n "$file" ] || continue
    [ -f "$file" ] || continue
    scanned=$((scanned + 1))
    base="$(basename "$file")"

    for denied in "${DENY_NAMES[@]}"; do
        # shellcheck disable=SC2053
        if [[ $base == $denied ]]; then
            report "$file — credential filename is never allowed in the repo"
            continue 2
        fi
    done

    for pattern in "${PATTERNS[@]}"; do
        hits="$(grep -nE -- "$pattern" "$file" 2>/dev/null | grep -v -- "$ALLOW_MARKER" | head -3)"
        [ -z "$hits" ] && continue
        report "$file — matches /$pattern/" "$hits"
    done
done < <(candidates)

if [ "$status" -eq 0 ]; then
    printf '\033[0;32mOK\033[0m no credential-shaped content (%s files scanned)\n' "$scanned"
else
    cat >&2 <<'EOF'

pi secret guard found credential material. Move it out of the repo:
  - pi provider keys -> ~/.pi/agent/auth.json (pi's own store, never linked here)
  - MCP / shell creds -> ~/.pi/agent/secrets.env (mode 600, sourced from .zshrc)
  - committed files may only reference them as ${NAME} or !command
  - reviewed placeholders may carry an `allowsecret` marker on the same line
EOF
fi
exit $status
