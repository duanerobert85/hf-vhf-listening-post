# HF/VHF Portable Listening Post

Raspberry Pi 3 Model B • NESDR SMArt • MHS35 3.5" Touchscreen • Sabrent USB DAC

Dedicated vehicle-mounted scanner. No desktop. PiScan backend + pygame framebuffer GUI.

## Quick start on the Pi

```bash
git clone https://github.com/duanerobert85/hf-vhf-listening-post.git
cd hf-vhf-listening-post
chmod +x scripts/*.sh

# Install packages
sudo ./scripts/install-deps.sh

# Install display (reboots)
sudo ./scripts/install-display.sh

# After reboot: configure audio
./scripts/setup-alsa.sh
# Edit and copy config/asound.conf.template to /etc/asound.conf

# Build PiScan (see docs/piscan-build.md)
# Copy config/systems.example.json to PiScan data/systems.json

# Install services
sudo cp systemd/*.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable piscan.service scanner-gui.service
```

Full workshop manual: see HF_VHF_Listening_Post_Manual.pdf in this repository.
