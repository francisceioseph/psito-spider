import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psito_games_ui/psito_games_ui.dart';

import '../../game/game_controller.dart';
import '../../game/game_state.dart';
import '../../game/scores.dart';
import '../atoms/card_face.dart';
import '../organisms/board.dart';
import '../organisms/spider_bar.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.number, this.suits});

  /// A fixed game number. Without one, the deal is random.
  final int? number;

  /// A fixed number of suits. Without one, the last one chosen.
  final Suits? suits;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController _game = GameController(
    number: widget.number,
    suits: widget.suits ?? Suits.one,
  );
  bool _precached = false;

  @override
  void initState() {
    super.initState();
    if (widget.suits == null) _restoreSuits();
  }

  /// The game opens with the suits of the last one, before any move.
  Future<void> _restoreSuits() async {
    final suits = await const ScoreStore().lastSuits();
    if (!mounted || suits == _game.suits || _game.moves > 0) return;
    _game.newGame(_game.number, suits);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    for (final path in allCardArt()) {
      precacheImage(AssetImage(path), context);
    }
    precacheImage(const AssetImage('assets/slots/nest.png'), context);
  }

  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _game,
    builder: (context, board) => GameTable(
      shortcuts: {
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
            _game.undo,
        const SingleActivator(LogicalKeyboardKey.keyN, control: true):
            _game.newGame,
        const SingleActivator(LogicalKeyboardKey.keyR, control: true):
            _game.restart,
        // The victory asks for a name, and these letters must reach it.
        if (!_game.state.isWon) ...{
          const SingleActivator(LogicalKeyboardKey.keyH): _game.hint,
          const SingleActivator(LogicalKeyboardKey.keyD): _game.deal,
        },
      },
      bar: SpiderBar(game: _game),
      board: board!,
    ),
    child: Board(game: _game),
  );
}
