#!/bin/bash
# One-shot install script for HF/VHF Listening Post
# Raspberry Pi 3 + NESDR SMArt + MHS35 + Sabrent DAC + PiScan
# Run as the normal user (pi). Script will use sudo where needed.
#
# Usage: chmod +x one-shot-install.sh && ./one-shot-install.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Detect user and home
USER_NAME=$(whoami)
HOME_DIR=$(eval echo ~$USER_NAME)
REPO_DIR="$HOME_DIR/hf-vhf-listening-post"
PISCAN_DIR="$HOME_DIR/PiScan"

info "Starting one-shot install for user: $USER_NAME"

# 1. System update
info "Updating system packages..."
sudo apt update
sudo apt full-upgrade -y

# 2. Install dependencies
info "Installing build and runtime dependencies..."
sudo apt install -y \
  g++ git build-essential cmake \
  libboost-all-dev libliquid-dev \
  soapysdr-module-rtlsdr librtlsdr0 \
  libasound2-dev protobuf-compiler libprotoc-dev \
  python3-pygame python3-protobuf \
  evtest alsa-utils fbi

# 3. Display driver (MHS35)
info "Installing MHS35 display driver..."
if [ ! -d "$HOME_DIR/LCD-show" ]; then
  git clone https://github.com/goodtft/LCD-show.git "$HOME_DIR/LCD-show"
fi
cd "$HOME_DIR/LCD-show"
chmod -R 755 .
sudo ./MHS35-show || warn "MHS35-show returned non-zero (may still be OK)"

warn "Display driver installed. A reboot is recommended before continuing with GUI tests."
warn "You can continue now or reboot and re-run this script (it is safe to re-run)."

# 4. Clone or update this repo (if not already present)
if [ ! -d "$REPO_DIR" ]; then
  info "Cloning listening-post repository..."
  git clone https://github.com/duanerobert85/hf-vhf-listening-post.git "$REPO_DIR"
else
  info "Repository already present, pulling latest..."
  cd "$REPO_DIR" && git pull || true
fi

# 5. Build PiScan with ALSA
info "Building PiScan (ALSA backend)..."
if [ ! -d "$PISCAN_DIR" ]; then
  git clone https://github.com/ezratl/PiScan.git "$PISCAN_DIR"
fi
cd "$PISCAN_DIR"
if [ -f configure_make ]; then
  sh ./configure_make || true
fi
mkdir -p build
cd build
cmake .. -DUSE_AUDIO_ALSA=ON
make -j$(nproc) piscan_server || make piscan_server
info "PiScan built. Binary is at $PISCAN_DIR/build/piscan_server"

# Optional install
# sudo make install

# 6. Prepare data directory and example systems.json
info "Preparing PiScan data directory..."
mkdir -p "$PISCAN_DIR/data"
if [ ! -f "$PISCAN_DIR/data/systems.json" ]; then
  cp "$REPO_DIR/config/systems.example.json" "$PISCAN_DIR/data/systems.json"
  info "Copied example systems.json"
fi

# 7. Install systemd services
info "Installing systemd service units..."
sudo cp "$REPO_DIR/systemd/piscan.service" /etc/systemd/system/
sudo cp "$REPO_DIR/systemd/scanner-gui.service" /etc/systemd/system/

# Fix paths in the service files if needed (they assume /home/pi)
if [ "$HOME_DIR" != "/home/pi" ]; then
  warn "Home is $HOME_DIR (not /home/pi). Editing service files..."
  sudo sed -i "s|/home/pi|$HOME_DIR|g" /etc/systemd/system/piscan.service
  sudo sed -i "s|/home/pi|$HOME_DIR|g" /etc/systemd/system/scanner-gui.service
fi

# Update ExecStart if we didn't do make install
PISCAN_BIN="$PISCAN_DIR/build/piscan_server"
if [ -f "$PISCAN_BIN" ]; then
  sudo sed -i "s|ExecStart=.*|ExecStart=$PISCAN_BIN|" /etc/systemd/system/piscan.service
  sudo sed -i "s|WorkingDirectory=.*|WorkingDirectory=$PISCAN_DIR/data|" /etc/systemd/system/piscan.service
fi

sudo systemctl daemon-reload

# 8. ALSA guidance
info "=== ALSA / Sabrent DAC setup (manual step) ==="
echo "Run: aplay -l"
echo "Identify the card number for the Sabrent USB device."
echo "Then copy and edit:"
echo "  sudo cp $REPO_DIR/config/asound.conf.template /etc/asound.conf"
echo "  sudo nano /etc/asound.conf   # set the correct card number"
echo "Test with: speaker-test -c 2 -t wav"
echo "Save mixer: sudo alsactl store"

# 9. Enable services (optional prompt)
info "=== Services ==="
echo "To enable automatic start on boot:"
echo "  sudo systemctl enable piscan.service scanner-gui.service"
echo "To start now (after display reboot and ALSA config):"
echo "  sudo systemctl start piscan.service"
echo "  sudo systemctl start scanner-gui.service"

info "=== One-shot install complete ==="
echo ""
echo "Next recommended steps:"
echo "  1. Reboot so the MHS35 framebuffer is active: sudo reboot"
echo "  2. Configure /etc/asound.conf for the Sabrent DAC"
echo "  3. Edit $PISCAN_DIR/data/systems.json with your frequencies"
echo "  4. Enable and start the services"
echo "  5. Check logs: journalctl -u piscan -f"
echo ""
info "Done."
