#!/usr/bin/env bash
# core.sh — Base features for all scripts

set -euo pipefail
IFS=$'\n\t'

# Colors (auto-disable if not terminal)
if [[ -t 2 ]]; then
    RED="\033[0;31m"; GREEN="\033[0;32m"; YELLOW="\033[1;33m"
    CYAN="\033[0;36m"; MAGENTA="\033[0;35m"; NC="\033[0m"
else
    RED=""; GREEN=""; YELLOW=""; CYAN=""; MAGENTA=""; NC=""
fi

timestamp() { date +"%Y-%m-%d %H:%M:%S"; }

log_info()    { echo -e "$(timestamp) ${CYAN}[INFO]${NC}    $*" >&2; }
log_warn()    { echo -e "$(timestamp) ${YELLOW}[WARN]${NC}    $*" >&2; }
log_error()   { echo -e "$(timestamp) ${RED}[ERROR]${NC}   $*" >&2; }
log_success() { echo -e "$(timestamp) ${GREEN}[SUCCESS]${NC} $*" >&2; }
log_debug()   { [[ "${VERBOSE:-false}" == true ]] && echo -e "$(timestamp) ${MAGENTA}[DEBUG]${NC}  $*" >&2; }

cleanup() { log_debug "Cleanup..."; }
trap cleanup EXIT INT TERM

require_cmd() { command -v "$1" >/dev/null || { log_error "Missing command: $1"; exit 127; }; }