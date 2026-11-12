"""Generates the two placeholder sounds bundled with the app (CC0, original work).

azan_default.wav  - a calm 11-second three-phrase tone melody. It is NOT an azan
                    recording; it exists so the app works out of the box. Users choose
                    their own azan file in Settings.
chime.wav         - a short two-note chime used for reminders.
"""
import math
import struct
import sys
import wave

RATE = 22050


def tone(freq, seconds, volume=0.5):
    n = int(RATE * seconds)
    out = []
    for i in range(n):
        t = i / RATE
        attack = min(1.0, t / 0.04)
        release = min(1.0, (seconds - t) / 0.25)
        env = max(0.0, min(attack, release))
        sample = math.sin(2 * math.pi * freq * t) + 0.3 * math.sin(2 * math.pi * freq * 2 * t)
        out.append(volume * env * sample / 1.3)
    return out


def silence(seconds):
    return [0.0] * int(RATE * seconds)


def write(path, samples):
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s)) * 32000)) for s in samples))


def main(out_dir):
    azan = []
    for phrase in ([392, 440, 494, 523], [523, 494, 440, 392], [440, 392, 349, 392]):
        for f in phrase:
            azan += tone(f, 0.7)
        azan += silence(0.4)
    write(f"{out_dir}/azan_default.wav", azan)
    write(f"{out_dir}/chime.wav", tone(880, 0.35, 0.4) + tone(660, 0.6, 0.4))


if __name__ == "__main__":
    main(sys.argv[1])
