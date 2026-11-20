# HF/VHF Portable Listening Post

Raspberry Pi 3 Model B • NESDR SMArt • HDMI display • Sabrent USB DAC

Dedicated scanner. No desktop. PiScan backend + pygame HDMI framebuffer GUI.

## One-shot install

```bash
git clone https://github.com/duanerobert85/hf-vhf-listening-post.git
cd hf-vhf-listening-post
chmod +x scripts/one-shot-install.sh
./scripts/one-shot-install.sh
```

The script will:
- Update the system and install all dependencies
- Build PiScan with the ALSA audio backend
- Install systemd service units for HDMI (/dev/fb0)
- Copy an example systems.json

After it finishes:
1. Confirm HDMI console is active (no desktop)
2. Configure `/etc/asound.conf` for the Sabrent DAC (see `config/asound.conf.template`)
3. Edit `~/PiScan/data/systems.json` with your frequencies
4. Enable the services:
   ```bash
   sudo systemctl enable piscan.service scanner-gui.service
   sudo systemctl start piscan.service scanner-gui.service
   ```

## Notes
- Display is HDMI only for now (MHS35 / SPI display removed).
- GUI runs on the HDMI framebuffer (/dev/fb0).
- Full workshop manual PDF can be regenerated if needed.
