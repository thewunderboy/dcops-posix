#!/bin/bash

# Load logging library first
source "${BASH_SOURCE%/*}/logging_lib.sh"

# Global error trap
set_error_trap() {
    trap 'catch_error $? $LINENO' ERR
}

catch_error() {
    local exit_code=$1
    local line_no=$2
    local command=$(sed -n "${line_no}p" "${BASH_SOURCE[1]}")
    
    log_error "Error occurred on line $line_no: $command"
    log_error "Exit code: $exit_code"
    
    # Call stack trace
    local frame=0
    while caller $frame; do
        ((frame++))
    done | awk '{printf "  at %s (%s:%d)\n", $2, $1, $3}' >&2
    
    exit $exit_code
}

assert() {
    local condition=$1
    local message=${2:-"Assertion failed"}
    
    if [ ! $condition ]; then
        log_error "$message"
        exit 1
    fi
}

check_exit_status() {
    local exit_code=$?
    local message=${1:-"Command failed with exit code $exit_code"}
    
    if [ $exit_code -ne 0 ]; then
        log_error "$message"
        exit $exit_code
    fi
}

exit_with_error() {
    local message=$1
    local exit_code=${2:-1}
    
    log_error "$message"
    exit $exit_code
}

try_catch() {
    local command="$@"
    
    $command 2>&1 | tee -a error.log
    local exit_code=${PIPESTATUS[0]}
    
    if [ $exit_code -ne 0 ]; then
        log_error "Command failed: $command"
        return $exit_code
    fi
    
    return 0
}