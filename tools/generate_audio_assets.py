#!/usr/bin/env python3
"""Generate the original adaptive music layers with no external dependencies."""

from __future__ import annotations

import math
import random
import struct
import wave
from pathlib import Path

RATE = 22050
ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets" / "audio"
TAU = math.tau


def write_wav(name: str, samples: list[float]) -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    peak = max(1.0, max(abs(sample) for sample in samples))
    with wave.open(str(OUTPUT / name), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(RATE)
        output.writeframes(b"".join(struct.pack("<h", int(max(-1.0, min(1.0, sample / peak)) * 30000)) for sample in samples))


def music_layer(drive: bool) -> list[float]:
    duration = 8.0
    count = int(duration * RATE)
    bpm = 120.0
    beat = 60.0 / bpm
    notes = [110.0, 146.83, 164.81, 130.81, 110.0, 196.0, 164.81, 146.83]
    rng = random.Random(7331 if drive else 1337)
    result: list[float] = []
    for index in range(count):
        time = index / RATE
        beat_index = int(time / beat) % len(notes)
        beat_phase = (time % beat) / beat
        note = notes[beat_index]
        if drive:
            gate = max(0.0, 1.0 - beat_phase * 3.2)
            pulse = math.sin(TAU * note * 2.0 * time) * 0.22 * gate
            tick = (rng.random() * 2.0 - 1.0) * 0.09 * max(0.0, 1.0 - (time % (beat / 2.0)) * 32.0)
            result.append(pulse + tick)
        else:
            pad = math.sin(TAU * note * time) * 0.16
            pad += math.sin(TAU * note * 1.5 * time) * 0.08
            bass = math.sin(TAU * (note / 2.0) * time) * 0.20
            pulse = 0.72 + 0.28 * math.sin(TAU * time / beat)
            result.append((pad + bass) * pulse)
    fade = int(0.08 * RATE)
    for index in range(fade):
        factor = index / fade
        result[index] *= factor
        result[-index - 1] *= factor
    return result


def main() -> None:
    write_wav("music_base.wav", music_layer(False))
    write_wav("music_drive.wav", music_layer(True))


if __name__ == "__main__":
    main()
