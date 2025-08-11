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


#!/bin/bash

# Framework configuration
FRAMEWORK_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
LIB_DIR="${FRAMEWORK_DIR}/libs"
CONFIG_DIR="${FRAMEWORK_DIR}/config"
MODULE_DIR="${FRAMEWORK_DIR}/modules"

# Framework metadata
declare -g -A FRAMEWORK_METADATA=(
    ["VERSION"]="1.1.0"
    ["AUTHOR"]="Your Name"
    ["REQUIRED_BASH_VERSION"]="4.2"
)

# Load core libraries automatically
for core_lib in logging error config filesystem; do
    if [ -f "${LIB_DIR}/${core_lib}_lib.sh" ]; then
        source "${LIB_DIR}/${core_lib}_lib.sh"
    else
        echo "ERROR: Missing core library: ${core_lib}_lib.sh" >&2
        exit 1
    fi
done

# Initialize framework
initialize_framework() {
    check_bash_version
    set_error_trap
    load_config "${CONFIG_DIR}/framework.conf"
    log_info "Initialized ${FRAMEWORK_METADATA["NAME"]} v${FRAMEWORK_METADATA["VERSION"]}"
}

# Check minimum Bash version
check_bash_version() {
    local required=${FRAMEWORK_METADATA["REQUIRED_BASH_VERSION"]}
    local current=${BASH_VERSION%%[^0-9.]*}
    
    if (( $(echo "$current < $required" | bc -l) )); then
        exit_with_error "Bash version $required or higher is required (current: $current)"
    fi
}

# Enhanced module loading
load_module() {
    local module=$1
    local module_path
    
    # Check in multiple locations
    for dir in "$LIB_DIR" "$MODULE_DIR"; do
        module_path="${dir}/${module}_lib.sh"
        if [ -f "$module_path" ]; then
            log_info "Loading module: $module"
            source "$module_path"
            return 0
        fi
    done
    
    log_error "Module not found: $module"
    return 1
}

# Auto-load modules from configuration
autoload_modules() {
    local modules=($(get_config_value "AUTO_LOAD_MODULES" "" | tr ',' ' '))
    
    for module in "${modules[@]}"; do
        module=$(echo "$module" | xargs) # Trim whitespace
        if [ -n "$module" ]; then
            load_module "$module" || exit_with_error "Failed to load required module: $module"
        fi
    done
}

# Main entry point
main() {
    initialize_framework
    autoload_modules
    
    # Your application logic here
    log_info "Framework initialized successfully"
    
    # Example: Load additional modules as needed
    # load_module "api"
    # load_module "database"
}

main "$@"