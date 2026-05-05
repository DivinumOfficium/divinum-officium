#!/bin/bash
# warm-ordo-cache.sh
# Pre-generates the full-year Ordo (Totus) for each rubrical version.
# Run nightly via cron to avoid 504 timeouts on live requests.
#
# Usage:
#   ./warm-ordo-cache.sh              # uses BASE_URL from environment or defaults to localhost
#   BASE_URL=https://www.divinumofficium.com ./warm-ordo-cache.sh   # run against production

set -euo pipefail

# --- Configuration -----------------------------------------------------------

BASE_URL="${BASE_URL:-http://localhost:8080}"
CACHE_DIR="${CACHE_DIR:-/var/www/web/ordo-cache}"
YEAR="${YEAR:-$(date +%Y)}"
LOG_PREFIX="[warm-ordo-cache]"

# All canonical rubrical versions from data.txt
VERSIONS=(
    "Tridentine - 1570"
    "Tridentine - 1888"
    "Divino Afflatu - 1939"
    "Divino Afflatu - 1954"
    "Reduced - 1955"
    "Rubrics 1960 - 1960"
    "Rubrics 1960 - 2020 USA"
    "Monastic Tridentinum 1617"
    "Monastic Divino 1930"
    "Monastic - 1963"
    "Ordo Praedicatorum - 1962"
)

# -----------------------------------------------------------------------------

mkdir -p "$CACHE_DIR"

echo "$LOG_PREFIX Starting ordo cache warm for year $YEAR at $(date)"
echo "$LOG_PREFIX Base URL: $BASE_URL"
echo "$LOG_PREFIX Cache dir: $CACHE_DIR"
echo ""

SUCCESS=0
FAILURE=0

for VERSION in "${VERSIONS[@]}"; do
    # Build a filesystem-safe cache key from the version name
    # e.g. "Rubrics 1960 - 1960" -> "rubrics-1960---1960"
    SAFE_KEY=$(echo "$VERSION" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
    CACHE_FILE="$CACHE_DIR/${YEAR}-${SAFE_KEY}.html"

    # URL-encode the version string (spaces -> %20, etc.)
    ENCODED_VERSION=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$VERSION'))")

    URL="${BASE_URL}/cgi-bin/horas/kalendar.pl?kmonth=14&kyear=${YEAR}&version=${ENCODED_VERSION}"

    echo "$LOG_PREFIX Warming: $VERSION"
    echo "$LOG_PREFIX   -> $CACHE_FILE"

    HTTP_CODE=$(wget \
        --quiet \
        --timeout=300 \
        --tries=1 \
        --server-response \
        --output-document="$CACHE_FILE.tmp" \
        "$URL" 2>&1 | grep "HTTP/" | tail -1 | awk '{print $2}')

    if [ -z "$HTTP_CODE" ]; then
        # wget doesn't always capture code this way - check if file has content
        if [ -s "$CACHE_FILE.tmp" ]; then
            HTTP_CODE="200"
        else
            HTTP_CODE="000"
        fi
    fi

    if [ "$HTTP_CODE" = "200" ] && [ -s "$CACHE_FILE.tmp" ]; then
        mv "$CACHE_FILE.tmp" "$CACHE_FILE"
        SIZE=$(wc -c < "$CACHE_FILE")
        echo "$LOG_PREFIX   OK ($SIZE bytes)"
        SUCCESS=$((SUCCESS + 1))
    else
        rm -f "$CACHE_FILE.tmp"
        echo "$LOG_PREFIX   FAILED (HTTP $HTTP_CODE) - skipping, old cache preserved if present"
        FAILURE=$((FAILURE + 1))
    fi

    echo ""
done

echo "$LOG_PREFIX Done at $(date). Success: $SUCCESS  Failed: $FAILURE"

if [ $FAILURE -gt 0 ]; then
    exit 1
fi
exit 0
