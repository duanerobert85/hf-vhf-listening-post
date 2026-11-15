#!/bin/bash
# Install MHS35 display driver (goodtft)
set -e

if [ ! -d "$HOME/LCD-show" ]; then
  git clone https://github.com/goodtft/LCD-show.git "$HOME/LCD-show"
fi
cd "$HOME/LCD-show"
chmod -R 755 .
sudo ./MHS35-show

echo "Display driver installed. Reboot required."
echo "After reboot, check /dev/fb* and test with: sudo fbi -T 1 -a /path/to/image.png"
