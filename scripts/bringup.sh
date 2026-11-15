#!/bin/bash
# Basic bring-up helper for the listening post
set -e

echo "=== Updating system ==="
sudo apt update
sudo apt full-upgrade -y

echo "=== Installing display driver dependencies ==="
sudo apt install -y git cmake

if [ ! -d /home/pi/LCD-show ]; then
  git clone https://github.com/goodtft/LCD-show.git /home/pi/LCD-show
fi

echo "=== Note: Run the following manually after reviewing ==="
echo "cd /home/pi/LCD-show && sudo ./MHS35-show"
echo "Then reboot and configure ALSA for the Sabrent DAC."

echo "=== Done (partial) ==="
