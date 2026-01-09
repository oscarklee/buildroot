#!/bin/sh
# Fix Bluetooth permissions in the target filesystem
BT_DIR="${TARGET_DIR}/var/lib/bluetooth"
if [ -d "${BT_DIR}" ]; then
    find "${BT_DIR}" -type d -exec chmod 700 {} \;
    find "${BT_DIR}" -type f -exec chmod 600 {} \;
fi
