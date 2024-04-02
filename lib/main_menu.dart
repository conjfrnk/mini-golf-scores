import 'package:flutter/material.dart';
import 'package:mini_golf_scores/scorekeeper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  void _showLoadGameDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final gameKeys = prefs.getKeys()
        .where((key) => key.startsWith('game_'))
        .toList();

    if (gameKeys.isEmpty) {
      // No games found, show a SnackBar instead
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved games found.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select a Game to Load'),
          content: SingleChildScrollView(
            child: ListBody(
              children: gameKeys.map((key) {
                return ListTile(
                  title: Text(key.substring(5).substring(0, 16).replaceAll(
                      "T", " ")),
                  onTap: () {
                    _loadGame(context, key);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadGame(BuildContext context, String gameKey) async {
    final prefs = await SharedPreferences.getInstance();
    final gameDataJson = prefs.getString(gameKey);
    if (gameDataJson != null) {
      final gameData = jsonDecode(gameDataJson);
      // Assuming gameData structure. Convert data types as necessary.
      Navigator.of(context).pop(); // Close the selection dialog
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ScoreKeeper(
                isNewGame: false,
                playerNames: List<String>.from(gameData['playerNames']),
                pars: Map.from(gameData['pars']).map((k, v) =>
                    MapEntry(int.parse(k), v)),
                scores: Map.from(gameData['scores']).map((k, v) =>
                    MapEntry(int.parse(k), List<int>.from(v))),
                gameCreationTime: DateTime.parse(gameData['creationTime']),
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Golf Main Menu'),
      ),
      body: Column(
        children: [
          const Spacer(),
          // Pushes everything below it towards the middle and bottom of the screen
          // Main action buttons centered in the middle of the screen
          ElevatedButton(
            child: const Text('Start New Game'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ScoreKeeper(isNewGame: true)),
              );
            },
          ),
          const SizedBox(height: 16),
          // Space between the buttons
          ElevatedButton(
            child: const Text('Load Game'),
            onPressed: () => _showLoadGameDialog(context),
          ),
          const Spacer(),
          // This will push the bottom content to the bottom of the screen
          // Information buttons at the bottom
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // Space out the buttons evenly in the Row
            children: [
              // About Button
              ElevatedButton(
                onPressed: () async {
                  PackageInfo packageInfo = await PackageInfo.fromPlatform();
                  String version = packageInfo.version;

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('About'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              const Text('Mini Golf Scorekeeper App'),
                              const Text('Made by Connor Frank'),
                              const Text('Princeton NJ'),
                              const Text(''),
                              Text('Version: $version'), // Display app version
                              const Text(''),
                              const Text('Mini Golf Scores  Copyright (C) 2024 Connor Frank'),
                              const Text('This program comes with ABSOLUTELY NO WARRANTY.'),
                              const Text('This is free software, and you are welcome to redistribute it under certain conditions.'),
                              const Text('View \'Licenses\' in main menu for details.'),
                              // Add more about info here
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('About'),
              ),
              // License Button
              ElevatedButton(
                onPressed: () async {
                  PackageInfo packageInfo = await PackageInfo.fromPlatform();
                  String version = packageInfo.version;
                  // Action for License button
                  showLicensePage(
                    context: context,
                    applicationName: 'Mini Golf Scores',
                    applicationVersion: version,
                    applicationLegalese: '© 2024 Connor Frank'
                  );
                },
                child: const Text('License'),
              ),
              // GitHub Link Button
              ElevatedButton(
                onPressed: () async {
                  Uri link = Uri(scheme: 'https',
                    host: 'github.com',
                    path: '/conjfrnk/mini-golf-scores');
                  if (await canLaunchUrl(link)) {
                    await launchUrl(link);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open GitHub')),
                    );
                  }
                },
                child: const Text(
                    'GitHub'), // You can use an Icon instead: Icon(Icons.link)
              ),
              ElevatedButton(
                onPressed: () async {
                  Uri link = Uri(scheme: 'mailto',
                      path: 'conjfrnk+minigolf@gmail.com');
                  if (await canLaunchUrl(link)) {
                    await launchUrl(link);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open GitHub')),
                    );
                  }
                },
                child: const Text('Contact'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Ensures there's space at the very bottom
        ],
      ),
    );
  }
}