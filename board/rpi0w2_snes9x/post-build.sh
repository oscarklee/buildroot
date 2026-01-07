#!/bin/sh

set -e

TARGET_DIR=$1

echo "Running post-build script for Snes9x..."

# Add a console on tty1 (HDMI console)
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
    sed -i '/GENERIC_SERIAL/a\
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console' ${TARGET_DIR}/etc/inittab
fi

# Make init scripts executable
chmod +x "${TARGET_DIR}/etc/init.d/S01emulator"
chmod +x "${TARGET_DIR}/etc/init.d/S02background"

# Set proper permissions for Bluetooth config
if [ -d "${TARGET_DIR}/var/lib/bluetooth" ]; then
    chmod -R 755 "${TARGET_DIR}/var/lib/bluetooth"
fi

# Set proper permissions for snes9x config
if [ -d "${TARGET_DIR}/root/.snes9x" ]; then
    chmod -R 755 "${TARGET_DIR}/root/.snes9x"
fi

# Create necessary directories
mkdir -p "${TARGET_DIR}/var/run/wpa_supplicant"
mkdir -p "${TARGET_DIR}/var/run/dbus"

# Set root directory permissions
chmod 700 "${TARGET_DIR}/root"

echo "Post-build script completed successfully."
