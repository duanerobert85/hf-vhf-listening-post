#!/usr/bin/env python3
"""
Minimal direct-framebuffer scanner GUI for HDMI console.
No SDL/pygame — works as a systemd service on Raspberry Pi OS Trixie.
Draws to /dev/fb0.
"""
import os
import sys
import mmap
import struct
import time
import fcntl

# Framebuffer ioctl constants
FBIOGET_VSCREENINFO = 0x4600
FBIOGET_FSCREENINFO = 0x4602

def get_fb_info(fd):
    # Variable screen info
    vinfo = bytearray(160)
    fcntl.ioctl(fd, FBIOGET_VSCREENINFO, vinfo)
    xres, yres, xres_virtual, yres_virtual, bits_per_pixel = struct.unpack_from('IIIIII', vinfo, 0)[:5]
    # Fixed screen info
    finfo = bytearray(80)
    fcntl.ioctl(fd, FBIOGET_FSCREENINFO, finfo)
    line_length = struct.unpack_from('I', finfo, 16)[0]
    return xres, yres, bits_per_pixel, line_length

def draw_pixel(fb, line_length, bpp, x, y, r, g, b):
    if bpp == 16:
        # RGB565
        color = ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3)
        offset = y * line_length + x * 2
        fb[offset:offset+2] = struct.pack('H', color)
    elif bpp == 32:
        # BGRA or RGBA — most Pi framesbuffers are BGRA
        offset = y * line_length + x * 4
        fb[offset:offset+4] = bytes([b, g, r, 255])

def fill_rect(fb, line_length, bpp, x, y, w, h, r, g, b):
    for yy in range(y, y + h):
        for xx in range(x, x + w):
            draw_pixel(fb, line_length, bpp, xx, yy, r, g, b)

def main():
    fb_path = "/dev/fb0"
    if not os.path.exists(fb_path):
        print("No /dev/fb0 found. Enable the framebuffer console or check HDMI.")
        sys.exit(1)

    fd = os.open(fb_path, os.O_RDWR)
    xres, yres, bpp, line_length = get_fb_info(fd)
    print(f"Framebuffer: {xres}x{yres} @ {bpp}bpp, line={line_length}")

    size = yres * line_length
    fb = mmap.mmap(fd, size, mmap.MAP_SHARED, mmap.PROT_WRITE | mmap.PROT_READ)

    # Simple UI colors
    bg = (10, 20, 30)
    green = (0, 255, 128)
    yellow = (255, 200, 0)
    bar = (40, 40, 60)
    white = (220, 220, 220)

    freq = "154.280 MHz"
    status = "SCAN"

    try:
        while True:
            # Clear background
            fill_rect(fb, line_length, bpp, 0, 0, xres, yres, *bg)

            # Draw a simple frequency area (just a colored block for now)
            fill_rect(fb, line_length, bpp, 30, 50, 400, 60, *green)
            fill_rect(fb, line_length, bpp, 30, 130, 200, 40, *yellow)

            # Soft key bar
            bar_h = 50
            fill_rect(fb, line_length, bpp, 0, yres - bar_h, xres, bar_h, *bar)
            # Key indicators
            keys = ["SCAN", "HOLD", "MAN", "SQL"]
            for i, k in enumerate(keys):
                fill_rect(fb, line_length, bpp, 20 + i * 160, yres - 40, 120, 30, *white)

            time.sleep(1)
    except KeyboardInterrupt:
        pass
    finally:
        fb.close()
        os.close(fd)

if __name__ == "__main__":
    main()
