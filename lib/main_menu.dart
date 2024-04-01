import 'package:flutter/material.dart';
import 'package:mini_golf/scorekeeper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  void _showLoadGameDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final gameKeys = prefs.getKeys().where((key) => key.startsWith('game_')).toList();

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
                  title: Text(key.substring(5).substring(0,16).replaceAll("T", " ")),
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
          builder: (context) => ScoreKeeper(
            isNewGame: false,
            playerNames: List<String>.from(gameData['playerNames']),
            pars: Map.from(gameData['pars']).map((k, v) => MapEntry(int.parse(k), v)),
            scores: Map.from(gameData['scores']).map((k, v) => MapEntry(int.parse(k), List<int>.from(v))),
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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              child: const Text('Start New Game'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScoreKeeper(isNewGame: true)),
                );
              },
            ),
            const SizedBox(height: 16), // Space between the buttons
            ElevatedButton(
              child: const Text('Load Game'),
              onPressed: () => _showLoadGameDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}
