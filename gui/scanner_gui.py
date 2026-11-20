#!/usr/bin/env python3
"""
Minimal scanner GUI skeleton for HDMI framebuffer.
Talks to PiScan on localhost:1234 (protobuf — to be implemented).
Uses /dev/fb0 by default.
"""
import os
os.environ.setdefault("SDL_FBDEV", "/dev/fb0")
os.environ.setdefault("SDL_VIDEODRIVER", "fbcon")

import pygame
import sys

# Typical HDMI console resolution; adjust if needed
WIDTH, HEIGHT = 800, 480

def main():
    global WIDTH, HEIGHT
    pygame.init()
    try:
        screen = pygame.display.set_mode((WIDTH, HEIGHT))
    except pygame.error:
        # Fallback if resolution is different
        screen = pygame.display.set_mode((0, 0), pygame.FULLSCREEN)
        WIDTH, HEIGHT = screen.get_size()

    pygame.display.set_caption("Scanner")
    font = pygame.font.Font(None, 48)
    small = pygame.font.Font(None, 28)

    clock = pygame.time.Clock()
    running = True
    freq = "154.280 MHz"
    status = "SCAN"

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            if event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
                running = False
            if event.type == pygame.MOUSEBUTTONDOWN:
                # TODO: map touch/mouse to soft keys
                pass

        screen.fill((10, 20, 30))
        text = font.render(freq, True, (0, 255, 128))
        screen.blit(text, (30, 60))
        st = small.render(status, True, (255, 200, 0))
        screen.blit(st, (30, 130))

        # Soft key bar
        bar_h = 50
        pygame.draw.rect(screen, (40, 40, 60), (0, HEIGHT - bar_h, WIDTH, bar_h))
        keys = ["SCAN", "HOLD", "MAN", "SQL"]
        for i, k in enumerate(keys):
            label = small.render(k, True, (220, 220, 220))
            screen.blit(label, (20 + i * 160, HEIGHT - 35))

        pygame.display.flip()
        clock.tick(15)

    pygame.quit()
    sys.exit(0)

if __name__ == "__main__":
    main()
