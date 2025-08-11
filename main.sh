#!/usr/bin/env bash

# Load core + modules
source "$(dirname "$0")/lib/core.sh"
source "$(dirname "$0")/lib/file.sh"
source "$(dirname "$0")/lib/str.sh"

VERBOSE=false
while getopts ":f:v" opt; do
    case $opt in
        f) FILE=$OPTARG ;;
        v) VERBOSE=true ;;
        *) log_error "Invalid option"; exit 1 ;;
    esac
done

require_file "$FILE"
log_info "Processing file: $FILE"

while IFS= read -r line; do
    log_debug "Raw: $line"
    processed=$(trim "$line")
    log_info "Processed: $processed"
done < "$FILE"

log_success "All done!"