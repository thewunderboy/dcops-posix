#!/bin/bash

# Framework main loader

# Framework version
FRAMEWORK_VERSION="1.0.0"

# Base directory
FRAMEWORK_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
LIB_DIR="${FRAMEWORK_DIR}/libs"

# Load core libraries
source "${LIB_DIR}/logging_lib.sh"
source "${LIB_DIR}/error_lib.sh"
source "${LIB_DIR}/config_lib.sh"
source "${LIB_DIR}/filesystem_lib.sh"

# Initialize framework
initialize_framework() {
    log_info "Initializing Bash Framework v${FRAMEWORK_VERSION}"
    set_error_trap
    load_config
    
    # Load additional modules
    for module in "$@"; do
        load_module "$module"
    done
}

load_module() {
    local module=$1
    local module_file="${LIB_DIR}/${module}_lib.sh"
    
    if file_exists "$module_file"; then
        log_info "Loading module: $module"
        source "$module_file"
    else
        log_error "Module not found: $module"
        return 1
    fi
}

# Main function
main() {
    initialize_framework "$@"
    
    # Your script logic here
    log_info "Framework initialized successfully"
    
    # Example usage:
    # create_dir "/tmp/example_dir"
    # backup_file "/etc/hosts"
}

main "$@"