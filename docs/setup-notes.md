# Setup Notes

## Display
After cloning LCD-show:
```bash
cd /home/pi/LCD-show
sudo ./MHS35-show
```

## Audio (Sabrent)
Identify card with `aplay -l`, then set `/etc/asound.conf`.

## PiScan
Build with `-DUSE_AUDIO_ALSA=ON`.
Copy `config/systems.example.json` to the PiScan data directory as `systems.json`.

## Services
```bash
sudo cp systemd/*.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable piscan.service scanner-gui.service
```
