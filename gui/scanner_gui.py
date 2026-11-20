#!/usr/bin/env python3
"""
Scanner GUI for HDMI using kmsdrm (Raspberry Pi OS Trixie).
Requires libegl1 libgles2. Runs as a systemd service.
"""
import os
os.environ.setdefault("SDL_VIDEODRIVER", "kmsdrm")

import pygame
import sys

def main():
    pygame.init()
    # Use the native resolution reported by the display (1366x768 on this setup)
    info = pygame.display.Info()
    width = info.current_w or 1366
    height = info.current_h or 768
    screen = pygame.display.set_mode((width, height))
    pygame.display.set_caption("Scanner")

    font = pygame.font.Font(None, 72)
    small = pygame.font.Font(None, 36)

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

        screen.fill((10, 20, 30))
        text = font.render(freq, True, (0, 255, 128))
        screen.blit(text, (50, 80))
        st = small.render(status, True, (255, 200, 0))
        screen.blit(st, (50, 180))

        # Soft key bar
        bar_h = 60
        pygame.draw.rect(screen, (40, 40, 60), (0, height - bar_h, width, bar_h))
        keys = ["SCAN", "HOLD", "MAN", "SQL"]
        for i, k in enumerate(keys):
            label = small.render(k, True, (220, 220, 220))
            screen.blit(label, (40 + i * 200, height - 40))

        pygame.display.flip()
        clock.tick(15)

    pygame.quit()
    sys.exit(0)

if __name__ == "__main__":
    main()
