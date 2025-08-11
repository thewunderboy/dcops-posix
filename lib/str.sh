#!/usr/bin/env bash
# str.sh — String helpers

trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}" # leading
    var="${var%"${var##*[![:space:]]}"}" # trailing
    echo "$var"
}

to_upper() { echo "$*" | tr '[:lower:]' '[:upper:]'; }
to_lower() { echo "$*" | tr '[:upper:]' '[:lower:]'; }