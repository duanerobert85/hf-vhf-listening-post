#!/bin/bash
# Install dependencies for PiScan + display + audio on Raspberry Pi OS Lite
set -e

sudo apt update
sudo apt install -y \
  g++ git build-essential cmake \
  libboost-all-dev libliquid-dev \
  soapysdr-module-rtlsdr librtlsdr0 \
  libasound2-dev protobuf-compiler libprotoc-dev \
  python3-pygame python3-protobuf \
  evtest alsa-utils

echo "Dependencies installed."
echo "Next: clone PiScan and build with -DUSE_AUDIO_ALSA=ON"
