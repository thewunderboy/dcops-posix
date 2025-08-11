#!/bin/bash

# Logging levels
LOG_LEVEL_ERROR=1
LOG_LEVEL_WARN=2
LOG_LEVEL_INFO=3
LOG_LEVEL_DEBUG=4

# Default log level
LOG_LEVEL=${LOG_LEVEL:-$LOG_LEVEL_INFO}

# Colors for terminal output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    local level=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    case $level in
        ERROR)
            if [ $LOG_LEVEL -ge $LOG_LEVEL_ERROR ]; then
                echo -e "${RED}[ERROR]${NC} $timestamp - $message" >&2
            fi
            ;;
        WARN)
            if [ $LOG_LEVEL -ge $LOG_LEVEL_WARN ]; then
                echo -e "${YELLOW}[WARN]${NC} $timestamp - $message" >&2
            fi
            ;;
        INFO)
            if [ $LOG_LEVEL -ge $LOG_LEVEL_INFO ]; then
                echo -e "${GREEN}[INFO]${NC} $timestamp - $message"
            fi
            ;;
        DEBUG)
            if [ $LOG_LEVEL -ge $LOG_LEVEL_DEBUG ]; then
                echo -e "${BLUE}[DEBUG]${NC} $timestamp - $message"
            fi
            ;;
    esac
}

log_info() {
    log "INFO" "$1"
}

log_warn() {
    log "WARN" "$1"
}

log_error() {
    log "ERROR" "$1"
}

log_debug() {
    log "DEBUG" "$1"
}

set_log_level() {
    case $1 in
        ERROR) LOG_LEVEL=$LOG_LEVEL_ERROR ;;
        WARN) LOG_LEVEL=$LOG_LEVEL_WARN ;;
        INFO) LOG_LEVEL=$LOG_LEVEL_INFO ;;
        DEBUG) LOG_LEVEL=$LOG_LEVEL_DEBUG ;;
        *) log_error "Invalid log level: $1" ;;
    esac
}

log_to_file() {
    local level=$1
    local message=$2
    local file=${3:-"script.log"}
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    if [ ! -f "$file" ]; then
        touch "$file"
    fi
    
    echo "[$level] $timestamp - $message" >> "$file"
}