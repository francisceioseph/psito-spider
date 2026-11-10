import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game_state.dart';

/// A finished game. More points is better, and the time breaks the ties.
@immutable
class Score {
  const Score({
    required this.name,
    required this.points,
    required this.seconds,
    required this.game,
  });

  factory Score.fromJson(Map<String, dynamic> json) => Score(
    name: json['name'] as String,
    points: json['points'] as int,
    seconds: json['seconds'] as int,
    game: json['game'] as int,
  );

  final String name;
  final int points;
  final int seconds;
  final int game;

  Map<String, dynamic> toJson() => {
    'name': name,
    'points': points,
    'seconds': seconds,
    'game': game,
  };
}

const maxScores = 10;

/// The list with [score] in its place, keeping only the best ones.
List<Score> insertScore(List<Score> scores, Score score) {
  final sorted = [...scores, score]
    ..sort((a, b) {
      final byPoints = b.points.compareTo(a.points);
      return byPoints != 0 ? byPoints : a.seconds.compareTo(b.seconds);
    });
  return sorted.take(maxScores).toList();
}

/// The scores of each number of suits, the last name used and the suits
/// chosen. They stay on this computer.
class ScoreStore {
  const ScoreStore();

  static const _nameKey = 'player_name';
  static const _suitsKey = 'suits';

  static String _scoresKey(Suits suits) => 'scores_${suits.name}';

  Future<List<Score>> load(Suits suits) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scoresKey(suits));
    if (raw == null) return const [];
    try {
      return [
        for (final item in jsonDecode(raw) as List)
          Score.fromJson(item as Map<String, dynamic>),
      ];
    } on Object {
      // A damaged file must not stop the game.
      return const [];
    }
  }

  Future<void> save(Suits suits, List<Score> scores) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scoresKey(suits), jsonEncode(scores));
  }

  Future<String> lastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? '';
  }

  Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  /// The number of suits of the last game, one suit at first.
  Future<Suits> lastSuits() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_suitsKey);
    return Suits.values.firstWhere(
      (suits) => suits.name == name,
      orElse: () => Suits.one,
    );
  }

  Future<void> saveSuits(Suits suits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_suitsKey, suits.name);
  }
}
