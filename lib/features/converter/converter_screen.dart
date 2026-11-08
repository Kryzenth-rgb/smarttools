import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'converter_data.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _input = TextEditingController(text: '1');
  UnitCategory _cat = unitCategories.first;
  late UnitDef _from = _cat.units[0];
  late UnitDef _to = _cat.units[1];

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  String? get _result {
    final v = double.tryParse(_input.text.trim().replaceAll(',', '.'));
    if (v == null) return null;
    return formatResult(convertValue(_cat, _from, _to, v));
  }

  void _selectCategory(UnitCategory c) {
    setState(() {
      _cat = c;
      _from = c.units[0];
      _to = c.units[1];
    });
  }

  void _swap() {
    setState(() {
      final tmp = _from;
      _from = _to;
      _to = tmp;
    });
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copié : $text')),
    );
  }

  Widget _picker(UnitDef value, ValueChanged<UnitDef> onChanged) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButton<String>(
        value: value.id,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: [
          for (final u in _cat.units)
            DropdownMenuItem<String>(
              value: u.id,
              child: Text('${u.name} (${u.symbol})'),
            ),
        ],
        onChanged: (id) {
          if (id == null) return;
          onChanged(_cat.units.firstWhere((u) => u.id == id));
        },
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final result = _result;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convertisseur'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final c in unitCategories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: Icon(c.icon, size: 18),
                        label: Text(c.name),
                        selected: c.id == _cat.id,
                        onSelected: (_) => _selectCategory(c),
                      ),
                    ),
                ],
              ),
            ),
            _label('Valeur'),
            TextField(
              controller: _input,
              onChanged: (_) => setState(() {}),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\-]')),
              ],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                filled: true,
                fillColor: scheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            _label('De'),
            _picker(_from, (u) => setState(() => _from = u)),
            Center(
              child: IconButton.filledTonal(
                tooltip: 'Inverser les unités',
                icon: const Icon(Icons.swap_vert_rounded),
                onPressed: _swap,
              ),
            ),
            _label('Vers'),
            _picker(_to, (u) => setState(() => _to = u)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: result == null
                  ? const Text('Saisissez un nombre valide.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_input.text.trim()} ${_from.symbol} =',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: SelectableText(
                                '$result ${_to.symbol}',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Copier le résultat',
                              icon: const Icon(Icons.copy_rounded),
                              onPressed: () => _copy(result),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
