#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$(dirname "$SCRIPT_DIR")"

usage_text() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help       Show this help message"
    echo "  -a, --auto       Bump version to current date (e.g. 2026/10 -> 1.2026.10)"
    echo "  -v, --version    Set specific version (e.g., 1.2026.10)"
    echo "  -m, --month      Bump month (1.2026.10 -> 1.2026.11; 1.2026.12 -> 1.2027.1)"
}

usage() {
    local exit_code="${1:-0}"
    if [ "$exit_code" -eq 0 ]; then
        usage_text
    else
        usage_text >&2
    fi
    exit "$exit_code"
}

get_current_version() {
    sed -n 's/^version[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' Cargo.toml | head -n1
}

set_version() {
    local new_version="$1"
    sed -i "s/^version[[:space:]]*=.*/version = \"${new_version}\"/" Cargo.toml
}

mode=""
explicit_version=""

while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        -a|--auto)
            mode="auto"
            shift
            ;;
        -v|--version)
            mode="version"
            shift
            if [ "$#" -eq 0 ]; then
                echo "Error: --version requires an argument" >&2
                usage 1
            fi
            explicit_version="$1"
            shift
            ;;
        -m|--month)
            mode="month"
            shift
            ;;
        *)
            echo "Error: unknown option '$1'" >&2
            usage 1
            ;;
    esac
done

if [ -z "$mode" ]; then
    usage
fi

case "$mode" in
    auto)
        new_version="1.$(date +%Y).$(date +%m)"
        ;;
    version)
        new_version="$explicit_version"
        if [[ ! "$new_version" =~ ^1\.[0-9]{4}\.[0-9]{1,2}$ ]]; then
            echo "Error: invalid version '${new_version}' (expected format: 1.YYYY.M)" >&2
            exit 1
        fi
        IFS='.' read -r _major year month <<< "$new_version"
        # Normalize the month to two digits so leading zeros are rejected as octal.
        new_version="1.${year}.$(printf '%02d' "$((10#$month))")"
        ;;
    month)
        current="$(get_current_version)"
        if [[ ! "$current" =~ ^1\.[0-9]{4}\.[0-9]{1,2}$ ]]; then
            echo "Error: current version '${current}' is not in the expected format" >&2
            exit 1
        fi

        IFS='.' read -r _major year month <<< "$current"
        month="$((10#$month + 1))"
        if [ "$month" -gt 12 ]; then
            month=1
            year="$((year + 1))"
        fi

        new_version="1.${year}.$(printf '%02d' "$month")"
        ;;
esac

set_version "$new_version"
echo "$new_version"
