#!/bin/sh

set -u
set -e

TARGET_DIR=$1

echo "Running post-build script for Raspberry Pi Zero 2W with Snes9x..."

# Add a console on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
	sed -i '/GENERIC_SERIAL/a\
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console' ${TARGET_DIR}/etc/inittab
# systemd doesn't use /etc/inittab, enable getty.tty1.service instead
elif [ -d ${TARGET_DIR}/etc/systemd ]; then
    mkdir -p "${TARGET_DIR}/etc/systemd/system/getty.target.wants"
    ln -sf /lib/systemd/system/getty@.service \
       "${TARGET_DIR}/etc/systemd/system/getty.target.wants/getty@tty1.service"
fi

# Create necessary directories for WiFi
mkdir -p "${TARGET_DIR}/var/run/wpa_supplicant"

# Create necessary directories for Bluetooth
mkdir -p "${TARGET_DIR}/var/lib/bluetooth"

# Set proper permissions for wpa_supplicant.conf
if [ -f "${TARGET_DIR}/etc/wpa_supplicant.conf" ]; then
    chmod 600 "${TARGET_DIR}/etc/wpa_supplicant.conf"
fi

# Make Bluetooth init script executable
if [ -f "${TARGET_DIR}/etc/init.d/S40bluetooth" ]; then
    chmod +x "${TARGET_DIR}/etc/init.d/S40bluetooth"
fi

# Make init scripts executable for Snes9x
if [ -f "${TARGET_DIR}/etc/init.d/S99emulator" ]; then
    chmod +x "${TARGET_DIR}/etc/init.d/S99emulator"
fi

if [ -f "${TARGET_DIR}/etc/init.d/S99background" ]; then
    chmod +x "${TARGET_DIR}/etc/init.d/S99background"
fi

# Set proper permissions for snes9x config
if [ -d "${TARGET_DIR}/root/.snes9x" ]; then
    chmod -R 755 "${TARGET_DIR}/root/.snes9x"
fi

# Set proper permissions for Bluetooth config
if [ -d "${TARGET_DIR}/var/lib/bluetooth" ]; then
    chmod -R 755 "${TARGET_DIR}/var/lib/bluetooth"
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
