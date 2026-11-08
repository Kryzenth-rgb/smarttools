import 'package:flutter/material.dart';

class UnitDef {
  final String id;
  final String name;
  final String symbol;
  // Valeur de l'unité exprimée dans l'unité de base de la catégorie.
  final double factor;

  const UnitDef(this.id, this.name, this.symbol, [this.factor = 1]);
}

class UnitCategory {
  final String id;
  final String name;
  final IconData icon;
  final List<UnitDef> units;

  const UnitCategory(this.id, this.name, this.icon, this.units);

  bool get isTemperature => id == 'temperature';
}

const List<UnitCategory> unitCategories = [
  UnitCategory('length', 'Longueur', Icons.straighten_rounded, [
    UnitDef('mm', 'Millimètre', 'mm', 0.001),
    UnitDef('cm', 'Centimètre', 'cm', 0.01),
    UnitDef('m', 'Mètre', 'm', 1),
    UnitDef('km', 'Kilomètre', 'km', 1000),
    UnitDef('in', 'Pouce', 'in', 0.0254),
    UnitDef('ft', 'Pied', 'ft', 0.3048),
    UnitDef('yd', 'Yard', 'yd', 0.9144),
    UnitDef('mi', 'Mile', 'mi', 1609.344),
  ]),
  UnitCategory('mass', 'Masse', Icons.scale_rounded, [
    UnitDef('mg', 'Milligramme', 'mg', 0.000001),
    UnitDef('g', 'Gramme', 'g', 0.001),
    UnitDef('kg', 'Kilogramme', 'kg', 1),
    UnitDef('t', 'Tonne', 't', 1000),
    UnitDef('oz', 'Once', 'oz', 0.028349523125),
    UnitDef('lb', 'Livre', 'lb', 0.45359237),
  ]),
  UnitCategory('temperature', 'Température', Icons.thermostat_rounded, [
    UnitDef('c', 'Celsius', '°C'),
    UnitDef('f', 'Fahrenheit', '°F'),
    UnitDef('k', 'Kelvin', 'K'),
  ]),
  UnitCategory('volume', 'Volume', Icons.science_rounded, [
    UnitDef('ml', 'Millilitre', 'ml', 0.001),
    UnitDef('l', 'Litre', 'l', 1),
    UnitDef('m3', 'Mètre cube', 'm³', 1000),
    UnitDef('gal', 'Gallon US', 'gal', 3.785411784),
  ]),
  UnitCategory('speed', 'Vitesse', Icons.speed_rounded, [
    UnitDef('ms', 'Mètre par seconde', 'm/s', 1),
    UnitDef('kmh', 'Kilomètre par heure', 'km/h', 1 / 3.6),
    UnitDef('mph', 'Mile par heure', 'mph', 0.44704),
    UnitDef('kn', 'Nœud', 'kn', 1852 / 3600),
  ]),
  UnitCategory('area', 'Surface', Icons.crop_square_rounded, [
    UnitDef('cm2', 'Centimètre carré', 'cm²', 0.0001),
    UnitDef('m2', 'Mètre carré', 'm²', 1),
    UnitDef('km2', 'Kilomètre carré', 'km²', 1000000),
    UnitDef('ha', 'Hectare', 'ha', 10000),
    UnitDef('ft2', 'Pied carré', 'ft²', 0.09290304),
    UnitDef('ac', 'Acre', 'ac', 4046.8564224),
  ]),
  UnitCategory('time', 'Temps', Icons.schedule_rounded, [
    UnitDef('s', 'Seconde', 's', 1),
    UnitDef('min', 'Minute', 'min', 60),
    UnitDef('h', 'Heure', 'h', 3600),
    UnitDef('d', 'Jour', 'j', 86400),
    UnitDef('w', 'Semaine', 'sem', 604800),
  ]),
];

double _toKelvin(String id, double v) {
  switch (id) {
    case 'c':
      return v + 273.15;
    case 'f':
      return (v - 32) * 5 / 9 + 273.15;
    default:
      return v;
  }
}

double _fromKelvin(String id, double k) {
  switch (id) {
    case 'c':
      return k - 273.15;
    case 'f':
      return (k - 273.15) * 9 / 5 + 32;
    default:
      return k;
  }
}

double convertValue(
  UnitCategory category,
  UnitDef from,
  UnitDef to,
  double value,
) {
  if (category.isTemperature) {
    return _fromKelvin(to.id, _toKelvin(from.id, value));
  }
  return value * from.factor / to.factor;
}

String formatResult(double v) {
  if (v.isNaN || v.isInfinite) return '—';
  if (v == 0) return '0';
  final abs = v.abs();
  if (abs < 0.0001 || abs >= 1e10) {
    return v.toStringAsExponential(6);
  }
  var s = v.toStringAsFixed(6);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
  }
  if (s == '-0') s = '0';
  return s;
}
