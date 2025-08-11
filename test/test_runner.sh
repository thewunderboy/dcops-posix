#!/bin/bash

# Test runner for the bash framework

# Load framework
source "${BASH_SOURCE%/*}/../framework.sh"

# Test directory
TEST_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TEST_LOG="$TEST_DIR/test_results.log"

# Initialize test system
init_tests() {
    > "$TEST_LOG"
    load_module "test"
    log_info "Starting test suite"
}

# Test case template
run_test() {
    local test_name=$1
    local test_func=$2
    
    log_info "Running test: $test_name"
    
    if $test_func; then
        log_info "PASS: $test_name"
        echo "PASS: $test_name" >> "$TEST_LOG"
        return 0
    else
        log_error "FAIL: $test_name"
        echo "FAIL: $test_name" >> "$TEST_LOG"
        return 1
    fi
}

# Example test cases
test_logging_info() {
    local output=$(log_info "Test message" 2>&1)
    [[ "$output" =~ "[INFO]" ]] && [[ "$output" =~ "Test message" ]]
}

test_error_handling() {
    (exit_with_error "Test error" 2>/dev/null)
    [ $? -eq 1 ]
}

# Run all tests
run_all_tests() {
    local passed=0
    local failed=0
    
    init_tests
    
    # Add tests here
    run_test "logging_info_level" test_logging_info && ((passed++)) || ((failed++))
    run_test "error_handling" test_error_handling && ((passed++)) || ((failed++))
    
    # Print summary
    log_info "Test summary: $passed passed, $failed failed"
    [ $failed -eq 0 ]
}

# Main execution
if run_all_tests; then
    exit 0
else
    exit 1
fi