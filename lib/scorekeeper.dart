import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ScoreKeeper extends StatefulWidget {
  final bool isNewGame;
  final List<String>? playerNames;
  final Map<int, int>? pars;
  final Map<int, List<int>>? scores;
  final DateTime? gameCreationTime;

  const ScoreKeeper({
    super.key,
    this.isNewGame = false,
    this.playerNames,
    this.pars,
    this.scores,
    this.gameCreationTime,
  });

  @override
  _ScoreKeeperState createState() => _ScoreKeeperState();
}

class _ScoreKeeperState extends State<ScoreKeeper> {
  late List<String> playerNames;
  late Map<int, int> pars;
  late Map<int, List<int>> scores;
  late DateTime gameCreationTime;
  late int _numberOfHoles;

  @override
  void initState() {
    super.initState();
    if (widget.isNewGame) {
      _numberOfHoles = 1;
      playerNames = [];
      pars = {1: 0};
      scores = {
        1: List.generate(playerNames.length, (_) => 0, growable: true),
      };
      gameCreationTime = DateTime.now();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _askForPlayerNames();
      });
    }
    else {
      // Use loaded data or initialize with default values
      playerNames = widget.playerNames ?? [];
      pars = widget.pars ?? {1: 0};
      scores = widget.scores ?? {
        1: List.generate(playerNames.length, (_) => 0, growable: true),
      };
      gameCreationTime = widget.gameCreationTime ?? DateTime.now();
      _numberOfHoles = scores.length;
    }
  }

  Future<void> _askForPlayerNames() async {
    TextEditingController controller = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Player Names'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Please enter player names, separated by commas.'),
                TextField(
                  controller: controller,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                // Splitting the input text by commas to get individual names
                setState(() {
                  playerNames = controller.text
                      .split(',')
                      .map((name) => name.trim())
                      .toList();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    final String timestamp = gameCreationTime.toIso8601String();
    final String gameKey = 'game_$timestamp'; // Unique key for each game

    // Convert maps with int keys to maps with String keys for JSON encoding
    final Map<String, int> parsAsStringKeys = pars.map((k, v) => MapEntry(k.toString(), v));
    final Map<String, List<int>> scoresAsStringKeys = scores.map((k, v) => MapEntry(k.toString(), v));

    final Map<String, dynamic> gameData = {
      'playerNames': playerNames,
      'pars': parsAsStringKeys,
      'scores': scoresAsStringKeys,
      'creationTime': timestamp,
    };

    await prefs.setString(gameKey, jsonEncode(gameData));
  }

  void _confirmDeleteGame(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Game"),
          content: const Text("Are you sure you want to delete this game? This action cannot be undone."),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                _deleteGame();
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Return to the main menu
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteGame() async {
    final prefs = await SharedPreferences.getInstance();
    final String timestamp = gameCreationTime.toIso8601String();
    final String gameKey = 'game_$timestamp'; // Unique key for each game
    await prefs.remove(gameKey); // Assuming game data is saved with this key
  }

  void _showHoleDetailsDialog(int holeNumber) {
    // Initialize text editing controllers for par and scores
    TextEditingController parController =
    TextEditingController(text: pars[holeNumber]?.toString());
    Map<String, TextEditingController> scoreControllers = {};
    for (var playerName in playerNames) {
      int playerIndex = playerNames.indexOf(playerName);
      scoreControllers[playerName] = TextEditingController(
          text: scores[holeNumber] != null &&
              scores[holeNumber]!.length > playerIndex
              ? scores[holeNumber]![playerIndex].toString()
              : '');
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Details for Hole $holeNumber'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: parController,
                  decoration: const InputDecoration(labelText: "Par"),
                  keyboardType: TextInputType.number,
                ),
                ...playerNames.map((name) => TextField(
                  controller: scoreControllers[name]!,
                  decoration: InputDecoration(labelText: "$name's Score"),
                  keyboardType: TextInputType.number,
                )),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                // Save the entered par and scores
                setState(() {
                  pars[holeNumber] = int.tryParse(parController.text) ?? 0;
                  scores[holeNumber] = playerNames
                      .map((name) =>
                  int.tryParse(scoreControllers[name]!.text) ?? 0)
                      .toList();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editPlayerNames() async {
    TextEditingController nameController = TextEditingController(
      text: playerNames.join(', '),
    );

    await showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Player Names'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Player 1, Player 2'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                final List<String> newNames = nameController.text
                    .split(',')
                    .map((name) => name.trim())
                    .toList();
                setState(() {
                  // Detect new players and add them
                  for (String newName in newNames) {
                    if (!playerNames.contains(newName)) {
                      playerNames.add(newName); // Add new player name
                      // Add a zero score for the new player in each hole
                      scores.forEach((hole, playerScores) {
                        // Ensure the scores list for each hole is growable
                        List<int> growableScores = List<int>.from(playerScores);
                        growableScores.add(
                            0); // Initialize with zero score for new player
                        scores[hole] =
                            growableScores; // Update with the modified scores list
                      });
                    }
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteLastHole() {
    if (scores.isEmpty) return; // No holes to delete
    print(_numberOfHoles);

    final lastHoleScores = scores[_numberOfHoles - 1];
    final isAllZeros =
        lastHoleScores != null && lastHoleScores.every((score) => score == 0);

    if (isAllZeros) {
      // If all scores are zeros, delete the last hole without confirmation
      setState(() {
        _numberOfHoles--;
        pars.remove(_numberOfHoles + 1);
        scores.remove(_numberOfHoles + 1);
      });
    } else {
      // If any score is not zero, ask for confirmation
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Last Hole?'),
            content: const Text(
                'This hole has scores. Are you sure you want to delete it?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Delete'),
                onPressed: () {
                  setState(() {
                    _numberOfHoles--;
                    pars.remove(_numberOfHoles + 1);
                    scores.remove(_numberOfHoles + 1);
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildHoleDetails(int holeNumber) {
    String scoreText;

    if (scores[holeNumber] != null) {
      scoreText = 'Par: ${pars[holeNumber]}';
      List<String> scoreDetails = [];
      for (int i = 0; i < playerNames.length; i++) {
        final playerName = playerNames[i];
        final playerScore = scores[holeNumber]!.length > i
            ? scores[holeNumber]![i].toString()
            : 'N/A';
        scoreDetails.add('$playerName: $playerScore');
      }
      scoreText += '  ${scoreDetails.join('  ')}';
    } else {
      scoreText = '  Tap to add scores';
    }

    return ListTile(
      title: Text('Hole $holeNumber'),
      subtitle: Text(scoreText),
      onTap: () => _showHoleDetailsDialog(holeNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Golf Score Keeper'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveGame,
            tooltip: 'Save Game',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDeleteGame(context),
            tooltip: 'Delete Game',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _numberOfHoles,
        itemBuilder: (context, index) {
          int holeNumber = index + 1;
          return _buildHoleDetails(holeNumber);
        },
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          // Adjust padding as needed
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: "deleteHole",
                onPressed: _deleteLastHole,
                tooltip: 'Delete Last Hole',
                backgroundColor: Colors.red,
                child: const Icon(
                    Icons.remove), // Optional: different color for delete
              ),
              const SizedBox(height: 16), // Space between the buttons
              FloatingActionButton(
                heroTag: "addHole",
                onPressed: () {
                  setState(() {
                    _numberOfHoles++; // Increment the number of holes
                    // Initialize par and scores for the new hole with defaults
                    pars[_numberOfHoles] = 0; // Assuming 0 as default par
                    scores[_numberOfHoles] = List.filled(playerNames.length, 0); // Initialize scores with 0
                  });
                },
                tooltip: 'Add New Hole',
                backgroundColor: Colors.green,
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.blueGrey[100],
        height: 60.0,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Total Par Display
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Total Par: ${pars.values.fold(0, (prev, par) => prev + par)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              // Divider between Total Par and Players' Scores
              const VerticalDivider(color: Colors.black),
              // Players' Scores
              ...playerNames.map((name) {
                // Calculate total score for each player
                int totalScore =
                scores.values.fold(0, (previousValue, holeScores) {
                  final index = playerNames.indexOf(name);
                  return previousValue +
                      (holeScores.length > index ? holeScores[index] : 0);
                });
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(name),
                      Text('Score: $totalScore'),
                    ],
                  ),
                );
              }),
              // Add an IconButton for editing player names
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _editPlayerNames();
                },
                tooltip: 'Edit Player Names',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
