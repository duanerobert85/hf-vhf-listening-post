# Scanner GUI

Minimal pygame skeleton in scanner_gui.py.

Environment variables expected by the systemd unit:
- SDL_FBDEV=/dev/fb1 (or fb0 depending on driver)
- SDL_VIDEODRIVER=fbcon

To test manually from console:
```bash
export SDL_FBDEV=/dev/fb1
export SDL_VIDEODRIVER=fbcon
python3 scanner_gui.py
```

Touch events come from the XPT2046 (ADS7846) input device.
Use evtest to identify the event node if needed.

Next steps:
- Implement protobuf client to PiScan (localhost:1234)
- Map touch zones to SCAN/HOLD/MANUAL/SQUELCH
- Update frequency and channel tags from server state
