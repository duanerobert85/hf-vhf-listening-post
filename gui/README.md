# Scanner GUI (HDMI)

Minimal pygame skeleton in scanner_gui.py for the HDMI framebuffer.

Environment variables used by the systemd unit:
- SDL_FBDEV=/dev/fb0
- SDL_VIDEODRIVER=fbcon

To test manually from the console (HDMI connected, no desktop):
```bash
export SDL_FBDEV=/dev/fb0
export SDL_VIDEODRIVER=fbcon
python3 scanner_gui.py
```

Press Escape to quit in the current skeleton.

Next steps:
- Implement protobuf client to PiScan (localhost:1234)
- Map input to SCAN/HOLD/MANUAL/SQUELCH
- Update frequency and channel tags from server state
