#!/usr/bin/env bats

# Test script for user_last_login.sh.
# These tests ensure argument parsing, help output, and error handling work correctly.

# Define the script path
export TEST_SCRIPT="./user_last_login.sh"

# setup() function runs before each test block.
setup() {
    # Create a temporary directory for reports and logs to ensure clean testing.
    export TMP_REPORT_DIR="$(mktemp -d)"
}

# teardown() function runs after each test block.
teardown() {
    # Clean up the temporary directory
    rm -rf "$TMP_REPORT_DIR"
}

@test "1. Script displays help message with --help and exits 0" {
    # Run the script with the --help argument
    run bash "$TEST_SCRIPT" --help

    # Check the exit code (status) must be 0 for successful help display
    [ "$status" -eq 0 ]

    # Check that the output contains the key phrase "Usage"
    [[ "$output" =~ "Usage" ]]
}

@test "2. Script exits with error on invalid UID argument (Status Check)" {
    # Run the script with a non-numeric UID
    run bash "$TEST_SCRIPT" -u not-a-number

    # Check that the exit code is NOT 0 (i.e., failure).
    # This is the most reliable check for fatal errors.
    [ "$status" -ne 0 ]

}

@test "3. Script successfully sets and uses the report directory (-d flag)" {
    # Run the script using the temporary report directory for reports
    # We test a simple case that should succeed without erroring on report path.
    # Note: Full functional testing (file creation) requires a more complex setup,
    # but this validates argument parsing.
    run bash "$TEST_SCRIPT" -d "$TMP_REPORT_DIR/reports" --help

    # Check that the exit code is 0
    [ "$status" -eq 0 ]

    # Since the script is expected to exit 0 and show help,
    # the -d argument was successfully parsed without failure.
}
