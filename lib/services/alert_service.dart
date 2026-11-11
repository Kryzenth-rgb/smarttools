import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

class SoundOption {
  final String id;
  final String name;

  const SoundOption(this.id, this.name);
}

const List<SoundOption> soundOptions = [
  SoundOption('beep', 'Bip classique'),
  SoundOption('melody', 'Mélodie douce'),
  SoundOption('chime', 'Carillon'),
];

final ValueNotifier<String> soundChoiceNotifier =
    ValueNotifier<String>('beep');

class _Tone {
  final double freq;
  final int ms;
  final int gapMs;

  const _Tone(this.freq, this.ms, this.gapMs);
}

class AlertService {
  static final AudioPlayer _player = AudioPlayer();
  static final Map<String, Uint8List> _cache = <String, Uint8List>{};

  static List<_Tone> _tonesFor(String id) {
    switch (id) {
      case 'melody':
        return const [
          _Tone(523.25, 280, 40),
          _Tone(659.25, 280, 40),
          _Tone(783.99, 280, 40),
          _Tone(1046.5, 700, 400),
        ];
      case 'chime':
        return const [
          _Tone(1318.51, 250, 30),
          _Tone(987.77, 250, 30),
          _Tone(783.99, 250, 30),
          _Tone(987.77, 250, 30),
          _Tone(1318.51, 600, 400),
        ];
      default:
        return const [
          _Tone(880, 300, 200),
          _Tone(880, 300, 200),
          _Tone(880, 300, 200),
        ];
    }
  }

  static Uint8List _synth(List<_Tone> tones, {required bool bell}) {
    const sampleRate = 22050;
    final pcm = <int>[];
    for (final t in tones) {
      final n = sampleRate * t.ms ~/ 1000;
      for (var i = 0; i < n; i++) {
        final x = i / sampleRate;
        final attack = math.min(1.0, i / 150.0);
        final release = math.min(1.0, (n - i) / 300.0);
        final double env = bell ? math.exp(-4.0 * i / n) : 1.0;
        var wave = math.sin(2 * math.pi * t.freq * x);
        if (bell) {
          wave += 0.3 * math.sin(2 * math.pi * t.freq * 2 * x);
          wave += 0.1 * math.sin(2 * math.pi * t.freq * 3 * x);
          wave /= 1.4;
        }
        final v = wave * env * math.min(attack, release) * 0.8;
        pcm.add((v * 32767).round());
      }
      final gap = sampleRate * t.gapMs ~/ 1000;
      pcm.addAll(List<int>.filled(gap, 0));
    }

    final dataLen = pcm.length * 2;
    final bd = ByteData(44 + dataLen);
    void text(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        bd.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    text(0, 'RIFF');
    bd.setUint32(4, 36 + dataLen, Endian.little);
    text(8, 'WAVE');
    text(12, 'fmt ');
    bd.setUint32(16, 16, Endian.little);
    bd.setUint16(20, 1, Endian.little);
    bd.setUint16(22, 1, Endian.little);
    bd.setUint32(24, sampleRate, Endian.little);
    bd.setUint32(28, sampleRate * 2, Endian.little);
    bd.setUint16(32, 2, Endian.little);
    bd.setUint16(34, 16, Endian.little);
    text(36, 'data');
    bd.setUint32(40, dataLen, Endian.little);
    for (var i = 0; i < pcm.length; i++) {
      bd.setInt16(44 + i * 2, pcm[i], Endian.little);
    }
    return bd.buffer.asUint8List();
  }

  static Future<void> ring({String? soundId, bool vibrate = true}) async {
    final id = soundId ?? soundChoiceNotifier.value;
    try {
      final bytes = _cache.putIfAbsent(
        id,
        () => _synth(_tonesFor(id), bell: id != 'beep'),
      );
      await _player.stop();
      await _player.play(
        BytesSource(bytes, mimeType: 'audio/wav'),
        volume: 1.0,
      );
    } catch (_) {
      // Son indisponible sur cet appareil : on continue sans bloquer.
    }
    if (!vibrate) return;
    try {
      final has = await Vibration.hasVibrator();
      if (has == true) {
        await Vibration.vibrate(pattern: [0, 400, 200, 400, 200, 400]);
      }
    } catch (_) {
      // Vibration indisponible sur cet appareil.
    }
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    try {
      await Vibration.cancel();
    } catch (_) {}
  }
}
