# HF/VHF Portable Listening Post

Raspberry Pi 3 Model B • NESDR SMArt • MHS35 3.5" Touchscreen • Sabrent USB DAC

Dedicated vehicle-mounted scanner. No desktop. PiScan backend + pygame framebuffer GUI.

## One-shot install (recommended)

```bash
git clone https://github.com/duanerobert85/hf-vhf-listening-post.git
cd hf-vhf-listening-post
chmod +x scripts/one-shot-install.sh
./scripts/one-shot-install.sh
```

The script will:
- Update the system and install all dependencies
- Install the MHS35 display driver
- Build PiScan with the ALSA audio backend
- Install systemd service units
- Copy an example systems.json

After it finishes:
1. Reboot (`sudo reboot`) so the display framebuffer is active
2. Configure `/etc/asound.conf` for the Sabrent DAC (see the script output and `config/asound.conf.template`)
3. Edit `~/PiScan/data/systems.json` with your frequencies
4. Enable the services:
   ```bash
   sudo systemctl enable piscan.service scanner-gui.service
   sudo systemctl start piscan.service scanner-gui.service
   ```

## Manual steps (if preferred)

See the individual scripts in `scripts/` and `docs/` for step-by-step control.

Full workshop manual PDF is available from the original project conversation.
