#!/usr/bin/env python3
"""
Generate 16-bit style sound effects for StarshipLander game.
Creates retro chiptune-style WAV files for game events.

Usage: python3 generate_sounds.py
Output: Creates WAV files in ../RocketLander/Sounds/
"""

import wave
import struct
import math
import os
import random

# Audio settings
SAMPLE_RATE = 44100
CHANNELS = 1
SAMPLE_WIDTH = 2  # 16-bit

def create_wav(filename, samples):
    """Write samples to a WAV file."""
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(CHANNELS)
        wav_file.setsampwidth(SAMPLE_WIDTH)
        wav_file.setframerate(SAMPLE_RATE)

        # Convert to 16-bit integers
        for sample in samples:
            # Clamp to valid range
            sample = max(-1.0, min(1.0, sample))
            packed = struct.pack('<h', int(sample * 32767))
            wav_file.writeframes(packed)

def square_wave(frequency, duration, volume=0.5):
    """Generate a square wave (classic 8-bit sound)."""
    samples = []
    num_samples = int(SAMPLE_RATE * duration)
    period = SAMPLE_RATE / frequency

    for i in range(num_samples):
        if (i % period) < (period / 2):
            samples.append(volume)
        else:
            samples.append(-volume)

    return samples

def triangle_wave(frequency, duration, volume=0.5):
    """Generate a triangle wave."""
    samples = []
    num_samples = int(SAMPLE_RATE * duration)
    period = SAMPLE_RATE / frequency

    for i in range(num_samples):
        t = (i % period) / period
        if t < 0.5:
            samples.append(volume * (4 * t - 1))
        else:
            samples.append(volume * (3 - 4 * t))

    return samples

def noise(duration, volume=0.5):
    """Generate white noise."""
    samples = []
    num_samples = int(SAMPLE_RATE * duration)

    for _ in range(num_samples):
        samples.append(random.uniform(-volume, volume))

    return samples

def apply_envelope(samples, attack=0.01, decay=0.1, sustain=0.7, release=0.1):
    """Apply ADSR envelope to samples."""
    total_samples = len(samples)
    attack_samples = int(attack * SAMPLE_RATE)
    decay_samples = int(decay * SAMPLE_RATE)
    release_samples = int(release * SAMPLE_RATE)
    sustain_samples = total_samples - attack_samples - decay_samples - release_samples

    result = []
    for i, sample in enumerate(samples):
        if i < attack_samples:
            # Attack phase
            envelope = i / attack_samples
        elif i < attack_samples + decay_samples:
            # Decay phase
            decay_pos = (i - attack_samples) / decay_samples
            envelope = 1.0 - (1.0 - sustain) * decay_pos
        elif i < attack_samples + decay_samples + sustain_samples:
            # Sustain phase
            envelope = sustain
        else:
            # Release phase
            release_pos = (i - attack_samples - decay_samples - sustain_samples) / release_samples
            envelope = sustain * (1.0 - release_pos)

        result.append(sample * envelope)

    return result

def mix_samples(*sample_lists):
    """Mix multiple sample lists together."""
    max_len = max(len(s) for s in sample_lists)
    result = [0.0] * max_len

    for samples in sample_lists:
        for i, sample in enumerate(samples):
            result[i] += sample

    # Normalize to prevent clipping
    max_val = max(abs(s) for s in result) or 1.0
    if max_val > 1.0:
        result = [s / max_val for s in result]

    return result

def generate_thrust():
    """Generate engine thrust sound (loopable rumble)."""
    duration = 0.5  # Short loop

    # Low frequency rumble using multiple square waves
    base_freq = 55  # Low A

    samples1 = square_wave(base_freq, duration, 0.3)
    samples2 = square_wave(base_freq * 1.5, duration, 0.2)
    samples3 = square_wave(base_freq * 2, duration, 0.15)

    # Add some noise for texture
    noise_samples = noise(duration, 0.15)

    # Mix together
    result = mix_samples(samples1, samples2, samples3, noise_samples)

    # Slight fade at ends for smooth looping
    fade_samples = int(0.02 * SAMPLE_RATE)
    for i in range(fade_samples):
        factor = i / fade_samples
        result[i] *= factor
        result[-(i+1)] *= factor

    return result

def generate_rotate():
    """Generate rotation blip sound."""
    duration = 0.08

    # Quick descending tone
    samples = []
    num_samples = int(SAMPLE_RATE * duration)

    for i in range(num_samples):
        t = i / num_samples
        # Frequency sweep from 880Hz to 440Hz
        freq = 880 - (440 * t)
        period = SAMPLE_RATE / freq

        if (i % period) < (period / 2):
            samples.append(0.4)
        else:
            samples.append(-0.4)

    # Apply quick envelope
    result = apply_envelope(samples, attack=0.005, decay=0.02, sustain=0.5, release=0.03)

    return result

def generate_land_success():
    """Generate triumphant landing fanfare."""
    # Classic 8-bit victory jingle
    notes = [
        (523, 0.1),   # C5
        (659, 0.1),   # E5
        (784, 0.1),   # G5
        (1047, 0.3),  # C6 (hold)
    ]

    all_samples = []

    for freq, dur in notes:
        note_samples = square_wave(freq, dur, 0.35)
        note_samples = apply_envelope(note_samples, attack=0.01, decay=0.05, sustain=0.7, release=0.05)
        all_samples.extend(note_samples)
        # Small gap between notes
        all_samples.extend([0.0] * int(0.02 * SAMPLE_RATE))

    # Add a final chord
    chord_dur = 0.4
    chord1 = square_wave(523, chord_dur, 0.25)  # C5
    chord2 = square_wave(659, chord_dur, 0.25)  # E5
    chord3 = square_wave(784, chord_dur, 0.25)  # G5

    chord = mix_samples(chord1, chord2, chord3)
    chord = apply_envelope(chord, attack=0.02, decay=0.1, sustain=0.6, release=0.2)

    all_samples.extend(chord)

    return all_samples

def generate_explosion():
    """Generate 8-bit explosion sound."""
    duration = 0.6

    # Start with noise
    noise_samples = noise(duration, 0.7)

    # Add some low frequency punch
    low_samples = square_wave(60, duration, 0.4)

    # Mix
    result = mix_samples(noise_samples, low_samples)

    # Apply explosive envelope (quick attack, long decay)
    result = apply_envelope(result, attack=0.005, decay=0.1, sustain=0.3, release=0.4)

    # Add pitch-dropping effect
    final = []
    num_samples = len(result)
    for i, sample in enumerate(result):
        # Modulate with dropping frequency
        t = i / num_samples
        mod_freq = 200 * (1 - t * 0.8)
        mod = math.sin(2 * math.pi * mod_freq * i / SAMPLE_RATE)
        final.append(sample * (0.5 + 0.5 * mod))

    return final

def main():
    # Create output directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_dir = os.path.join(script_dir, '..', 'RocketLander', 'Sounds')
    os.makedirs(output_dir, exist_ok=True)

    print("Generating 16-bit sound effects...")

    # Generate thrust sound
    print("  - thrust.wav")
    thrust_samples = generate_thrust()
    create_wav(os.path.join(output_dir, 'thrust.wav'), thrust_samples)

    # Generate rotate sound
    print("  - rotate.wav")
    rotate_samples = generate_rotate()
    create_wav(os.path.join(output_dir, 'rotate.wav'), rotate_samples)

    # Generate landing success sound
    print("  - land_success.wav")
    success_samples = generate_land_success()
    create_wav(os.path.join(output_dir, 'land_success.wav'), success_samples)

    # Generate explosion sound
    print("  - explosion.wav")
    explosion_samples = generate_explosion()
    create_wav(os.path.join(output_dir, 'explosion.wav'), explosion_samples)

    print(f"\nSound files created in: {output_dir}")
    print("\nTo add to Xcode project:")
    print("1. Open RocketLander.xcworkspace in Xcode")
    print("2. Right-click on RocketLander folder in navigator")
    print("3. Select 'Add Files to RocketLander...'")
    print("4. Select the Sounds folder and click Add")
    print("5. Make sure 'Copy items if needed' is checked")

if __name__ == '__main__':
    main()
