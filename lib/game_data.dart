class GameData {
  List<String> playerNames;
  Map<int, int> pars;
  Map<int, List<int>> scores;
  DateTime date;

  GameData({
    this.playerNames = const [],
    this.pars = const {},
    this.scores = const {},
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'playerNames': playerNames,
    'pars': pars.map((key, value) => MapEntry(key.toString(), value)),
    'scores': scores.map((key, value) => MapEntry(key.toString(), value)),
    'date': date.toIso8601String(),
    // No need to serialize 'winner' as it's derived from scores
  };

  factory GameData.fromJson(Map<String, dynamic> json) => GameData(
    playerNames: List<String>.from(json['playerNames']),
    pars: Map<int, int>.from(json['pars'].map((key, value) => MapEntry(int.parse(key), value))),
    scores: Map<int, List<int>>.from(json['scores'].map((key, value) => MapEntry(int.parse(key), List<int>.from(value)))),
    date: DateTime.parse(json['date']),
  );
}