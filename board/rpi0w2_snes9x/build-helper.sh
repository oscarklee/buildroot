#!/bin/bash
#
# Helper script to build and update the Snes9x image
#

set -e

BUILDROOT_DIR="/Users/oklee/dev/playgrd/buildroot"
SNES9X_SOURCE="/Users/oklee/dev/playgrd/snes9x/snes9x"
DEFCONFIG="rpi0w2_snes9x_defconfig"

cd "$BUILDROOT_DIR"

echo "=== Snes9x Buildroot Helper ==="
echo ""
echo "Options:"
echo "  1) Initial configuration (make defconfig)"
echo "  2) Configuration menu (menuconfig)"
echo "  3) Build everything (make)"
echo "  4) Build Snes9x only (make snes9x-rebuild)"
echo "  5) Clean Snes9x build (make snes9x-dirclean)"
echo "  6) Clean everything and rebuild (make clean + make)"
echo "  7) Update Snes9x source code"
echo "  8) Flash image to SD card"
echo "  9) Exit"
echo ""
read -p "Select option: " option

case $option in
    1)
        echo "Loading configuration ${DEFCONFIG}..."
        make ${DEFCONFIG}
        echo "Configuration loaded. Run 'make' to compile."
        ;;
    2)
        echo "Opening menuconfig..."
        make menuconfig
        ;;
    3)
        echo "Building full image..."
        echo "This may take 1-2 hours on the first build."
        read -p "Continue? (y/n): " confirm
        if [ "$confirm" = "y" ]; then
            time make -j$(nproc)
            echo ""
            echo "✓ Build completed!"
            echo "Image: output/images/sdcard.img"
        fi
        ;;
    4)
        echo "Rebuilding Snes9x only..."
        make snes9x-rebuild
        echo "Regenerating image..."
        make
        echo "✓ Snes9x updated!"
        ;;
    5)
        echo "Cleaning Snes9x build..."
        make snes9x-dirclean
        echo "✓ Cleaning completed. Run option 3 or 4 to rebuild."
        ;;
    6)
        echo "Clean EVERYTHING and rebuild from scratch?"
        read -p "This will delete all builds. Continue? (y/n): " confirm
        if [ "$confirm" = "y" ]; then
            make clean
            time make -j$(nproc)
            echo "✓ Full rebuild finished!"
        fi
        ;;
    7)
        echo "Updating Snes9x source code..."
        if [ -d "$SNES9X_SOURCE" ]; then
            echo "Source code at: $SNES9X_SOURCE"
            echo "Remember that changes are taken from there automatically."
            echo "Run option 4 to rebuild with new changes."
        else
            echo "⚠ Directory not found: $SNES9X_SOURCE"
        fi
        ;;
    8)
        echo "Flash image to SD card"
        if [ ! -f "output/images/sdcard.img" ]; then
            echo "⚠ output/images/sdcard.img does not exist"
            echo "Build first (option 3)"
            exit 1
        fi
        
        echo ""
        echo "Available devices:"
        lsblk -d -o NAME,SIZE,TYPE,MODEL | grep disk
        echo ""
        read -p "Enter device (e.g., sdb, mmcblk0): " device
        
        if [ -z "$device" ]; then
            echo "⚠ No device entered"
            exit 1
        fi
        
        DEV="/dev/$device"
        
        if [ ! -b "$DEV" ]; then
            echo "⚠ $DEV is not a valid block device"
            exit 1
        fi
        
        echo ""
        echo "⚠⚠⚠ WARNING ⚠⚠⚠"
        echo "This will ERASE ALL content on $DEV"
        echo ""
        read -p "Are you SURE? Type 'YES' to continue: " confirm
        
        if [ "$confirm" = "YES" ]; then
            echo "Flashing image..."
            sudo dd if=output/images/sdcard.img of=$DEV bs=4M status=progress conv=fsync
            sync
            echo ""
            echo "✓ Image flashed successfully!"
            echo "You can remove the SD card and use it in your Raspberry Pi."
        else
            echo "Operation cancelled."
        fi
        ;;
    9)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac
