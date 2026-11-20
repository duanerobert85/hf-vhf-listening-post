#!/usr/bin/env python3
"""
Minimal scanner GUI skeleton for HDMI.
Tries kmsdrm, then fbcon, then default.
"""
import os
import sys
import pygame

WIDTH, HEIGHT = 800, 480

def try_video():
    drivers = ["kmsdrm", "fbcon", "x11", "wayland", ""]
    for drv in drivers:
        if drv:
            os.environ["SDL_VIDEODRIVER"] = drv
        else:
            os.environ.pop("SDL_VIDEODRIVER", None)
        try:
            pygame.display.init()
            screen = pygame.display.set_mode((WIDTH, HEIGHT))
            print(f"Using video driver: {drv or 'default'}")
            return screen
        except pygame.error as e:
            print(f"Driver {drv or 'default'} failed: {e}")
            pygame.display.quit()
    raise RuntimeError("No working SDL video driver found")

def main():
    global WIDTH, HEIGHT
    pygame.init()
    screen = try_video()
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

        screen.fill((10, 20, 30))
        text = font.render(freq, True, (0, 255, 128))
        screen.blit(text, (30, 60))
        st = small.render(status, True, (255, 200, 0))
        screen.blit(st, (30, 130))

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
