#!/usr/bin/env bash
#===============================================================================
# File        : bash_utils.sh
# Description : Common reusable functions & safe defaults for Bash scripts
# Author      : Your Name
# Version     : 1.0
#===============================================================================

# --- Enable Strict Mode in Calling Script ---
set -euo pipefail
IFS=$'\n\t'

# --- Detect if output is a terminal (for color support) ---
if [[ -t 2 ]]; then
    RED="\033[0;31m"
    GREEN="\033[0;32m"
    YELLOW="\033[1;33m"
    BLUE="\033[0;34m"
    MAGENTA="\033[0;35m"
    CYAN="\033[0;36m"
    NC="\033[0m"
else
    RED=""; GREEN=""; YELLOW=""; BLUE=""; MAGENTA=""; CYAN=""; NC=""
fi

# --- Timestamp Function ---
timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

# --- Logging Functions ---
log_info()    { echo -e "$(timestamp) ${CYAN}[INFO]${NC}    $*" >&2; }
log_warn()    { echo -e "$(timestamp) ${YELLOW}[WARN]${NC}    $*" >&2; }
log_error()   { echo -e "$(timestamp) ${RED}[ERROR]${NC}   $*" >&2; }
log_success() { echo -e "$(timestamp) ${GREEN}[SUCCESS]${NC} $*" >&2; }
log_debug()   { [[ "${VERBOSE:-false}" == true ]] && echo -e "$(timestamp) ${MAGENTA}[DEBUG]${NC}  $*" >&2; }

# --- Cleanup & Trap ---
cleanup() {
    log_debug "Running cleanup..."
    # Add temp file deletion, process kill, etc.
}
trap cleanup EXIT INT TERM

# --- Dependency Checker ---
require_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        log_error "Required command '$1' not found."
        exit 127
    }
}

# --- Safe File Check ---
require_file() {
    [[ -f "$1" ]] || {
        log_error "File '$1' not found."
        exit 1
    }
}

# --- Enable Verbose Mode ---
enable_verbose() {
    VERBOSE=true
    log_debug "Verbose mode enabled"
}

# --- Enable Dry-Run Mode ---
enable_dry_run() {
    DRY_RUN=true
    log_warn "Dry run mode enabled — no changes will be made."
}

# --- Run a Command Safely ---
run_cmd() {
    if [[ "${DRY_RUN:-false}" == true ]]; then
        log_info "[DRY RUN] $*"
    else
        "$@"
    fi
}