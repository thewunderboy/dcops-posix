#!/bin/bash

# Framework deployment script

# Load framework (minimal for deployment)
source "${BASH_SOURCE%/*}/logging_lib.sh"
source "${BASH_SOURCE%/*}/error_lib.sh"

FRAMEWORK_DIR="/opt/bash_framework"
BIN_DIR="/usr/local/bin"

install_framework() {
    log_info "Installing bash framework to $FRAMEWORK_DIR"
    
    create_dir "$FRAMEWORK_DIR"
    create_dir "$FRAMEWORK_DIR/libs"
    create_dir "$FRAMEWORK_DIR/modules"
    create_dir "$FRAMEWORK_DIR/config"
    create_dir "$FRAMEWORK_DIR/docs"
    
    # Copy files
    cp framework.sh "$FRAMEWORK_DIR/"
    cp libs/* "$FRAMEWORK_DIR/libs/"
    cp config/* "$FRAMEWORK_DIR/config/" 2>/dev/null || true
    
    # Create symlink for easy access
    ln -sf "$FRAMEWORK_DIR/framework.sh" "$BIN_DIR/bframework"
    
    log_info "Framework installed successfully"
}

verify_installation() {
    log_info "Verifying installation"
    
    if [ ! -f "$FRAMEWORK_DIR/framework.sh" ]; then
        exit_with_error "Framework installation failed"
    fi
    
    if ! "$FRAMEWORK_DIR/framework.sh" --version; then
        exit_with_error "Framework verification failed"
    fi
    
    log_info "Verification successful"
}

install_dependencies() {
    log_info "Installing dependencies"
    
    local deps=("jq" "curl" "bc")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        log_info "Installing missing dependencies: ${missing[*]}"
        
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y "${missing[@]}"
        elif command -v yum &> /dev/null; then
            sudo yum install -y "${missing[@]}"
        else
            log_warn "Cannot install dependencies - no supported package manager found"
        fi
    fi
    
    log_info "Dependencies installed"
}

main() {
    log_info "Starting framework deployment"
    
    install_dependencies
    install_framework
    verify_installation
    
    log_info "Framework deployment completed successfully"
}

main "$@"