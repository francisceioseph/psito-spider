import 'package:flutter/material.dart';
import 'package:psito_games_ui/psito_games_ui.dart';

import '../../../l10n/app_localizations.dart';
import '../../../l10n/l10n.dart';
import '../../game/game_controller.dart';
import '../../game/game_state.dart';
import '../../game/scores.dart';
import '../../version.dart';
import 'victory_panel.dart';

/// What Psito Spider says about itself.
GameInfo spiderInfo(AppLocalizations l10n) => GameInfo(
  title: l10n.appTitle,
  version: appVersion,
  howToPlay: l10n.howToPlayBody,
  about: l10n.aboutBody,
  legal: l10n.aboutLegal,
  site: 'https://francisceioseph.github.io/psito-spider/',
);

/// "2 suits, medium", for the menu of suits.
String suitsDetail(AppLocalizations l10n, Suits suits) => l10n.suitsChoice(
  l10n.suitCount(suits.count),
  switch (suits) {
    Suits.one => l10n.easy,
    Suits.two => l10n.medium,
    Suits.four => l10n.hard,
  },
);

/// The bar of the table: the game number, the points, the clock, the hint,
/// the undo and the number of suits.
class SpiderBar extends StatelessWidget {
  const SpiderBar({super.key, required this.game});

  static const _suitsInWords = 1440.0;

  final GameController game;

  void _chooseSuits(Suits suits) {
    game.newGame(null, suits);
    const ScoreStore().saveSuits(suits);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ui = context.gamesUi;
    return GameBar(
      info: spiderInfo(l10n),
      onNewGame: game.newGame,
      onBestGames: () =>
          showBestGames(context, SpiderBestGames(initial: game.suits)),
      menu: [
        GameMenuEntry(
          label: ui.chooseGame,
          onSelected: () => showDialog<void>(
            context: context,
            builder: (_) => ChooseGameDialog(onChosen: game.newGame),
          ),
        ),
        GameMenuEntry(label: '${ui.restart}  (Ctrl+R)', onSelected: game.restart),
      ],
      stats: (space) => StatsPill(
        children: [
          if (!space.narrow)
            StatTile(label: ui.statGame, value: '${game.number}'),
          StatTile(label: l10n.statScore, value: '${game.score}'),
          ClockStat(seconds: () => game.seconds),
        ],
      ),
      actions: (space) => [
        BarButton(
          tooltip: '${l10n.hint}  (H)',
          icon: Icons.lightbulb_outline_rounded,
          onPressed: game.state.isWon ? null : game.hint,
        ),
        BarButton(
          tooltip: '${ui.undo}  (Ctrl+Z)',
          icon: Icons.undo_rounded,
          onPressed: game.canUndo ? game.undo : null,
        ),
        ChoiceButton<Suits>(
          tooltip: ui.difficulty,
          current: game.suits,
          choices: Suits.values,
          icon: Icons.style_outlined,
          // With the hint and the undo, the words only fit in wide windows.
          iconOnly: space.width < _suitsInWords,
          label: (suits) => l10n.suitCount(suits.count),
          menuLabel: (suits) => suitsDetail(l10n, suits),
          onSelected: _chooseSuits,
        ),
      ],
    );
  }
}

/// The best games of each number of suits, starting from the one being
/// played.
class SpiderBestGames extends StatefulWidget {
  const SpiderBestGames({super.key, required this.initial});

  final Suits initial;

  @override
  State<SpiderBestGames> createState() => _SpiderBestGamesState();
}

class _SpiderBestGamesState extends State<SpiderBestGames> {
  late Suits _suits = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<Suits>(
          showSelectedIcon: false,
          selected: {_suits},
          onSelectionChanged: (chosen) => setState(() => _suits = chosen.single),
          segments: [
            for (final suits in Suits.values)
              ButtonSegment(
                value: suits,
                label: Text(l10n.suitCount(suits.count)),
              ),
          ],
        ),
        const SizedBox(height: 14),
        FutureBuilder<List<Score>>(
          key: ValueKey(_suits),
          future: const ScoreStore().load(_suits),
          builder: (context, snapshot) =>
              SpiderScoreTable(scores: snapshot.data ?? const []),
        ),
      ],
    );
  }
}
