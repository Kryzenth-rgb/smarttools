import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class AlertService {
  static final AudioPlayer _player = AudioPlayer();
  static Uint8List? _wav;

  static Uint8List _buildWav() {
    const sampleRate = 22050;
    final pcm = <int>[];
    for (var b = 0; b < 3; b++) {
      const n = sampleRate * 300 ~/ 1000;
      for (var i = 0; i < n; i++) {
        final edge = math.min(i, n - i) / 200.0;
        final fade = math.min(1.0, edge);
        final v = math.sin(2 * math.pi * 880 * i / sampleRate) * 0.8 * fade;
        pcm.add((v * 32767).round());
      }
      const gap = sampleRate * 200 ~/ 1000;
      for (var i = 0; i < gap; i++) {
        pcm.add(0);
      }
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

  static Future<void> ring() async {
    try {
      _wav ??= _buildWav();
      await _player.stop();
      await _player.play(
        BytesSource(_wav!, mimeType: 'audio/wav'),
        volume: 1.0,
      );
    } catch (_) {
      // Son indisponible sur cet appareil : on continue sans bloquer.
    }
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
