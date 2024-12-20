#!/bin/bash

source ./common.sh

# Define variables
CHAIN_ID="shentu-2.2"
SNAP_PATH="/var/snapshots/shentu"
LOG_PATH="/var/snapshots/shentu/shentu.log"
DATA_PATH="$HOME/.shentud/data/"
SERVICE_NAME="shentud.service"
RPC_ADDRESS="http://127.0.0.1:14657"

# Check if the directory exists, if not, create it
if [ ! -d "$SNAP_PATH" ]; then
    echo "Directory $SNAP_PATH does not exist. Creating it..."
    mkdir -p "$SNAP_PATH"
fi

# Check if the log file exists, if not, create it
if [ ! -f "$LOG_PATH" ]; then
    echo "Log file $LOG_PATH does not exist. Creating it..."
    touch "$LOG_PATH"
fi

# Generate new snap name, collect old name
SNAP_NAME=$(echo "${CHAIN_ID}_$(date '+%Y-%m-%d').tar.lz4")

LAST_BLOCK_HEIGHT=$(curl -s ${RPC_ADDRESS}/status | jq -r .result.sync_info.latest_block_height)
log_this "LAST_BLOCK_HEIGHT ${LAST_BLOCK_HEIGHT}"

log_this "Stopping ${SERVICE_NAME}"
systemctl stop ${SERVICE_NAME}; echo $? >> ${LOG_PATH}

log_this "Creating new snapshot"
time tar -cf - -C ${DATA_PATH} . | lz4 - > ${HOME}/${SNAP_NAME} 2>&1 | tee -a ${LOG_PATH}

log_this "Starting ${SERVICE_NAME}"
systemctl start ${SERVICE_NAME}; echo $? >> ${LOG_PATH}

log_this "Removing old snapshot(s):"
cd ${SNAP_PATH}
# Find and remove .lz4 files older than 24 hours
find . -name "*.lz4" -type f -mtime +1 -exec rm -fv {} \; &>>${LOG_PATH}

log_this "Moving new snapshot to ${SNAP_PATH}"
mv ${HOME}/${CHAIN_ID}*lz4 ${SNAP_PATH}

du -hs ${SNAP_PATH} | tee -a ${LOG_PATH}

log_this "Done\n---------------------------\n"
