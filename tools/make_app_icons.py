"""Generate the app and tray icons (stdlib only, no Pillow needed).

Draws a deep-teal disc (the seed colour of the UI) with a white crescent, at
several sizes, and writes:

  app/assets/icons/tray.png                       32 x 32 (tray and toast icon)
  app/assets/icons/tray.ico                       16/24/32/48/64/256, PNG-compressed
  app/windows/runner/resources/app_icon.ico       same set (the runner icon)

Run from the repository root:  python -I tools/make_app_icons.py
The output is deterministic, so re-running it never changes the files.
"""
import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TEAL = (0x0F, 0x76, 0x6E)
WHITE = (0xFF, 0xFF, 0xFF)
SAMPLES = 4  # supersampling per axis


def inside(x, y, cx, cy, r):
    return (x - cx) ** 2 + (y - cy) ** 2 <= r * r


def pixel(px, py, size):
    """RGBA of one output pixel, averaged over SAMPLES x SAMPLES sub-samples."""
    r = g = b = a = 0.0
    for sy in range(SAMPLES):
        for sx in range(SAMPLES):
            x = (px + (sx + 0.5) / SAMPLES) / size
            y = (py + (sy + 0.5) / SAMPLES) / size
            if not inside(x, y, 0.5, 0.5, 0.47):
                continue
            colour = TEAL
            if inside(x, y, 0.47, 0.5, 0.27) and not inside(x, y, 0.58, 0.45, 0.23):
                colour = WHITE
            r += colour[0]
            g += colour[1]
            b += colour[2]
            a += 1
    total = SAMPLES * SAMPLES
    if a == 0:
        return (0, 0, 0, 0)
    return (round(r / a), round(g / a), round(b / a), round(255 * a / total))


def png(size):
    rows = bytearray()
    for py in range(size):
        rows.append(0)  # filter: none
        for px in range(size):
            rows.extend(pixel(px, py, size))

    def chunk(kind, data):
        body = kind + data
        return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body) & 0xFFFFFFFF)

    header = struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0)
    return (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", header)
        + chunk(b"IDAT", zlib.compress(bytes(rows), 9))
        + chunk(b"IEND", b"")
    )


def ico(sizes):
    images = [(s, png(s)) for s in sizes]
    out = struct.pack("<HHH", 0, 1, len(images))
    offset = 6 + 16 * len(images)
    for size, data in images:
        dim = 0 if size >= 256 else size
        out += struct.pack("<BBBBHHII", dim, dim, 0, 0, 1, 32, len(data), offset)
        offset += len(data)
    return out + b"".join(data for _, data in images)


def main():
    icons = ROOT / "app" / "assets" / "icons"
    icons.mkdir(parents=True, exist_ok=True)
    (icons / "tray.png").write_bytes(png(32))
    sizes = [16, 24, 32, 48, 64, 256]
    (icons / "tray.ico").write_bytes(ico(sizes))
    (ROOT / "app" / "windows" / "runner" / "resources" / "app_icon.ico").write_bytes(ico(sizes))
    print("icons written")


if __name__ == "__main__":
    main()
