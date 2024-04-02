C
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini_golf_scores/main_menu.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('LICENSE');
    yield LicenseEntryWithLineBreaks(['mini_golf_scores'], license);
  });
  runApp(const MiniGolfScoreApp());
}

class MiniGolfScoreApp extends StatelessWidget {
  const MiniGolfScoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mini Golf Score App',
      home: MainMenu(),
    );
  }
}
