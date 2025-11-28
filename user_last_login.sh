#!/usr/bin/env bash
set -euo pipefail


# GLOBAL SETTINGS
DEFAULT_MIN_UID=1000
MIN_UID=$DEFAULT_MIN_UID

LOG_DIR="/var/log/sre-tools"
REPORT_DIR="/opt/sre-reports"
LOG="$LOG_DIR/user_last_login.log"
REPORT="$REPORT_DIR/user_last_login_$(date +%F).csv"


# Display Usage/Help
display_usage() {
    echo "Usage: $(basename "$0") [-u MIN_UID] [-d REPORT_DIR]"
    echo ""
    echo "Options:"
    echo "  -u | --uid <UID>         Set minimum User ID to check (default: $DEFAULT_MIN_UID)."
    echo "  -d | --dir <PATH>        Set the report output directory (default: $REPORT_DIR)."
    echo "  -h | --help              Display this help message."
    echo "  -v | --version           Display script version."
    exit 0
}

## Display Version
display_version() {
    echo "$(basename "$0") version 1.0.0"
    exit 0
}


# Parse Command Line Options
parse_options() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -u | --uid)
                if [[ -z "$2" ]] || [[ "$2" =~ ^- ]]; then
                    echo "ERROR: Option $1 requires a numeric argument." >&2
                    exit 1
                fi
                if ! [[ "$2" =~ ^[0-9]+$ ]]; then
                    echo "ERROR: Invalid UID specified: '$2'. UID must be a number." >&2
                    exit 1
                fi
                MIN_UID="$2"
                shift
                ;;
            -d | --dir)
                if [[ -z "$2" ]] || [[ "$2" =~ ^- ]]; then
                    echo "ERROR: Option $1 requires an argument." >&2
                    exit 1
                fi
                REPORT_DIR="$2"
                shift
                ;;
            -h | --help)
                display_usage
                ;;
            -v | --version)
                display_version
                ;;
            *)
                echo "ERROR: Unknown option: $1" >&2
                display_usage
                ;;
        esac
        shift
    done

    REPORT="$REPORT_DIR/user_last_login_$(date +%F).csv"
}

# Check Dependencies
check_dependencies() {
    local REQUIRED_COMMANDS=("getent" "last" "lastlog" "id" "date" "awk" "sed" "grep")
    local cmd_missing=0

    echo "Checking dependencies..." >> "$LOG"

    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "ERROR: Required command '$cmd' is not installed or not in PATH." >> "$LOG"
            cmd_missing=1
        fi
    done

    if [[ "$cmd_missing" -eq 1 ]]; then
        echo "Script execution failed due to missing commands." >> "$LOG"
        exit 1
    fi
}


# Setup and Initialization
setup_environment() {

    #LOG title
    echo "=== $(date) START ===" >> "$LOG"
    # Writing CSV header (This will create or overwrite the file)
    echo "Username,Last_Login_Date,Days_Ago" > "$REPORT"
}

# Generate Report (Core Logic)
generate_report() {
    local USER_UID LAST_ENTRY LAST_LOGIN DAYS DATE_EPOCH NOW
    local LAST_LOG_ENTRY

    while IFS=: read -r USER _; do
        if [[ -z "$USER" ]]; then
            continue
        fi

        USER_UID=$(id -u "$USER" 2>/dev/null)
        if [[ "$USER_UID" -lt "$MIN_UID" ]]; then
            continue
        fi

        # 1. Attempt: Use ‘last’ (reliable for local users)
        LAST_ENTRY=$(last -w -n 1 "$USER" 2>/dev/null | head -1)
        LAST_LOGIN=""

        if [[ -n "$LAST_ENTRY" ]] && ! echo "$LAST_ENTRY" | grep -q "never logged"; then

            # User found in wtmp (last)
            if echo "$LAST_ENTRY" | grep -q "still logged"; then
                LAST_LOGIN="currently_logged_in"
                DAYS=0
            else
                # Parsing the date from last
                LAST_LOGIN=$(echo "$LAST_ENTRY" | awk '{print $4, $5, $6, $7}')
            fi
        fi

        # 2. Attempt: If last did not find the date, check ‘lastlog’ (for network users))
        if [[ -z "$LAST_LOGIN" ]]; then
            LAST_LOG_ENTRY=$(LANGUAGE=C lastlog -u "$USER" | sed -n "2p")

            if echo "$LAST_LOG_ENTRY" | grep -q "Never logged"; then
                 LAST_LOGIN="never"
            else
                # Если найдена дата в lastlog, парсим ее
                LAST_LOGIN=$(echo "$LAST_LOG_ENTRY" | awk '{print $4,$5,$6,$7}')
            fi
        fi

        # 3. Final calculation of days
        if [[ "$LAST_LOGIN" == "never" ]]; then
            DAYS="N/A"
        elif [[ "$LAST_LOGIN" == "currently_logged_in" ]]; then
            DAYS=0
        else
            if DATE_EPOCH=$(date -d "$LAST_LOGIN" +%s 2>/dev/null); then
                NOW=$(date +%s)
                DAYS=$(( (NOW - DATE_EPOCH) / 86400 ))
            else
                LAST_LOGIN="invalid"
                DAYS="N/A"
            fi
        fi

        echo "$USER,$LAST_LOGIN,$DAYS" >> "$REPORT"
    done < <(getent passwd)
}


# Finalize and Exit
cleanup_and_exit() {

    echo "Report saved to: $REPORT" >> "$LOG"
    echo "=== $(date) END ===" >> "$LOG"

    exit 0
}


# MAIN EXECUTION
parse_options "$@"
mkdir -p "$LOG_DIR"
mkdir -p "$REPORT_DIR"
check_dependencies
setup_environment
generate_report
cleanup_and_exit



