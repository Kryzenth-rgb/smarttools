import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum _TimerState { idle, running, paused, finished }

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final TextEditingController _h = TextEditingController(text: '0');
  final TextEditingController _m = TextEditingController(text: '5');
  final TextEditingController _s = TextEditingController(text: '0');

  _TimerState _state = _TimerState.idle;
  Duration _total = Duration.zero;
  Duration _remaining = Duration.zero;
  DateTime? _endAt;
  Timer? _ticker;
  Timer? _alarm;

  @override
  void dispose() {
    _ticker?.cancel();
    _alarm?.cancel();
    _h.dispose();
    _m.dispose();
    _s.dispose();
    super.dispose();
  }

  int _val(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  String _fmt(Duration d) {
    final secs = (d.inMilliseconds + 999) ~/ 1000;
    final h = (secs ~/ 3600).toString().padLeft(2, '0');
    final m = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _start() {
    final d = Duration(hours: _val(_h), minutes: _val(_m), seconds: _val(_s));
    if (d == Duration.zero) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Définissez une durée.')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    _total = d;
    _remaining = d;
    _run();
  }

  void _run() {
    _endAt = DateTime.now().add(_remaining);
    _ticker?.cancel();
    _ticker = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => _tick(),
    );
    setState(() => _state = _TimerState.running);
  }

  void _tick() {
    final left = _endAt!.difference(DateTime.now());
    if (left <= Duration.zero) {
      _finish();
    } else {
      setState(() => _remaining = left);
    }
  }

  void _pause() {
    _ticker?.cancel();
    final left = _endAt!.difference(DateTime.now());
    setState(() {
      _remaining = left > Duration.zero ? left : Duration.zero;
      _state = _TimerState.paused;
    });
  }

  void _reset() {
    _ticker?.cancel();
    _alarm?.cancel();
    setState(() {
      _remaining = Duration.zero;
      _state = _TimerState.idle;
    });
  }

  void _ring() {
    HapticFeedback.vibrate();
    SystemSound.play(SystemSoundType.alert);
  }

  void _finish() {
    _ticker?.cancel();
    if (!mounted) return;
    setState(() {
      _remaining = Duration.zero;
      _state = _TimerState.finished;
    });
    _ring();
    _alarm?.cancel();
    _alarm = Timer.periodic(const Duration(seconds: 2), (_) => _ring());
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Temps écoulé'),
        content: Text('Le minuteur de ${_fmt(_total)} est terminé.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    ).then((_) => _alarm?.cancel());
  }

  void _preset(int minutes) {
    setState(() {
      _h.text = (minutes ~/ 60).toString();
      _m.text = (minutes % 60).toString();
      _s.text = '0';
    });
  }

  Widget _field(TextEditingController c, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextField(
          controller: c,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: scheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _field(_h, 'Heures'),
            _field(_m, 'Minutes'),
            _field(_s, 'Secondes'),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final min in const [1, 5, 10, 30])
              ActionChip(
                label: Text('$min min'),
                onPressed: () => _preset(min),
              ),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _start,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
          ),
          child: const Text('Démarrer'),
        ),
      ],
    );
  }

  Widget _buildRunning() {
    final scheme = Theme.of(context).colorScheme;
    final progress = _total.inMilliseconds == 0
        ? 0.0
        : _remaining.inMilliseconds / _total.inMilliseconds;
    final running = _state == _TimerState.running;
    final finished = _state == _TimerState.finished;
    return Column(
      children: [
        SizedBox(
          width: 260,
          height: 260,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 10,
                backgroundColor: scheme.secondaryContainer,
              ),
              Center(
                child: Text(
                  _fmt(_remaining),
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _reset,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: const Text('Réinitialiser'),
              ),
            ),
            if (!finished) ...[
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: running ? _pause : _run,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: Text(running ? 'Pause' : 'Reprendre'),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minuteur'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_state == _TimerState.idle) _buildSetup() else _buildRunning(),
          ],
        ),
      ),
    );
  }
}
