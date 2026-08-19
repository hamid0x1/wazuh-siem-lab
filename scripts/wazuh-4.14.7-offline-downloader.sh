#!/usr/bin/env bash

# ============================================================
# Wazuh 4.14.7 Offline Package Downloader
# Portable — works on any bash-capable Unix-like environment
# (Linux, macOS, WSL, Termux via its exec-path shim, etc.)
#
# IMPORTANT:
# - Runs entirely in the CURRENT directory.
# - Does NOT create a working directory.
# - Does NOT execute wazuh-install.sh.
# - Does NOT execute wazuh-certs-tool.sh.
# - Does NOT use apt/systemd.
# - Downloads fixed Wazuh 4.14.7 packages.
# ============================================================

set -e

WAZUH_VERSION="4.14.7"
FILEBEAT_VERSION="7.10.2-2"

BASE="https://packages.wazuh.com"

echo "======================================================"
echo " Wazuh ${WAZUH_VERSION} Offline Package Downloader"
echo "======================================================"
echo
echo "Current directory:"
pwd
echo

# ------------------------------------------------------------
# Download helper
# ------------------------------------------------------------

download() {
    URL="$1"
    FILE="$2"

    echo "------------------------------------------------------"
    echo "Downloading:"
    echo "$FILE"
    echo
    echo "URL:"
    echo "$URL"
    echo

    curl -fL \
        --retry 3 \
        --connect-timeout 20 \
        --continue-at - \
        -o "$FILE" \
        "$URL"

    if [ ! -s "$FILE" ]; then
        echo
        echo "ERROR: $FILE was not downloaded correctly."
        exit 1
    fi

    echo
    echo "OK: $FILE"
    echo
}

# ------------------------------------------------------------
# 1. Wazuh installation assistant
# ------------------------------------------------------------

echo "=== [1/7] Wazuh installation assistant ==="

download \
    "$BASE/4.14/wazuh-install.sh" \
    "wazuh-install.sh"

chmod 744 wazuh-install.sh

echo "IMPORTANT: wazuh-install.sh was downloaded ONLY."
echo "It will NOT be executed by this script."
echo

# ------------------------------------------------------------
# 2. Certificate generation tool
# ------------------------------------------------------------

echo "=== [2/7] Wazuh certificate tool ==="

download \
    "$BASE/4.14/wazuh-certs-tool.sh" \
    "wazuh-certs-tool.sh"

chmod 744 wazuh-certs-tool.sh

echo

# ------------------------------------------------------------
# 3. Certificate configuration
# ------------------------------------------------------------

echo "=== [3/7] Wazuh certificate configuration ==="

download \
    "$BASE/4.14/config.yml" \
    "config.yml"

echo "config.yml downloaded unchanged."
echo "We will configure the actual VM IP later."
echo

# ------------------------------------------------------------
# 4. Wazuh Indexer
# ------------------------------------------------------------

echo "=== [4/7] Wazuh Indexer ==="

IDX="wazuh-indexer_4.14.7-1_amd64.deb"

download \
    "$BASE/4.x/apt/pool/main/w/wazuh-indexer/$IDX" \
    "$IDX"

# ------------------------------------------------------------
# 5. Wazuh Manager
# ------------------------------------------------------------

echo "=== [5/7] Wazuh Manager ==="

MGR="wazuh-manager_4.14.7-1_amd64.deb"

download \
    "$BASE/4.x/apt/pool/main/w/wazuh-manager/$MGR" \
    "$MGR"

# ------------------------------------------------------------
# 6. Wazuh Dashboard + Filebeat
# ------------------------------------------------------------

echo "=== [6/7] Wazuh Dashboard ==="

DSH="wazuh-dashboard_4.14.7-1_amd64.deb"

download \
    "$BASE/4.x/apt/pool/main/w/wazuh-dashboard/$DSH" \
    "$DSH"

echo "=== [6b/7] Filebeat ==="

FB="filebeat_${FILEBEAT_VERSION}_amd64.deb"

download \
    "$BASE/4.x/apt/pool/main/f/filebeat/$FB" \
    "$FB"

# ------------------------------------------------------------
# 7. Windows Agent
# ------------------------------------------------------------

echo "=== [7/7] Windows Wazuh Agent ==="

AGENT="wazuh-agent-4.14.7-1.msi"

download \
    "$BASE/4.x/windows/$AGENT" \
    "$AGENT"

# ------------------------------------------------------------
# Bundle everything
# ------------------------------------------------------------

DATE_TAG="$(date +%Y%m%d)"
BUNDLE="wazuh-ready-${DATE_TAG}.tar.gz"

echo
echo "======================================================"
echo " Creating offline bundle"
echo "======================================================"
echo

tar -czf "$BUNDLE" \
    wazuh-install.sh \
    wazuh-certs-tool.sh \
    config.yml \
    "$IDX" \
    "$MGR" \
    "$DSH" \
    "$FB" \
    "$AGENT"

echo
echo "======================================================"
echo " SUCCESS"
echo "======================================================"
echo
echo "Bundle:"
echo
echo "  $(pwd)/$BUNDLE"
echo
echo "Files inside bundle:"
echo

tar -tzf "$BUNDLE"

echo
echo "======================================================"
echo " IMPORTANT"
echo "======================================================"
echo
echo "This script did NOT install Wazuh."
echo "wazuh-install.sh was NOT executed."
echo "wazuh-certs-tool.sh was NOT executed."
echo
echo "Transfer this bundle to your target Ubuntu VM/host."
echo
echo "On the target:"
echo
echo "  tar -xzf $BUNDLE"
echo
echo "Then perform the actual Wazuh installation there."
echo
echo "======================================================"
