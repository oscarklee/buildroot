#!/bin/sh

set -u
set -e

TARGET_DIR=$1

echo "Running post-build script for Raspberry Pi Zero 2W with Snes9x..."

# Remove unnecessary services to speed up boot
rm -f "${TARGET_DIR}/etc/init.d/S01syslogd"
rm -f "${TARGET_DIR}/etc/init.d/S02klogd"
rm -f "${TARGET_DIR}/etc/init.d/S50crond"

# Create necessary directories for WiFi
mkdir -p "${TARGET_DIR}/var/run/wpa_supplicant"

# Create necessary directories for Bluetooth
mkdir -p "${TARGET_DIR}/var/lib/bluetooth"

# Set proper permissions for wpa_supplicant.conf
if [ -f "${TARGET_DIR}/etc/wpa_supplicant.conf" ]; then
    chmod 600 "${TARGET_DIR}/etc/wpa_supplicant.conf"
fi

# Make init scripts executable
if [ -f "${TARGET_DIR}/etc/init.d/S30snes9x" ]; then
    chmod +x "${TARGET_DIR}/etc/init.d/S30snes9x"
fi
if [ -f "${TARGET_DIR}/etc/init.d/S40bluetooth" ]; then
    chmod +x "${TARGET_DIR}/etc/init.d/S40bluetooth"
fi

# Remove old scripts if they exist in target
rm -f "${TARGET_DIR}/etc/init.d/S30emulator"
rm -f "${TARGET_DIR}/etc/init.d/S99emulator"
rm -f "${TARGET_DIR}/etc/init.d/S99background"

# Set proper permissions for snes9x config
if [ -d "${TARGET_DIR}/root/.snes9x" ]; then
    chmod -R 755 "${TARGET_DIR}/root/.snes9x"
fi

# Fix Bluetooth permissions (BlueZ is strict)
BT_DIR="${TARGET_DIR}/var/lib/bluetooth"
if [ -d "${BT_DIR}" ]; then
    find "${BT_DIR}" -type d -exec chmod 700 {} \;
    find "${BT_DIR}" -type f -exec chmod 600 {} \;
fi

# Create necessary directories
mkdir -p "${TARGET_DIR}/var/run/dbus"

# Set root directory permissions
chmod 700 "${TARGET_DIR}/root"

# Remove conflicting Buildroot Bluetooth init scripts
rm -f "${TARGET_DIR}/etc/init.d/S30bluetooth"
rm -f "${TARGET_DIR}/etc/init.d/S40bluetoothd"
rm -f "${TARGET_DIR}/etc/init.d/S45bluetoothd"

echo "Post-build script completed successfully."
