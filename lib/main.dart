import 'package:flutter/material.dart';
import 'package:mini_golf/main_menu.dart';

void main() {
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
