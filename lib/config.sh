#!/bin/bash

# Load dependencies
source "${BASH_SOURCE%/*}/logging_lib.sh"

declare -A CONFIG

load_config() {
    local config_file=${1:-"config.conf"}
    
    if [ ! -f "$config_file" ]; then
        log_error "Configuration file not found: $config_file"
        return 1
    fi
    
    log_info "Loading configuration from: $config_file"
    
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ $key =~ ^# ]] || [[ -z $key ]] && continue
        
        # Remove quotes and extra spaces
        key=$(echo "$key" | tr -d '[:space:]')
        value=$(echo "$value" | sed -e 's/^["'\'']//' -e 's/["'\'']$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        
        CONFIG["$key"]="$value"
        log_debug "Loaded config: $key=${CONFIG[$key]}"
    done < "$config_file"
    
    log_info "Configuration loaded successfully"
}

get_config_value() {
    local key=$1
    local default_value=${2:-}
    
    if [[ -z "${CONFIG[$key]+x}" ]]; then
        log_warn "Configuration key not found: $key (returning default: $default_value)"
        echo "$default_value"
    else
        echo "${CONFIG[$key]}"
    fi
}

validate_config() {
    local required_keys=("$@")
    local missing_keys=()
    local valid=true
    
    for key in "${required_keys[@]}"; do
        if [[ -z "${CONFIG[$key]+x}" || -z "${CONFIG[$key]}" ]]; then
            missing_keys+=("$key")
            valid=false
        fi
    done
    
    if [ "$valid" = false ]; then
        log_error "Missing required configuration keys: ${missing_keys[*]}"
        return 1
    fi
    
    return 0
}

set_default_config() {
    local key=$1
    local value=$2
    
    if [[ -z "${CONFIG[$key]+x}" ]]; then
        CONFIG["$key"]="$value"
        log_debug "Set default config: $key=$value"
    fi
}

write_config() {
    local config_file=${1:-"config.conf"}
    
    log_info "Writing configuration to: $config_file"
    
    # Backup existing config
    if [ -f "$config_file" ]; then
        cp "$config_file" "${config_file}.bak"
    fi
    
    # Write new config
    > "$config_file"
    for key in "${!CONFIG[@]}"; do
        echo "$key=\"${CONFIG[$key]}\"" >> "$config_file"
    done
    
    log_info "Configuration saved successfully"
}