#!/usr/bin/env python3
"""Generate the launch-screen glyph for Valizim.

Same dependency-free approach as tool/generate_app_icons.py, but writes RGBA so
the glyph sits on the storyboard's adaptive background instead of a hard-coded
colour. Re-run after changing ACCENT:

    python3 tool/generate_launch_assets.py
"""

import os
import struct
import zlib

import generate_app_icons as icons

LAUNCH_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "ios", "Runner", "Assets.xcassets", "LaunchImage.imageset",
)

# Logical size of the glyph on screen; @2x and @3x follow.
BASE = 96
SUPERSAMPLE = 3


def glyph_alpha(x, y):
    """Coverage of the suitcase shape at a normalised point."""
    if y < 0.345:
        outer = icons.rounded_rect(x, y, 0.5, 0.335, 0.115, 0.075, 0.055)
        inner = icons.rounded_rect(x, y, 0.5, 0.335, 0.075, 0.045, 0.032)
        if outer and not inner:
            return 255
    if icons.rounded_rect(x, y, 0.5, 0.56, 0.29, 0.215, 0.045):
        for offset in (-0.10, 0.10):
            if abs(x - (0.5 + offset)) <= 0.014:
                return 0
        return 255
    return 0


def render(size):
    step = 1.0 / (size * SUPERSAMPLE)
    n = SUPERSAMPLE * SUPERSAMPLE
    rows = []
    for py in range(size):
        row = bytearray()
        for px in range(size):
            a = 0
            for sy in range(SUPERSAMPLE):
                y = (py * SUPERSAMPLE + sy + 0.5) * step
                for sx in range(SUPERSAMPLE):
                    x = (px * SUPERSAMPLE + sx + 0.5) * step
                    a += glyph_alpha(x, y)
            row += bytes((icons.ACCENT[0], icons.ACCENT[1], icons.ACCENT[2], a // n))
        rows.append(bytes(row))
    return rows


def write_rgba_png(path, rows, size):
    raw = b"".join(b"\x00" + row for row in rows)

    def chunk(tag, data):
        body = tag + data
        return (struct.pack(">I", len(data)) + body
                + struct.pack(">I", zlib.crc32(body) & 0xFFFFFFFF))

    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(raw, 9))
    png += chunk(b"IEND", b"")
    with open(path, "wb") as handle:
        handle.write(png)


def main():
    for scale, name in ((1, "LaunchImage.png"),
                        (2, "LaunchImage@2x.png"),
                        (3, "LaunchImage@3x.png")):
        size = BASE * scale
        write_rgba_png(os.path.join(LAUNCH_DIR, name), render(size), size)
        print("  %-24s %4dpx" % (name, size))


if __name__ == "__main__":
    main()
