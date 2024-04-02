import 'package:flutter/foundation.dart';
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
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue, // Example primary color for light theme
        scaffoldBackgroundColor: Colors.white, // Light mode background color
        // Define other theme properties for light mode
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Button color for light mode
            foregroundColor: Colors.black, // Text color for light mode
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey, // Example primary color for dark theme
        scaffoldBackgroundColor: Colors.black, // Dark mode background color
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          // Add other text styles as needed
        ),
        // Define other theme properties for dark mode
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey, // Button color for dark mode
            foregroundColor: Colors.white, // Text color for dark mode
          ),
        ),
      ),
      themeMode: ThemeMode.system, // Use the system theme setting (light/dark)
      title: 'Mini Golf Score App',
      home: const MainMenu(),
    );
  }
}
