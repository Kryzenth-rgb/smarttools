import 'dart:math' as math;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String appVersion = '0.1.0';

typedef InfoRow = (String, String);

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  late final Future<List<InfoRow>> _future = _loadDevice();
  List<InfoRow> _deviceRows = <InfoRow>[];

  Future<List<InfoRow>> _loadDevice() async {
    try {
      final rows = await _readDevice();
      if (mounted) _deviceRows = rows;
      return rows;
    } catch (_) {
      return const [
        ('Informations', 'Non disponibles sur cette plateforme'),
      ];
    }
  }

  Future<List<InfoRow>> _readDevice() async {
    final plugin = DeviceInfoPlugin();
    if (kIsWeb) {
      final w = await plugin.webBrowserInfo;
      return [
        ('Plateforme', 'Navigateur Web'),
        ('Navigateur', w.browserName.name),
        ('Système (navigateur)', w.platform ?? 'Inconnu'),
        ('Agent utilisateur', w.userAgent ?? 'Inconnu'),
      ];
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final a = await plugin.androidInfo;
        return [
          ('Fabricant', a.manufacturer),
          ('Marque', a.brand),
          ('Modèle', a.model),
          ('Système', 'Android ${a.version.release} (API ${a.version.sdkInt})'),
          (
            'Architecture',
            a.supportedAbis.isEmpty ? 'Inconnue' : a.supportedAbis.join(', ')
          ),
          ('Appareil physique', a.isPhysicalDevice ? 'Oui' : 'Non'),
        ];
      case TargetPlatform.iOS:
        final i = await plugin.iosInfo;
        return [
          ('Fabricant', 'Apple'),
          ('Modèle', i.model),
          ('Identifiant du modèle', i.utsname.machine),
          ('Système', '${i.systemName} ${i.systemVersion}'),
          ('Appareil physique', i.isPhysicalDevice ? 'Oui' : 'Non'),
        ];
      default:
        return [('Plateforme', defaultTargetPlatform.name)];
    }
  }

  List<InfoRow> _screenRows(BuildContext context) {
    final mq = MediaQuery.of(context);
    final ratio = mq.devicePixelRatio;
    final w = mq.size.width;
    final h = mq.size.height;
    return [
      ('Taille (points)', '${w.round()} × ${h.round()}'),
      ('Résolution (pixels)', '${(w * ratio).round()} × ${(h * ratio).round()}'),
      ('Densité', '× ${ratio.toStringAsFixed(2)}'),
      (
        'Orientation',
        mq.orientation == Orientation.portrait ? 'Portrait' : 'Paysage'
      ),
      ('Plus petit côté', '${math.min(w, h).round()} points'),
    ];
  }

  List<InfoRow> _appRows() {
    return [
      ('Application', 'SmartTools'),
      ('Version', appVersion),
      ('Éditeur', 'SmartLife Apps'),
      ('Exécution', kIsWeb ? 'Navigateur Web' : defaultTargetPlatform.name),
    ];
  }

  Future<void> _copyAll() async {
    final buffer = StringBuffer();
    void add(String title, List<InfoRow> rows) {
      buffer.writeln('== $title ==');
      for (final r in rows) {
        buffer.writeln('${r.$1} : ${r.$2}');
      }
      buffer.writeln();
    }

    add('Appareil', _deviceRows);
    add('Écran', _screenRows(context));
    add('Application', _appRows());
    await Clipboard.setData(ClipboardData(text: buffer.toString().trim()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Informations copiées')),
    );
  }

  Widget _section(String title, List<InfoRow> rows) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final r in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.$1,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    SelectableText(
                      r.$2,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infos appareil'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Tout copier',
            icon: const Icon(Icons.copy_rounded),
            onPressed: _copyAll,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FutureBuilder<List<InfoRow>>(
              future: _future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _section('Appareil', snapshot.data!);
              },
            ),
            _section('Écran', _screenRows(context)),
            _section('Application', _appRows()),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Seules les informations accessibles sans permission '
                'particulière sont affichées. Rien n’est envoyé.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
