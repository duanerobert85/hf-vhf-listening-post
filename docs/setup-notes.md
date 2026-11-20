# Setup Notes (HDMI)

## Display
HDMI only. No MHS35 / SPI display.
The GUI uses the HDMI framebuffer (`/dev/fb0`).

Boot to console (no desktop):
```bash
sudo raspi-config
# System Options → Boot / Auto Login → Console
```

## Audio (Sabrent)
Identify card with `aplay -l`, then set `/etc/asound.conf` from the template.

## PiScan
Build with `-DUSE_AUDIO_ALSA=ON`.
Copy `config/systems.example.json` to the PiScan data directory as `systems.json`.

## Services
```bash
sudo systemctl daemon-reload
sudo systemctl enable piscan.service scanner-gui.service
sudo systemctl start piscan.service scanner-gui.service
```

Check framebuffer: `ls /dev/fb*`
