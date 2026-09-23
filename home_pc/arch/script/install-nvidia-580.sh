#!/bin/sh

sudo pacman -Sy libva-nvidia-driver \
    lib32-opencl-nvidia-580xx \
    lib32-nvidia-580xx-utils \
    opencl-nvidia-580xx \
    nvidia-580xx-dkms \
    nvidia-580xx-utils \
    libxnvctrl-580xx \
    nvidia-580xx-settings
