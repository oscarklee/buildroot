#!/bin/bash

set -e

BOARD_DIR="$(dirname $0)"
GENIMAGE_CFG="${BOARD_DIR}/genimage.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

# Copy RPi firmware files
FIRMWARE_DIR="${BINARIES_DIR}/rpi-firmware"

# Ensure firmware files are at the root of BINARIES_DIR for genimage
# Buildroot's rpi-firmware package puts them in rpi-firmware/
if [ -d "${FIRMWARE_DIR}" ]; then
    echo "Copying firmware files from ${FIRMWARE_DIR} to ${BINARIES_DIR}..."
    cp -f "${FIRMWARE_DIR}"/bootcode.bin "${BINARIES_DIR}/" 2>/dev/null || true
    cp -f "${FIRMWARE_DIR}"/start*.elf "${BINARIES_DIR}/" 2>/dev/null || true
    cp -f "${FIRMWARE_DIR}"/fixup*.dat "${BINARIES_DIR}/" 2>/dev/null || true
    cp -f "${FIRMWARE_DIR}"/config.txt "${BINARIES_DIR}/" 2>/dev/null || true
    
    # Copy overlays if they exist in firmware dir
    if [ -d "${FIRMWARE_DIR}/overlays" ]; then
        mkdir -p "${BINARIES_DIR}/overlays"
        cp -rf "${FIRMWARE_DIR}/overlays"/* "${BINARIES_DIR}/overlays/"
    fi
fi

# Copy any dtbo files from BINARIES_DIR to overlays/
if ls "${BINARIES_DIR}"/*.dtbo >/dev/null 2>&1; then
    mkdir -p "${BINARIES_DIR}/overlays"
    cp -f "${BINARIES_DIR}"/*.dtbo "${BINARIES_DIR}/overlays/"
fi

# Copy all dtbs and overlays
cp -f "${BINARIES_DIR}"/*.dtb "${BINARIES_DIR}/" 2>/dev/null || true
if [ -d "${BINARIES_DIR}/rpi-firmware/overlays" ]; then
    cp -rf "${BINARIES_DIR}/rpi-firmware/overlays" "${BINARIES_DIR}/"
fi

# Copy cmdline.txt and config.txt from board directory
cp -f "${BOARD_DIR}/cmdline.txt" "${BINARIES_DIR}/"
cp -f "${BOARD_DIR}/config.txt" "${BINARIES_DIR}/"

# Run genimage
rm -rf "${GENIMAGE_TMP}"
genimage \
    --rootpath "${TARGET_DIR}" \
    --tmppath "${GENIMAGE_TMP}" \
    --inputpath "${BINARIES_DIR}" \
    --outputpath "${BINARIES_DIR}" \
    --config "${GENIMAGE_CFG}"

echo "SD card image created: ${BINARIES_DIR}/sdcard.img"
