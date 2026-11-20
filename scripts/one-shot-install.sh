#!/bin/bash
# One-shot install script for HF/VHF Listening Post
# Raspberry Pi 3 + NESDR SMArt + HDMI + Sabrent DAC + PiScan
# HDMI framebuffer UI (no MHS35 / no SPI display)
# Run as the normal user (pi). Script will use sudo where needed.
#
# Usage: chmod +x one-shot-install.sh && ./one-shot-install.sh

set -u

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

USER_NAME=$(whoami)
HOME_DIR=$(eval echo ~$USER_NAME)
REPO_DIR="$HOME_DIR/hf-vhf-listening-post"
PISCAN_DIR="$HOME_DIR/PiScan"
PISCAN_BIN="$PISCAN_DIR/build/piscan_server"
DATA_DIR="$PISCAN_DIR/data"

info "Starting one-shot install for user: $USER_NAME ($HOME_DIR)"
info "Display mode: HDMI framebuffer (no MHS35)"

# 1. System update
info "Updating system packages..."
sudo apt update || warn "apt update failed"
sudo apt full-upgrade -y || warn "apt upgrade failed"

# 2. Install dependencies
info "Installing build and runtime dependencies..."
sudo apt install -y \
  g++ git build-essential cmake \
  libboost-all-dev libliquid-dev \
  libsoapysdr-dev soapysdr-module-rtlsdr soapysdr-tools \
  librtlsdr0 \
  libasound2-dev protobuf-compiler libprotoc-dev \
  python3-pygame python3-protobuf \
  evtest alsa-utils fbi \
|| warn "Some packages failed to install"

# 3. Clone or update this repo
if [ ! -d "$REPO_DIR" ]; then
  info "Cloning listening-post repository..."
  git clone https://github.com/duanerobert85/hf-vhf-listening-post.git "$REPO_DIR" || error "Failed to clone repo"
else
  info "Repository already present, pulling latest..."
  (cd "$REPO_DIR" && git pull) || warn "git pull failed"
fi

# 4. Build PiScan with ALSA
info "Building PiScan (ALSA backend)..."
if [ ! -d "$PISCAN_DIR" ]; then
  git clone https://github.com/ezratl/PiScan.git "$PISCAN_DIR" || error "Failed to clone PiScan"
fi

if [ -d "$PISCAN_DIR" ]; then
  cd "$PISCAN_DIR"
  if [ -f configure_make ]; then
    info "Running configure_make..."
    sh ./configure_make || warn "configure_make had errors (continuing)"
  fi
  mkdir -p build data
  cd build
  info "Running cmake with ALSA..."
  cmake .. -DUSE_AUDIO_ALSA=ON || warn "cmake failed"
  info "Building piscan_server..."
  make -j$(nproc) piscan_server || make piscan_server || warn "make failed"
  if [ -f "$PISCAN_BIN" ]; then
    info "PiScan binary built: $PISCAN_BIN"
  else
    warn "PiScan binary not found at $PISCAN_BIN"
  fi
else
  warn "PiScan directory missing, skipping build"
fi

# 5. Prepare data directory and example systems.json
info "Preparing PiScan data directory..."
mkdir -p "$DATA_DIR"
if [ -f "$REPO_DIR/config/systems.example.json" ] && [ ! -f "$DATA_DIR/systems.json" ]; then
  cp "$REPO_DIR/config/systems.example.json" "$DATA_DIR/systems.json"
  info "Copied example systems.json"
fi

# 6. Install systemd services (HDMI framebuffer)
info "Installing systemd service units for HDMI..."
if [ -d "$REPO_DIR/systemd" ]; then
  sudo tee /etc/systemd/system/piscan.service > /dev/null <<EOF
[Unit]
Description=PiScan Scanner Server
After=network.target sound.target

[Service]
Type=simple
User=$USER_NAME
WorkingDirectory=$DATA_DIR
ExecStart=$PISCAN_BIN
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

  sudo tee /etc/systemd/system/scanner-gui.service > /dev/null <<EOF
[Unit]
Description=Scanner HDMI GUI
After=piscan.service
Requires=piscan.service

[Service]
Type=simple
User=$USER_NAME
WorkingDirectory=$REPO_DIR/gui
Environment=SDL_FBDEV=/dev/fb0
Environment=SDL_VIDEODRIVER=fbcon
ExecStart=/usr/bin/python3 $REPO_DIR/gui/scanner_gui.py
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload || warn "daemon-reload failed"
  info "Service files written (HDMI /dev/fb0)"
else
  warn "systemd directory missing in repo, skipping service install"
fi

# 7. ALSA guidance
info "=== ALSA / Sabrent DAC setup (manual step) ==="
echo "Run: aplay -l"
echo "Identify the card number for the Sabrent USB device."
echo "Then:"
echo "  sudo cp $REPO_DIR/config/asound.conf.template /etc/asound.conf"
echo "  sudo nano /etc/asound.conf   # set the correct card number"
echo "Test with: speaker-test -c 2 -t wav"
echo "Save mixer: sudo alsactl store"

# 8. Final instructions
info "=== One-shot install finished (HDMI mode) ==="
echo ""
echo "Next steps:"
echo "  1. Ensure HDMI is connected and console is active (no desktop)"
echo "  2. Configure /etc/asound.conf for the Sabrent DAC"
echo "  3. Edit $DATA_DIR/systems.json with your frequencies"
echo "  4. Enable and start the services:"
echo "     sudo systemctl enable piscan.service scanner-gui.service"
echo "     sudo systemctl start piscan.service"
echo "     sudo systemctl start scanner-gui.service"
echo "  5. Check logs: journalctl -u piscan -f"
echo ""
if [ ! -f "$PISCAN_BIN" ]; then
  warn "PiScan binary was not built. Fix the build before starting the service."
fi
info "Done."
