import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  static const String _lowerChars = 'abcdefghijklmnopqrstuvwxyz';
  static const String _upperChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _digitChars = '0123456789';
  static const String _symbolChars = r'!@#$%^&*()-_=+[]{};:,.?';

  double _length = 16;
  bool _lower = true;
  bool _upper = true;
  bool _digits = true;
  bool _symbols = true;
  String _password = '';

  @override
  void initState() {
    super.initState();
    _password = _generate();
  }

  List<String> get _pools => [
        if (_lower) _lowerChars,
        if (_upper) _upperChars,
        if (_digits) _digitChars,
        if (_symbols) _symbolChars,
      ];

  String _generate() {
    final pools = _pools;
    if (pools.isEmpty) return '';
    final Random rnd;
    try {
      rnd = Random.secure();
    } catch (_) {
      return '';
    }
    final length = _length.round();
    final chars = <String>[];
    for (final p in pools) {
      chars.add(p[rnd.nextInt(p.length)]);
    }
    final all = pools.join();
    while (chars.length < length) {
      chars.add(all[rnd.nextInt(all.length)]);
    }
    chars.shuffle(rnd);
    return chars.join();
  }

  void _regenerate() => setState(() => _password = _generate());

  double get _bits {
    final size = _pools.join().length;
    if (size == 0) return 0;
    return _length.round() * (log(size) / ln2);
  }

  String get _strengthLabel {
    final b = _bits;
    if (b < 40) return 'Faible';
    if (b < 60) return 'Moyen';
    if (b < 80) return 'Fort';
    return 'Très fort';
  }

  Color get _strengthColor {
    final b = _bits;
    if (b < 40) return Colors.red;
    if (b < 60) return Colors.orange;
    if (b < 80) return Colors.green;
    return Colors.teal;
  }

  Future<void> _copy() async {
    if (_password.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _password));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mot de passe copié')),
    );
  }

  Widget _option(String label, bool value, void Function(bool) assign) {
    final enabledCount = [_lower, _upper, _digits, _symbols]
        .where((v) => v)
        .length;
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      onChanged: (v) {
        if (!v && enabledCount == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gardez au moins un type de caractère.'),
            ),
          );
          return;
        }
        setState(() {
          assign(v);
          _password = _generate();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mots de passe'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    _password.isEmpty ? '—' : _password,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_bits / 100).clamp(0.0, 1.0),
                      minHeight: 8,
                      color: _strengthColor,
                      backgroundColor: scheme.secondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Robustesse : $_strengthLabel',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _regenerate,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Régénérer'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _copy,
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Copier'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Longueur : ${_length.round()}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    value: _length,
                    min: 6,
                    max: 64,
                    divisions: 58,
                    label: '${_length.round()}',
                    onChanged: (v) {
                      setState(() {
                        _length = v;
                        _password = _generate();
                      });
                    },
                  ),
                  _option('Majuscules (A-Z)', _upper, (v) => _upper = v),
                  _option('Minuscules (a-z)', _lower, (v) => _lower = v),
                  _option('Chiffres (0-9)', _digits, (v) => _digits = v),
                  _option(
                    'Caractères spéciaux (!@#…)',
                    _symbols,
                    (v) => _symbols = v,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Généré sur votre appareil. Rien n’est envoyé ni enregistré.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
