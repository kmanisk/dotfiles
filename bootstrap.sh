#!/usr/bin/env bash
# Forwarder to canonical bootstrap script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "$SCRIPT_DIR/scripts/bootstrap/linux.sh" "$@"
