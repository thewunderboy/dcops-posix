#!/bin/bash

# Load dependencies
source "${BASH_SOURCE%/*}/logging_lib.sh"
source "${BASH_SOURCE%/*}/error_lib.sh"

check_connection() {
    local host=${1:-"google.com"}
    local ping_count=${2:-3}
    local timeout=${3:-2}
    
    log_info "Checking network connection to $host"
    
    if ping -c "$ping_count" -W "$timeout" "$host" &> /dev/null; then
        log_info "Network connection to $host is active"
        return 0
    else
        log_warn "Cannot reach $host"
        return 1
    fi
}

download_file() {
    local url=$1
    local output_file=$2
    local checksum=$3
    local checksum_type=${4:-"sha256"}
    
    log_info "Downloading $url to $output_file"
    
    # Use curl if available, fall back to wget
    if command -v curl &> /dev/null; then
        curl -L -o "$output_file" "$url" --progress-bar
    elif command -v wget &> /dev/null; then
        wget -O "$output_file" "$url"
    else
        exit_with_error "Neither curl nor wget is available"
    fi
    
    check_exit_status "Failed to download $url"
    
    if [ -n "$checksum" ]; then
        verify_checksum "$output_file" "$checksum" "$checksum_type"
    fi
    
    log_info "Download completed successfully"
}

verify_checksum() {
    local file=$1
    local expected_checksum=$2
    local checksum_type=$3
    
    log_info "Verifying $checksum_type checksum for $file"
    
    case $checksum_type in
        sha256)
            actual_checksum=$(sha256sum "$file" | awk '{print $1}')
            ;;
        md5)
            actual_checksum=$(md5sum "$file" | awk '{print $1}')
            ;;
        sha1)
            actual_checksum=$(sha1sum "$file" | awk '{print $1}')
            ;;
        *)
            exit_with_error "Unsupported checksum type: $checksum_type"
            ;;
    esac
    
    if [ "$actual_checksum" != "$expected_checksum" ]; then
        exit_with_error "Checksum verification failed for $file (Expected: $expected_checksum, Actual: $actual_checksum)"
    fi
    
    log_info "Checksum verified successfully"
}

test_port() {
    local host=$1
    local port=$2
    local timeout=${3:-5}
    
    log_info "Testing connection to $host:$port"
    
    if command -v nc &> /dev/null; then
        if nc -z -w "$timeout" "$host" "$port"; then
            log_info "Port $port is open on $host"
            return 0
        else
            log_warn "Port $port is closed or unreachable on $host"
            return 1
        fi
    elif command -v telnet &> /dev/null; then
        # Fallback using telnet (less reliable)
        if (echo > "/dev/tcp/$host/$port") &> /dev/null; then
            log_info "Port $port is open on $host"
            return 0
        else
            log_warn "Port $port is closed or unreachable on $host"
            return 1
        fi
    else
        exit_with_error "Neither netcat (nc) nor telnet is available for port testing"
    fi
}

get_public_ip() {
    local service=${1:-"ifconfig.co"}
    
    log_info "Getting public IP address using $service"
    
    local ip
    case $service in
        "ifconfig.co")
            ip=$(curl -s ifconfig.co)
            ;;
        "ipinfo.io")
            ip=$(curl -s ipinfo.io/ip)
            ;;
        "api.ipify.org")
            ip=$(curl -s api.ipify.org)
            ;;
        *)
            exit_with_error "Unknown IP service: $service"
            ;;
    esac
    
    check_exit_status "Failed to get public IP from $service"
    
    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$ip"
        log_info "Public IP address: $ip"
        return 0
    else
        exit_with_error "Invalid IP address received: $ip"
    fi
}