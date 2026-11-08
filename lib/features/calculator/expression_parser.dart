class ExpressionParser {
  final String _s;
  int _i = 0;

  ExpressionParser(String input)
      : _s = input
            .replaceAll(' ', '')
            .replaceAll('×', '*')
            .replaceAll('÷', '/')
            .replaceAll('−', '-')
            .replaceAll(',', '.');

  double parse() {
    if (_s.isEmpty) throw const FormatException('Expression vide');
    final value = _expr();
    if (_i != _s.length) throw const FormatException('Expression invalide');
    return value;
  }

  bool _peek(String c) => _i < _s.length && _s[_i] == c;

  double _expr() {
    var left = _term().$1;
    while (_peek('+') || _peek('-')) {
      final op = _s[_i++];
      final t = _term();
      // « 200 + 10% » signifie 200 + 10 % de 200
      final right = t.$2 ? left * t.$1 : t.$1;
      left = op == '+' ? left + right : left - right;
    }
    return left;
  }

  (double, bool) _term() {
    var (value, pct) = _factor();
    while (_peek('*') || _peek('/')) {
      final op = _s[_i++];
      final f = _factor();
      if (op == '*') {
        value *= f.$1;
      } else {
        if (f.$1 == 0) throw const FormatException('Division par zéro');
        value /= f.$1;
      }
      pct = false;
    }
    return (value, pct);
  }

  (double, bool) _factor() {
    if (_peek('-')) {
      _i++;
      final f = _factor();
      return (-f.$1, f.$2);
    }
    if (_peek('+')) {
      _i++;
      return _factor();
    }
    double v;
    if (_peek('(')) {
      _i++;
      v = _expr();
      if (!_peek(')')) throw const FormatException('Parenthèse manquante');
      _i++;
    } else {
      v = _number();
    }
    var pct = false;
    while (_peek('%')) {
      _i++;
      v /= 100;
      pct = true;
    }
    return (v, pct);
  }

  double _number() {
    final start = _i;
    while (_i < _s.length && (_isDigit(_s[_i]) || _s[_i] == '.')) {
      _i++;
    }
    if (start == _i) throw const FormatException('Expression invalide');
    final v = double.tryParse(_s.substring(start, _i));
    if (v == null) throw const FormatException('Nombre invalide');
    return v;
  }

  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
}

String formatNumber(double v) {
  if (v.isNaN || v.isInfinite) {
    throw const FormatException('Résultat invalide');
  }
  var s = v.toStringAsFixed(10);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
  }
  if (s == '-0') s = '0';
  return s;
}
