#!/usr/bin/env bash
# auto_input.sh - Handle input from positional args, file, or interactive prompt automatically

# -------------------------
# Functions
# -------------------------

# Handle positional parameters
handle_positional() {
    echo "=== Handling Positional Parameters ==="
    for arg in "$@"; do
        echo "Positional: $arg"
    done
}

# Handle file input
handle_file() {
    local file="$1"
    echo "=== Handling File Input ==="
    while IFS= read -r line; do
        echo "From file: $line"
    done < "$file"
}

# Handle interactive input
handle_interactive() {
    echo "=== Handling Interactive Input ==="
    echo "Enter values (blank line to stop):"
    while true; do
        read -rp "> " input
        [[ -z "$input" ]] && break
        echo "Interactive: $input"
    done
}

# Show usage/help
usage() {
    cat <<EOF
Usage: $0 [ARGS] | [filename]

Examples:
  $0 apple banana cherry   # Positional parameters
  $0 myfile.txt            # File input (if file exists)
  $0                       # Interactive mode
EOF
}

# -------------------------
# Main Logic
# -------------------------
if [[ $# -eq 0 ]]; then
    # No args → interactive mode
    handle_interactive
elif [[ $# -eq 1 && -f "$1" ]]; then
    # Single arg and it's a file
    handle_file "$1"
else
    # Treat as positional args
    handle_positional "$@"
fi