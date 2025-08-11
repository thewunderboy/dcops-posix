#!/bin/bash

# Load dependencies
source "${BASH_SOURCE%/*}/logging_lib.sh"
source "${BASH_SOURCE%/*}/error_lib.sh"

is_process_running() {
    local process_name=$1
    local user=${2:-}
    
    local pgrep_cmd="pgrep -f '$process_name'"
    if [ -n "$user" ]; then
        pgrep_cmd="sudo -u $user $pgrep_cmd"
    fi
    
    if eval "$pgrep_cmd" &>/dev/null; then
        log_debug "Process is running: $process_name"
        return 0
    else
        log_debug "Process not running: $process_name"
        return 1
    fi
}

start_process() {
    local process_cmd=$1
    local process_name=${2:-$1}
    local user=${3:-}
    local log_file=${4:-"/var/log/${process_name}.log"}
    
    if is_process_running "$process_name" "$user"; then
        log_warn "Process already running: $process_name"
        return 0
    fi
    
    log_info "Starting process: $process_name"
    
    local start_cmd="$process_cmd >> $log_file 2>&1 &"
    if [ -n "$user" ]; then
        start_cmd="sudo -u $user nohup $start_cmd"
    else
        start_cmd="nohup $start_cmd"
    fi
    
    eval "$start_cmd"
    check_exit_status "Failed to start process: $process_name"
    
    # Verify process started
    sleep 1
    if ! is_process_running "$process_name" "$user"; then
        exit_with_error "Process failed to start: $process_name"
    fi
    
    log_info "Process started successfully (PID: $(get_process_pid "$process_name"))"
}

stop_process() {
    local process_name=$1
    local user=${2:-}
    local timeout=${3:-30}
    local force=${4:-false}
    
    if ! is_process_running "$process_name" "$user"; then
        log_warn "Process not running: $process_name"
        return 0
    fi
    
    log_info "Stopping process: $process_name"
    
    local pids=$(get_process_pid "$process_name" "$user")
    local kill_cmd="kill"
    if [ -n "$user" ]; then
        kill_cmd="sudo -u $user $kill_cmd"
    fi
    
    # First try graceful SIGTERM
    $kill_cmd $pids
    check_exit_status "Failed to send SIGTERM to process: $process_name"
    
    # Wait for process to stop
    local waited=0
    while [ $waited -lt $timeout ] && is_process_running "$process_name" "$user"; do
        sleep 1
        ((waited++))
    done
    
    # Force kill if still running
    if is_process_running "$process_name" "$user"; then
        if [ "$force" = true ]; then
            log_warn "Process did not stop, forcing SIGKILL"
            $kill_cmd -9 $pids
            check_exit_status "Failed to send SIGKILL to process: $process_name"
        else
            exit_with_error "Process did not stop after $timeout seconds"
        fi
    fi
    
    log_info "Process stopped successfully: $process_name"
}

restart_process() {
    local process_cmd=$1
    local process_name=${2:-$1}
    local user=${3:-}
    local log_file=${4:-"/var/log/${process_name}.log"}
    
    stop_process "$process_name" "$user"
    start_process "$process_cmd" "$process_name" "$user" "$log_file"
}

monitor_process() {
    local process_name=$1
    local check_interval=${2:-60}
    local max_restarts=${3:-5}
    local user=${4:-}
    
    log_info "Starting process monitor for $process_name (check every $check_interval seconds)"
    
    local restarts=0
    while true; do
        if ! is_process_running "$process_name" "$user"; then
            log_error "Process $process_name is not running!"
            ((restarts++))
            
            if [ $restarts -gt $max_restarts ]; then
                exit_with_error "Max restarts ($max_restarts) reached for $process_name"
            fi
            
            log_info "Attempting to restart $process_name (attempt $restarts/$max_restarts)"
            start_process "$process_name" "$process_name" "$user"
        fi
        
        sleep $check_interval
    done
}

get_process_pid() {
    local process_name=$1
    local user=${2:-}
    
    local pgrep_cmd="pgrep -f '$process_name'"
    if [ -n "$user" ]; then
        pgrep_cmd="sudo -u $user $pgrep_cmd"
    fi
    
    eval "$pgrep_cmd" 2>/dev/null || echo ""
}

get_process_info() {
    local process_name=$1
    local user=${2:-}
    local pid=$(get_process_pid "$process_name" "$user")
    
    if [ -z "$pid" ]; then
        echo "Process not running: $process_name"
        return 1
    fi
    
    echo "Process Info for $process_name (PID: $pid):"
    ps -p "$pid" -o user,pid,ppid,%cpu,%mem,cmd
    echo -e "\nOpen files:"
    lsof -p "$pid" | head -n 10
    echo -e "\nMemory usage:"
    pmap -x "$pid" | tail -n +3
}