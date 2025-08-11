#!/usr/bin/env bash
# file.sh — File and path helpers

require_file() {
    [[ -f "$1" ]] || { log_error "File not found: $1"; exit 1; }
}

require_dir() {
    [[ -d "$1" ]] || { log_error "Directory not found: $1"; exit 1; }
}

safe_copy() {
    local src=$1 dest=$2
    if [[ -e "$dest" ]]; then
        log_warn "Destination exists, not overwriting: $dest"
    else
        cp "$src" "$dest"
        log_success "Copied $src to $dest"
    fi
}