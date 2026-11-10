import 'package:flutter/material.dart';
import 'package:psito_games_ui/psito_games_ui.dart';

import '../../../l10n/l10n.dart';
import '../../game/game_controller.dart';
import '../../game/scores.dart';

/// The best games: the most points first, and the time for the ties.
class SpiderScoreTable extends StatelessWidget {
  const SpiderScoreTable({super.key, required this.scores, this.highlight});

  final List<Score> scores;
  final Score? highlight;

  @override
  Widget build(BuildContext context) => ScoreTable<Score>(
    scores: scores,
    highlight: highlight,
    name: (score) => score.name,
    details: (score) => [
      Text(context.l10n.points(score.points)),
      const SizedBox(width: 12),
      SizedBox(
        width: 48,
        child: Text(formatTime(score.seconds), textAlign: TextAlign.end),
      ),
    ],
  );
}

/// Asks for the winner's name and shows where the game landed among the
/// games with the same number of suits.
class VictoryPanel extends StatelessWidget {
  const VictoryPanel({super.key, required this.game, required this.store});

  final GameController game;
  final ScoreStore store;

  Future<Widget> _save(String name) async {
    final suits = game.suits;
    final mine = Score(
      name: name,
      points: game.score,
      seconds: game.seconds,
      game: game.number,
    );
    final scores = insertScore(await store.load(suits), mine);
    await store.save(suits, scores);
    await store.saveName(name);
    return SpiderScoreTable(scores: scores, highlight: mine);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return VictoryCard(
      title: l10n.youWon,
      summary: l10n.winSummary(
        l10n.points(game.score),
        formatTime(game.seconds),
      ),
      lastName: store.lastName,
      onSave: _save,
      onNewGame: game.newGame,
    );
  }
}
