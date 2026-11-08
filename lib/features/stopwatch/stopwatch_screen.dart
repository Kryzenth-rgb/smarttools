import 'dart:async';

import 'package:flutter/material.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _sw = Stopwatch();
  final List<Duration> _laps = <Duration>[];
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    final cs = ((d.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s.$cs' : '$m:$s.$cs';
  }

  void _start() {
    _sw.start();
    _ticker?.cancel();
    _ticker = Timer.periodic(
      const Duration(milliseconds: 50),
      (_) => setState(() {}),
    );
    setState(() {});
  }

  void _pause() {
    _sw.stop();
    _ticker?.cancel();
    setState(() {});
  }

  void _reset() {
    _sw.reset();
    _ticker?.cancel();
    setState(() => _laps.clear());
  }

  void _lap() {
    setState(() => _laps.add(_sw.elapsed));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final running = _sw.isRunning;
    final started = _sw.elapsed > Duration.zero;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chronomètre'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _fmt(_sw.elapsed),
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          running ? _lap : (started ? _reset : null),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: Text(running ? 'Tour' : 'Réinitialiser'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: running ? _pause : _start,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: Text(
                        running
                            ? 'Pause'
                            : (started ? 'Reprendre' : 'Démarrer'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _laps.isEmpty
                    ? const Center(child: Text('Aucun tour enregistré.'))
                    : ListView.builder(
                        itemCount: _laps.length,
                        itemBuilder: (context, i) {
                          final index = _laps.length - 1 - i;
                          final total = _laps[index];
                          final lap =
                              index == 0 ? total : total - _laps[index - 1];
                          return ListTile(
                            leading: Text('Tour ${index + 1}'),
                            title: Text(_fmt(lap)),
                            trailing: Text(
                              _fmt(total),
                              style:
                                  TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
