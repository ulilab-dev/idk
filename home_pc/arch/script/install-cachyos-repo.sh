#!/bin/bash

# CachyOS Repository Auto-Installer
# For Arch Linux and Arch-based distributions

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Error: This script must be run as root${NC}"
    exit 1
fi

if ! command -v pacman &> /dev/null; then
    echo -e "${RED}Error: pacman not found. This script is for Arch-based systems only.${NC}"
    exit 1
fi

echo -e "${GREEN}=== CachyOS Repository Installer ===${NC}"
echo

echo -e "${YELLOW}Select installation method:${NC}"
echo "1) Automated (recommended) - Downloads official CachyOS script"
echo "2) Manual - Adds repos directly"
read -p "Enter choice [1-2]: " choice

case $choice in
    1)
        echo -e "${GREEN}Downloading CachyOS repo installer...${NC}"
        cd /tmp
        curl -O https://mirror.cachyos.org/cachyos-repo.tar.xz
        tar xvf cachyos-repo.tar.xz
        cd cachyos-repo
        echo -e "${GREEN}Running official installer...${NC}"
        sudo ./cachyos-repo.sh
        ;;
    2)
        echo -e "${YELLOW}Detecting CPU architecture...${NC}"
        
        if grep -q "x86-64-v4" /proc/cpuinfo 2>/dev/null || /lib/ld-linux-x86-64.so.2 --help 2>/dev/null | grep -q "x86-64-v4"; then
            ARCH="v4"
            echo -e "${GREEN}Detected: x86-64-v4${NC}"
        elif grep -q "x86-64-v3" /proc/cpuinfo 2>/dev/null || /lib/ld-linux-x86-64.so.2 --help 2>/dev/null | grep -q "x86-64-v3"; then
            ARCH="v3"
            echo -e "${GREEN}Detected: x86-64-v3${NC}"
        else
            ARCH="v2"
            echo -e "${GREEN}Detected: x86-64 (baseline)${NC}"
        fi
        
        echo -e "${YELLOW}Importing CachyOS signing key...${NC}"
        pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
        pacman-key --lsign-key F3B607488DB35A47
        
        echo -e "${YELLOW}Installing CachyOS keyring and mirrorlists...${NC}"
        pacman -U --noconfirm \
            "https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-keyring-20240331-1-any.pkg.tar.zst" \
            "https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-mirrorlist-27-1-any.pkg.tar.zst" \
            "https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v3-mirrorlist-27-1-any.pkg.tar.zst" \
            "https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v4-mirrorlist-27-1-any.pkg.tar.zst"
        
        echo -e "${YELLOW}Configuring repositories in pacman.conf...${NC}"
        
        REPO_CONFIG=""
        if [[ "$ARCH" == "v4" ]]; then
            REPO_CONFIG="[cachyos-v4]
Include = /etc/pacman.d/cachyos-v4-mirrorlist

[cachyos-core-v4]
Include = /etc/pacman.d/cachyos-v4-mirrorlist

[cachyos-extra-v4]
Include = /etc/pacman.d/cachyos-v4-mirrorlist

"
        elif [[ "$ARCH" == "v3" ]]; then
            REPO_CONFIG="[cachyos-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist

[cachyos-core-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist

[cachyos-extra-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist

"
        fi
        
        REPO_CONFIG="${REPO_CONFIG}[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist"
        
        if ! grep -q "\[cachyos\]" /etc/pacman.conf; then
            cp /etc/pacman.conf /etc/pacman.conf.bak
            echo -e "\n${REPO_CONFIG}" >> /etc/pacman.conf
            echo -e "${GREEN}Repositories added to pacman.conf${NC}"
        else
            echo -e "${YELLOW}CachyOS repositories already configured${NC}"
        fi
        
        echo -e "${YELLOW}Syncing package databases...${NC}"
        pacman -Sy
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo
echo -e "${GREEN}=== Installation Complete ===${NC}"
echo -e "${YELLOW}Run 'sudo pacman -Syu' to update your system${NC}"
