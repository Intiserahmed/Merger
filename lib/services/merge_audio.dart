// lib/services/merge_audio.dart
//
// Generates Do-Re-Mi sine-wave tones in memory and plays them via audioplayers.
// Successive merges advance up the scale (Do→Re→Mi→Fa→Sol→La→Ti→Do…).

import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

class MergeAudio {
  MergeAudio._();
  static final MergeAudio instance = MergeAudio._();

  final _player = AudioPlayer();
  int _comboIndex = 0;

  // Do-Re-Mi-Fa-Sol-La-Ti in Hz
  static const _scale = [261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88];

  Future<void> playMerge() async {
    final freq = _scale[_comboIndex % _scale.length];
    _comboIndex++;
    try {
      final wav = _buildWav(freq, durationSecs: 0.18);
      await _player.play(BytesSource(wav), volume: 0.45);
    } catch (_) {
      // Silently ignore audio errors (e.g. simulator without audio)
    }
  }

  void resetCombo() => _comboIndex = 0;

  // ── WAV builder ────────────────────────────────────────────────────────

  static Uint8List _buildWav(double frequency, {double durationSecs = 0.2}) {
    const sampleRate = 44100;
    final numSamples = (sampleRate * durationSecs).round();
    final dataLen = numSamples * 2; // 16-bit mono

    final buf = BytesBuilder();

    void str(String s) => buf.add(s.codeUnits);
    void u32(int v) => buf.add([v & 0xff, (v >> 8) & 0xff, (v >> 16) & 0xff, (v >> 24) & 0xff]);
    void u16(int v) => buf.add([v & 0xff, (v >> 8) & 0xff]);

    // RIFF header
    str('RIFF'); u32(36 + dataLen);
    str('WAVE');
    // fmt chunk
    str('fmt '); u32(16); u16(1); u16(1);
    u32(sampleRate); u32(sampleRate * 2); u16(2); u16(16);
    // data chunk
    str('data'); u32(dataLen);

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      // Bell-shaped amplitude envelope
      final env = math.sin(math.pi * i / numSamples);
      final raw = (math.sin(2 * math.pi * frequency * t) * 14000 * env).round();
      final clamped = raw.clamp(-32768, 32767);
      u16(clamped & 0xffff);
    }

    return buf.toBytes();
  }
}
