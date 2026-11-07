#!/usr/bin/env python3
"""Generate a Tokyo Night mountains wallpaper. Deterministic (fixed seed).

usage: python3 wallpapers/generate.py [out.png] [width] [height]
"""
import random
import sys

from PIL import Image, ImageDraw, ImageFilter

OUT = sys.argv[1] if len(sys.argv) > 1 else "wallpapers/tokyo-night-mountains.png"
W = int(sys.argv[2]) if len(sys.argv) > 2 else 2560
H = int(sys.argv[3]) if len(sys.argv) > 3 else 1440
random.seed(1337)


def hex2rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def lerp(a, b, t):
    return tuple(round(x + (y - x) * t) for x, y in zip(a, b))


# --- sky gradient: night bg -> storm -> faint purple/blue glow at horizon ---
stops = [(0.0, "#16161e"), (0.35, "#1a1b26"), (0.55, "#24283b"), (0.68, "#3d3f72"), (0.80, "#6b4f9a"), (1.0, "#6b4f9a")]
sky = Image.new("RGB", (W, H))
px = sky.load()
for y in range(H):
    t = y / (H - 1)
    for (t0, c0), (t1, c1) in zip(stops, stops[1:]):
        if t0 <= t <= t1:
            col = lerp(hex2rgb(c0), hex2rgb(c1), (t - t0) / (t1 - t0))
            break
    for x in range(W):
        px[x, y] = col
img = sky.convert("RGBA")

# --- stars ---
stars = Image.new("RGBA", (W, H), (0, 0, 0, 0))
d = ImageDraw.Draw(stars)
for _ in range(int(W * H / 5000)):
    x, y = random.randrange(W), random.randrange(int(H * 0.65))
    r = random.choice([1, 1, 1, 1.5, 2])
    a = random.randint(60, 200)
    col = random.choice(["#c0caf5", "#c0caf5", "#7dcfff", "#bb9af7"])
    d.ellipse([x - r, y - r, x + r, y + r], fill=hex2rgb(col) + (a,))
img = Image.alpha_composite(img, stars)

# --- moon with glow ---
mx, my, mr = int(W * 0.74), int(H * 0.24), int(H * 0.055)
glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
ImageDraw.Draw(glow).ellipse([mx - mr * 4, my - mr * 4, mx + mr * 4, my + mr * 4], fill=hex2rgb("#7aa2f7") + (55,))
img = Image.alpha_composite(img, glow.filter(ImageFilter.GaussianBlur(mr * 1.6)))
moon = Image.new("RGBA", (W, H), (0, 0, 0, 0))
ImageDraw.Draw(moon).ellipse([mx - mr, my - mr, mx + mr, my + mr], fill=hex2rgb("#c0caf5") + (240,))
img = Image.alpha_composite(img, moon.filter(ImageFilter.GaussianBlur(1.2)))


# --- mountain ridges via midpoint displacement ---
def ridge(base, rough, seg=8, peaks=6):
    pts = [base + random.uniform(-rough, rough) for _ in range(peaks)]
    disp = rough * 0.6
    for _ in range(seg):
        nxt = []
        for a, b in zip(pts, pts[1:]):
            nxt += [a, (a + b) / 2 + random.uniform(-disp, disp)]
        nxt.append(pts[-1])
        pts, disp = nxt, disp * 0.55
    step = W / (len(pts) - 1)
    return [(i * step, y) for i, y in enumerate(pts)]


layers = [  # (baseline, roughness, color, alpha, haze blur)
    (0.66, 0.11, "#414868", 235, 2),
    (0.74, 0.09, "#2f334d", 255, 1),
    (0.83, 0.07, "#24283b", 255, 0),
    (0.92, 0.05, "#16161e", 255, 0),
]
for base, rough, col, a, blur in layers:
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    poly = ridge(base * H, rough * H) + [(W, H), (0, H)]
    ImageDraw.Draw(layer).polygon(poly, fill=hex2rgb(col) + (a,))
    if blur:
        layer = layer.filter(ImageFilter.GaussianBlur(blur))
    img = Image.alpha_composite(img, layer)

img.convert("RGB").save(OUT, optimize=True)
print(f"wrote {OUT} ({W}x{H})")
