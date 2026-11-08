import 'package:flutter/material.dart';

import '../models/tool.dart';
import 'calculator/calculator_screen.dart';
import 'converter/converter_screen.dart';
import 'stopwatch/stopwatch_screen.dart';
import 'timer/timer_screen.dart';

Widget? _screenFor(String id) {
  switch (id) {
    case 'calculator':
      return const CalculatorScreen();
    case 'converter':
      return const ConverterScreen();
    case 'stopwatch':
      return const StopwatchScreen();
    case 'timer':
      return const TimerScreen();
    default:
      return null;
  }
}

void openTool(BuildContext context, Tool tool) {
  markRecent(tool.id);
  final screen = _screenFor(tool.id);
  if (screen == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${tool.name} : bientôt disponible')),
    );
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => screen),
  );
}
