#!/usr/bin/env python3
"""
Minimal scanner GUI skeleton for MHS35 framebuffer.
Talks to PiScan on localhost:1234 (protobuf — to be implemented).
"""
import os
os.environ["SDL_FBDEV"] = "/dev/fb1"
os.environ["SDL_VIDEODRIVER"] = "fbcon"

import pygame
import sys

# 320x480 landscape or portrait depending on rotate
WIDTH, HEIGHT = 480, 320

def main():
    pygame.init()
    screen = pygame.display.set_mode((WIDTH, HEIGHT))
    pygame.display.set_caption("Scanner")
    font = pygame.font.Font(None, 36)
    small = pygame.font.Font(None, 24)

    clock = pygame.time.Clock()
    running = True
    freq = "154.280 MHz"
    status = "SCAN"

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            if event.type == pygame.MOUSEBUTTONDOWN:
                # TODO: map touch to soft keys
                pass

        screen.fill((10, 20, 30))
        # Frequency display
        text = font.render(freq, True, (0, 255, 128))
        screen.blit(text, (20, 40))
        # Status
        st = small.render(status, True, (255, 200, 0))
        screen.blit(st, (20, 90))
        # Soft key bar
        pygame.draw.rect(screen, (40, 40, 60), (0, HEIGHT-40, WIDTH, 40))
        keys = ["SCAN", "HOLD", "MAN", "SQL"]
        for i, k in enumerate(keys):
            label = small.render(k, True, (220, 220, 220))
            screen.blit(label, (10 + i*110, HEIGHT-30))

        pygame.display.flip()
        clock.tick(15)

    pygame.quit()
    sys.exit(0)

if __name__ == "__main__":
    main()
