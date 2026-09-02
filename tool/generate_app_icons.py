#!/usr/bin/env python3
"""Generate placeholder iOS app icons for Valizim.

Deliberately dependency-free (stdlib zlib only) so a clean checkout can
regenerate the icon set without installing Pillow or ImageMagick.

These are PLACEHOLDERS. When studio artwork arrives, either replace the PNGs in
ios/Runner/Assets.xcassets/AppIcon.appiconset/ directly, or change ACCENT below
and re-run:

    python3 tool/generate_app_icons.py

iOS app icons must be fully opaque, so this writes RGB (no alpha channel).
"""

import json
import os
import struct
import zlib

ACCENT = (0x0D, 0x94, 0x88)   # keep in step with AppTheme.seed
GLYPH = (0xFF, 0xFF, 0xFF)

ICON_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset",
)

MASTER = 1024
SUPERSAMPLE = 2


def rounded_rect(x, y, cx, cy, hw, hh, r):
    """True when (x, y) is inside a rounded rectangle, all in 0..1 units."""
    dx = abs(x - cx) - (hw - r)
    dy = abs(y - cy) - (hh - r)
    if dx <= 0 and dy <= 0:
        return True
    dx = dx if dx > 0 else 0.0
    dy = dy if dy > 0 else 0.0
    return dx * dx + dy * dy <= r * r


def sample(x, y):
    """Colour at a normalised point: a suitcase, which is what 'valiz' means."""
    # Handle: a ring above the body, with only its upper half visible.
    if y < 0.345:
        outer = rounded_rect(x, y, 0.5, 0.335, 0.115, 0.075, 0.055)
        inner = rounded_rect(x, y, 0.5, 0.335, 0.075, 0.045, 0.032)
        if outer and not inner:
            return GLYPH

    # Body.
    if rounded_rect(x, y, 0.5, 0.56, 0.29, 0.215, 0.045):
        # Two straps punched back out to the background colour.
        for offset in (-0.10, 0.10):
            if abs(x - (0.5 + offset)) <= 0.014:
                return ACCENT
        return GLYPH

    return ACCENT


def render_master():
    """Render the 1024px master with supersampled edges."""
    step = 1.0 / (MASTER * SUPERSAMPLE)
    rows = []
    for py in range(MASTER):
        row = bytearray()
        for px in range(MASTER):
            r = g = b = 0
            for sy in range(SUPERSAMPLE):
                y = (py * SUPERSAMPLE + sy + 0.5) * step
                for sx in range(SUPERSAMPLE):
                    x = (px * SUPERSAMPLE + sx + 0.5) * step
                    c = sample(x, y)
                    r += c[0]
                    g += c[1]
                    b += c[2]
            n = SUPERSAMPLE * SUPERSAMPLE
            row += bytes((r // n, g // n, b // n))
        rows.append(bytes(row))
    return rows


def downsample(master, size):
    """Area-average the master down to `size`, which keeps edges smooth."""
    if size == MASTER:
        return master
    scale = MASTER / size
    out = []
    for y in range(size):
        y0 = int(y * scale)
        y1 = max(y0 + 1, int((y + 1) * scale))
        row = bytearray()
        for x in range(size):
            x0 = int(x * scale)
            x1 = max(x0 + 1, int((x + 1) * scale))
            r = g = b = n = 0
            for sy in range(y0, min(y1, MASTER)):
                src = master[sy]
                for sx in range(x0, min(x1, MASTER)):
                    i = sx * 3
                    r += src[i]
                    g += src[i + 1]
                    b += src[i + 2]
                    n += 1
            row += bytes((r // n, g // n, b // n))
        out.append(bytes(row))
    return out


def write_png(path, rows, size):
    raw = b"".join(b"\x00" + row for row in rows)

    def chunk(tag, data):
        body = tag + data
        return (struct.pack(">I", len(data)) + body
                + struct.pack(">I", zlib.crc32(body) & 0xFFFFFFFF))

    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 2, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(raw, 9))
    png += chunk(b"IEND", b"")
    with open(path, "wb") as handle:
        handle.write(png)


def required_sizes():
    """Pixel sizes named by the asset catalogue, so nothing is missed."""
    with open(os.path.join(ICON_DIR, "Contents.json")) as handle:
        manifest = json.load(handle)
    wanted = {}
    for image in manifest["images"]:
        base = float(image["size"].split("x")[0])
        scale = int(image["scale"].rstrip("x"))
        wanted[image["filename"]] = int(round(base * scale))
    return wanted


def main():
    wanted = required_sizes()
    print("rendering %dpx master..." % MASTER)
    master = render_master()
    for filename, size in sorted(wanted.items(), key=lambda kv: -kv[1]):
        write_png(os.path.join(ICON_DIR, filename), downsample(master, size), size)
        print("  %-32s %4dpx" % (filename, size))
    print("wrote %d icons" % len(wanted))


if __name__ == "__main__":
    main()
