import 'package:flutter/material.dart';
import 'package:mini_golf_scores/scorekeeper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  void _showLoadGameDialog(BuildContext context) async {
    final localContext = context;
    final prefs = await SharedPreferences.getInstance();
    final gameKeys = prefs.getKeys()
        .where((key) => key.startsWith('game_'))
        .toList();

    if (gameKeys.isEmpty) {
      ScaffoldMessenger.of(localContext).showSnackBar(
        const SnackBar(content: Text('No saved games found.')),
      );
      return;
    }

    showDialog(
      context: localContext,
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
                    _loadGame(localContext, key);
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
    final localContext = context;
    final prefs = await SharedPreferences.getInstance();
    final gameDataJson = prefs.getString(gameKey);
    if (gameDataJson != null) {
      final gameData = jsonDecode(gameDataJson);
      Navigator.of(localContext).pop(); // Close the selection dialog
      Navigator.push(
        localContext,
        MaterialPageRoute(
          builder: (localContext) =>
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

  void showAboutDialog(BuildContext context) async {
    final localContext = context;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    showDialog(
      context: localContext,
      builder: (BuildContext localContext) {
        return AlertDialog(
          title: const Text('About'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Mini Golf Scorekeeper App'),
                const Text('Made by Connor Frank'),
                const Text('Princeton NJ ca. April 2024'),
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
              child: const Text('Contact Me'),
              onPressed: () async {
                Uri link = Uri(scheme: 'mailto',
                    path: 'conjfrnk+minigolf@gmail.com',
                    query: 'subject=Mini Golf Scores App',
                );
                if (await canLaunchUrl(link)) {
                  await launchUrl(link);
                } else {
                  ScaffoldMessenger.of(localContext).showSnackBar(
                    const SnackBar(content: Text('Could not launch email client')),
                  );
                }
              },
            ),
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
  }

  @override
  Widget build(BuildContext context) {
    final localContext = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Golf Scores'),
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
                localContext,
                MaterialPageRoute(
                    builder: (localContext) => const ScoreKeeper(isNewGame: true)),
              );
            },
          ),
          const SizedBox(height: 16),
          // Space between the buttons
          ElevatedButton(
            child: const Text('Load Game'),
            onPressed: () => _showLoadGameDialog(localContext),
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
                onPressed: () {
                  showAboutDialog(localContext);
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
                    context: localContext,
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
                    ScaffoldMessenger.of(localContext).showSnackBar(
                      const SnackBar(content: Text('Could not open GitHub')),
                    );
                  }
                },
                child: const Text(
                    'GitHub'), // You can use an Icon instead: Icon(Icons.link)
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