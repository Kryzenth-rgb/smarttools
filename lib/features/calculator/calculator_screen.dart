import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'expression_parser.dart';

// Mémoire temporaire : la sauvegarde sur l'appareil viendra à l'étape stockage.
final ValueNotifier<List<String>> calculatorHistory =
    ValueNotifier<List<String>>(<String>[]);

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';

  static const List<String> _operators = ['+', '-', '×', '÷'];

  static const List<List<String>> _rows = [
    ['C', '⌫', '(', ')'],
    ['7', '8', '9', '÷'],
    ['4', '5', '6', '×'],
    ['1', '2', '3', '−'],
    ['0', '.', '%', '+'],
    ['='],
  ];

  String? _tryEvaluate(String e) {
    try {
      return formatNumber(ExpressionParser(e).parse());
    } on FormatException {
      return null;
    }
  }

  String? get _preview {
    if (_expression.isEmpty) return null;
    if (!_expression.contains(RegExp(r'[+\-×÷%]'))) return null;
    final result = _tryEvaluate(_expression);
    if (result == _expression) return null;
    return result;
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _input(String raw) {
    final s = raw == '−' ? '-' : raw;
    setState(() {
      if (_operators.contains(s) || s == '%') {
        if (_expression.isEmpty) {
          if (s == '-') _expression = '-';
          return;
        }
        final last = _expression[_expression.length - 1];
        if (s == '%') {
          if (_operators.contains(last) || last == '(') return;
        } else {
          if (_operators.contains(last)) {
            _expression =
                _expression.substring(0, _expression.length - 1) + s;
            return;
          }
          if (last == '(' && s != '-') return;
        }
      }
      if (s == '.') {
        final m = RegExp(r'[0-9.]*$').firstMatch(_expression);
        if (m != null && m.group(0)!.contains('.')) return;
      }
      _expression += s;
    });
  }

  void _equals() {
    if (_expression.isEmpty) return;
    try {
      final result = formatNumber(ExpressionParser(_expression).parse());
      final entry = '$_expression = $result';
      calculatorHistory.value =
          [entry, ...calculatorHistory.value].take(50).toList();
      setState(() => _expression = result);
    } on FormatException catch (e) {
      _snack(e.message);
    }
  }

  Future<void> _copy() async {
    final text = _preview ?? _expression;
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    _snack('Copié : $text');
  }

  void _showHistory() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: ValueListenableBuilder<List<String>>(
            valueListenable: calculatorHistory,
            builder: (ctx, items, _) {
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Aucun calcul pour le moment.'),
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final e in items)
                          ListTile(
                            title: Text(e),
                            onTap: () {
                              final r = e.split(' = ').last;
                              setState(() => _expression = r);
                              Navigator.pop(ctx);
                            },
                          ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => calculatorHistory.value = <String>[],
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Effacer l’historique'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _key(String label) {
    final scheme = Theme.of(context).colorScheme;
    Color bg = scheme.surface;
    Color fg = scheme.onSurface;
    VoidCallback onTap = () => _input(label);
    Widget child = Text(
      label,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    );

    if (label == 'C') {
      onTap = () => setState(() => _expression = '');
      bg = scheme.errorContainer;
      fg = scheme.onErrorContainer;
    } else if (label == '⌫') {
      onTap = () {
        if (_expression.isEmpty) return;
        setState(() =>
            _expression = _expression.substring(0, _expression.length - 1));
      };
      child = const Icon(Icons.backspace_outlined);
      bg = scheme.errorContainer;
      fg = scheme.onErrorContainer;
    } else if (label == '=') {
      onTap = _equals;
      bg = scheme.primary;
      fg = Colors.white;
    } else if (['÷', '×', '−', '+', '%', '(', ')'].contains(label)) {
      bg = scheme.secondaryContainer;
      fg = scheme.onSecondaryContainer;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: DefaultTextStyle(
            style: TextStyle(color: fg),
            child: IconTheme(
              data: IconThemeData(color: fg),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final preview = _preview;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculatrice'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Copier le résultat',
            icon: const Icon(Icons.copy_rounded),
            onPressed: _copy,
          ),
          IconButton(
            tooltip: 'Historique',
            icon: const Icon(Icons.history_rounded),
            onPressed: _showHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _expression.isEmpty ? '0' : _expression,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      preview != null ? '= $preview' : ' ',
                      style: TextStyle(
                        fontSize: 20,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  children: [
                    for (final row in _rows)
                      Expanded(
                        child: Row(
                          children: [
                            for (final label in row)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: _key(label),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
