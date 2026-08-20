#!/usr/bin/env python3
"""Generate the original Orbit Breaker sound pack with no external dependencies."""

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


def envelope(index: int, total: int, attack: float = 0.04, release: float = 0.28) -> float:
    progress = index / max(1, total - 1)
    return min(1.0, progress / attack) * min(1.0, (1.0 - progress) / release)


def write_wav(name: str, samples: list[float]) -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    peak = max(1.0, max(abs(sample) for sample in samples))
    with wave.open(str(OUTPUT / name), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(RATE)
        output.writeframes(b"".join(struct.pack("<h", int(max(-1.0, min(1.0, sample / peak)) * 30000)) for sample in samples))


def sweep(duration: float, start: float, finish: float, harmonics: tuple[float, ...], noise: float = 0.0) -> list[float]:
    rng = random.Random(90210 + int(start))
    count = int(duration * RATE)
    phase = 0.0
    result: list[float] = []
    for index in range(count):
        progress = index / count
        frequency = start * ((finish / start) ** progress)
        phase += TAU * frequency / RATE
        sample = sum(weight * math.sin(phase * (harmonic + 1)) for harmonic, weight in enumerate(harmonics))
        sample += (rng.random() * 2.0 - 1.0) * noise * (1.0 - progress)
        result.append(sample * envelope(index, count))
    return result


def chord(duration: float, notes: tuple[float, ...], shimmer: bool = False) -> list[float]:
    count = int(duration * RATE)
    phases = [0.0 for _ in notes]
    result: list[float] = []
    for index in range(count):
        progress = index / count
        sample = 0.0
        for note_index, note in enumerate(notes):
            phases[note_index] += TAU * note / RATE
            sample += math.sin(phases[note_index]) * (0.52 / len(notes))
            if shimmer:
                sample += math.sin(phases[note_index] * 2.01) * (0.14 / len(notes)) * progress
        result.append(sample * envelope(index, count, 0.025, 0.42))
    return result


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
    write_wav("launch.wav", sweep(0.22, 170.0, 1180.0, (0.62, 0.22, 0.09), 0.07))
    write_wav("land.wav", chord(0.30, (220.0, 329.63, 440.0), True))
    perfect = chord(0.62, (523.25, 659.25, 783.99, 1046.5), True)
    write_wav("perfect.wav", perfect)
    write_wav("fail.wav", sweep(0.70, 230.0, 42.0, (0.58, 0.20, 0.12), 0.16))
    write_wav("ui.wav", chord(0.10, (660.0, 990.0), True))
    write_wav("music_base.wav", music_layer(False))
    write_wav("music_drive.wav", music_layer(True))


if __name__ == "__main__":
    main()
