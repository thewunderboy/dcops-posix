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


#!/bin/bash

# Load dependencies
source "${BASH_SOURCE%/*}/logging_lib.sh"
source "${BASH_SOURCE%/*}/error_lib.sh"

file_exists() {
    local file=$1
    
    if [ -f "$file" ]; then
        log_debug "File exists: $file"
        return 0
    else
        log_debug "File not found: $file"
        return 1
    fi
}

dir_exists() {
    local dir=$1
    
    if [ -d "$dir" ]; then
        log_debug "Directory exists: $dir"
        return 0
    else
        log_debug "Directory not found: $dir"
        return 1
    fi
}

create_dir() {
    local dir=$1
    local mode=${2:-0755}
    
    if dir_exists "$dir"; then
        log_warn "Directory already exists: $dir"
        return 0
    fi
    
    log_info "Creating directory: $dir with mode $mode"
    mkdir -p -m "$mode" "$dir"
    check_exit_status "Failed to create directory: $dir"
    
    log_info "Directory created successfully"
}

safe_remove() {
    local target=$1
    local backup_dir=${2:-"./backup"}
    
    if [ ! -e "$target" ]; then
        log_warn "Target not found, nothing to remove: $target"
        return 0
    fi
    
    # Create backup directory if needed
    create_dir "$backup_dir"
    
    # Generate backup filename with timestamp
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="${backup_dir}/$(basename "$target")_${timestamp}"
    
    log_info "Backing up $target to $backup_file"
    cp -r "$target" "$backup_file"
    check_exit_status "Failed to create backup of $target"
    
    log_info "Removing target: $target"
    rm -rf "$target"
    check_exit_status "Failed to remove $target"
    
    log_info "Successfully removed and backed up $target"
}

backup_file() {
    local source_file=$1
    local backup_dir=${2:-"./backup"}
    local max_backups=${3:-5}
    
    if ! file_exists "$source_file"; then
        log_error "Source file not found: $source_file"
        return 1
    fi
    
    create_dir "$backup_dir"
    
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="${backup_dir}/$(basename "$source_file")_${timestamp}"
    
    log_info "Creating backup of $source_file at $backup_file"
    cp "$source_file" "$backup_file"
    check_exit_status "Failed to create backup"
    
    # Rotate backups
    local backups=("$backup_dir"/"$(basename "$source_file")"_*)
    if [ ${#backups[@]} -gt $max_backups ]; then
        log_info "Rotating backups (keeping $max_backups)"
        # Sort by date and remove oldest
        ls -t "$backup_dir"/"$(basename "$source_file")"_* | tail -n +$(($max_backups + 1)) | xargs rm -f
    fi
    
    log_info "Backup completed successfully"
}