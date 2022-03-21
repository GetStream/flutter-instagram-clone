import 'package:flutter/material.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final theme = AppTheme();
  runApp(StreamagramApp(appTheme: theme));
}
