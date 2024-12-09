#!/bin/bash

# Get current date
now_date() {
    echo -n $(TZ="UTC" date '+%Y-%m-%d_%H:%M:%S')
}

# Write Log
log_this() {
    YEL='\033[1;33m' # yellow
    NC='\033[0m'     # No Color
    local logging="$@"
    printf "|$(now_date)| $logging\n" | tee -a ${LOG_PATH}
}
