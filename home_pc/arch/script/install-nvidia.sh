#!/bin/sh

sudo pacman -Sy nvidia-open \
                nvidia-utils \
                lib32-nvidia-utils \
                lib32-opencl-nvidia \
                opencl-nvidia \
                libva-nvidia-driver \
                nvidia-settings --noconfirm
                
                
