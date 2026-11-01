#!/usr/bin/env python3
"""Draws Xlin-soft's six built-in gradient wallpapers.
Needs Pillow and numpy. Run: python3 scripts/make-wallpapers.py   -> assets/wallpapers/*.jpg"""
import os

import numpy as np
from PIL import Image

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "wallpapers")
W, H = 2560, 1440

# name: (top-left colour, bottom-right colour). Six plain gradients; users add their own in Settings -> Desktop.
WALLS = {
    "light":      ("#f8f9fc", "#d9dfeb"),
    "dark":       ("#15171d", "#2a2e3a"),
    "dark-blue":  ("#0a1a38", "#24509c"),
    "light-blue": ("#eaf3ff", "#a4c8f7"),
    "dark-green": ("#08201a", "#1f6048"),
    "light-pink": ("#fff3f7", "#f6bdd2"),
}


def rgb(h):
    h = h.lstrip("#")
    return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], dtype=np.float32)


def draw(name, spec, seed):
    a, b = spec
    xs = np.linspace(0, 1, W, dtype=np.float32)[None, :]
    ys = np.linspace(0, 1, H, dtype=np.float32)[:, None]
    t = ((xs * W + ys * H) / (W + H))[..., None]           # diagonal, top-left to bottom-right
    img = rgb(a) * (1 - t) + rgb(b) * t
    rng = np.random.default_rng(seed)
    img += rng.normal(0, 1.2, (H, W, 1)).astype(np.float32)   # a little grain, hides banding
    return Image.fromarray(np.clip(img, 0, 255).astype(np.uint8))


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for i, (n, spec) in enumerate(WALLS.items()):
        im = draw(n, spec, i)
        im.save(os.path.join(OUT, f"xlin-{n}.jpg"), quality=90, optimize=True)
        print("wrote", n)
