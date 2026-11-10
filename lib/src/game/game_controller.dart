import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'game_state.dart';

/// What the player is holding after a click.
@immutable
class Selection {
  const Selection(this.pile, this.count);

  final Pile pile;
  final int count;
}

/// Why the game cannot help with the stock.
enum DealRefusal { emptyColumn, noCards }

class _Snapshot {
  const _Snapshot(this.state, this.moves, this.score);

  final GameState state;
  final int moves;
  final int score;
}

/// A game in progress: the table, the score and the undo history.
class GameController extends ChangeNotifier {
  GameController({
    int? number,
    this.suits = Suits.one,
    this.hintTime = const Duration(milliseconds: 1400),
  }) : number = number ?? _randomNumber() {
    state = GameState.deal(this.number, suits);
  }

  static int _randomNumber() => Random().nextInt(999999) + 1;

  /// The classic scoring: 500 to start, one less for each move and 100 more
  /// for each sequence that reaches a nest.
  static const startScore = 500;
  static const nestPoints = 100;

  /// How long a hint stays lit.
  final Duration hintTime;

  int number;
  Suits suits;
  late GameState state;
  int moves = 0;
  int score = startScore;
  Selection? selected;

  /// The cards of the latest move, drawn above the others while they travel.
  Set<int> lastMoved = const {};

  /// The cards of the latest refused move. [rejectTick] tells them to shake.
  Set<int> rejected = const {};
  int rejectTick = 0;

  /// The cards lit by the latest hint, and whether it points at the stock.
  Set<int> hinted = const {};
  bool hintedStock = false;

  /// Why the latest deal was refused, until the next move. [refusalTick]
  /// tells the table to say it again.
  DealRefusal? refusal;
  int refusalTick = 0;

  /// Whether the latest move was a deal, so the row goes out one by one.
  bool dealt = false;

  /// Set when the latest hint found nothing at all to do.
  bool stuck = false;

  final List<_Snapshot> _history = [];
  final Stopwatch _clock = Stopwatch();
  Timer? _hintTimer;
  int _nextHint = 0;

  bool get canUndo => _history.isNotEmpty;

  /// The time played, from the first move until the win.
  int get seconds => _clock.elapsed.inSeconds;

  void newGame([int? number, Suits? suits]) {
    this.number = number ?? _randomNumber();
    if (suits != null) this.suits = suits;
    _restart();
  }

  void restart() => _restart();

  void _restart() {
    _clock
      ..stop()
      ..reset();
    state = GameState.deal(number, suits);
    moves = 0;
    score = startScore;
    selected = null;
    lastMoved = const {};
    dealt = false;
    rejected = const {};
    _history.clear();
    _forgetHint();
    _calm();
    notifyListeners();
  }

  void undo() {
    if (_history.isEmpty) return;
    final snapshot = _history.removeLast();
    state = snapshot.state;
    moves = snapshot.moves;
    // Taking a move back costs a point too, so undoing is never free.
    score = max(0, snapshot.score - 1);
    selected = null;
    lastMoved = const {};
    dealt = false;
    _forgetHint();
    _calm();
    notifyListeners();
  }

  void clearSelection() {
    if (selected == null) return;
    selected = null;
    notifyListeners();
  }

  void _calm() {
    refusal = null;
    stuck = false;
  }

  void _forgetHint() {
    _hintTimer?.cancel();
    hinted = const {};
    hintedStock = false;
    _nextHint = 0;
  }

  void _remember() => _history.add(_Snapshot(state, moves, score));

  void _advance(GameState next, Set<int> moved, {bool dealing = false}) {
    final collected = next.nests.length - state.nests.length;
    _remember();
    state = next;
    moves++;
    score = max(0, score - 1 + collected * nestPoints);
    selected = null;
    lastMoved = moved;
    dealt = dealing;
    rejected = const {};
    _forgetHint();
    _calm();
    _clock.start();
    if (state.isWon) _clock.stop();
    notifyListeners();
  }

  void _reject(Iterable<PlayingCard> cards) {
    rejected = {for (final card in cards) card.id};
    rejectTick++;
    selected = null;
    notifyListeners();
  }

  /// Refuses a pick up: the cards from [index] down are not in suit.
  void rejectPick(Pile pile, int index) {
    if (pile.kind != PileKind.column) return;
    _reject(state.columns[pile.index].sublist(index));
  }

  /// Deals a row, or says why it cannot.
  void deal() {
    final next = state.deal();
    if (next == null) {
      refusal = state.stock.isEmpty
          ? DealRefusal.noCards
          : DealRefusal.emptyColumn;
      refusalTick++;
      selected = null;
      notifyListeners();
      return;
    }
    _advance(
      next,
      {for (final card in state.stock.reversed.take(columnCount)) card.id},
      dealing: true,
    );
  }

  /// Moves the cards, or makes them shake if the rules do not allow it.
  bool moveCards(Pile from, int count, Pile to) {
    final next = state.move(from, count, to);
    if (next == null) {
      if (state.canPick(from, count)) _reject(state.cardsFrom(from, count));
      return false;
    }
    _advance(next, {for (final card in state.cardsFrom(from, count)) card.id});
    return true;
  }

  int _countFrom(Pile pile, int index) => state.columns[pile.index].length - index;

  /// A click on the card at [index] of [pile].
  void tapCard(Pile pile, int index) {
    if (pile.kind == PileKind.stock) {
      deal();
      return;
    }
    final held = selected;
    if (held != null) {
      if (held.pile == pile) {
        clearSelection();
      } else {
        moveCards(held.pile, held.count, pile);
      }
      return;
    }
    if (index < state.hidden[pile.index]) return;
    final count = _countFrom(pile, index);
    if (!state.canPick(pile, count)) {
      rejectPick(pile, index);
      return;
    }
    selected = Selection(pile, count);
    notifyListeners();
  }

  /// A click on an empty place.
  void tapEmpty(Pile pile) {
    if (pile.kind == PileKind.stock) {
      deal();
      return;
    }
    final held = selected;
    if (held != null) moveCards(held.pile, held.count, pile);
  }

  /// A double click: sends the cards to the best place there is.
  void sendAway(Pile pile, int index) {
    selected = null;
    if (index < state.hidden[pile.index]) return;
    final count = _countFrom(pile, index);
    final target = state.bestDestination(pile, count);
    if (target == null) {
      if (state.canPick(pile, count)) {
        _reject(state.cardsFrom(pile, count));
      } else {
        rejectPick(pile, index);
      }
      return;
    }
    moveCards(pile, count, target);
  }

  /// Lights the next useful move, then the stock, then says there is none.
  /// Pressing again shows the one after.
  void hint() {
    if (state.isWon) return;
    final hints = state.hints();
    final choices = hints.length + (state.canDeal ? 1 : 0);
    _hintTimer?.cancel();
    selected = null;
    if (choices == 0) {
      hinted = const {};
      hintedStock = false;
      stuck = true;
      refusalTick++;
      notifyListeners();
      return;
    }
    final pick = _nextHint % choices;
    _nextHint = pick + 1;
    if (pick < hints.length) {
      final shown = hints[pick];
      final from = state.columns[shown.from];
      hinted = {
        for (final card in from.sublist(from.length - shown.count)) card.id,
        state.columns[shown.to].last.id,
      };
      hintedStock = false;
    } else {
      hinted = const {};
      hintedStock = true;
    }
    notifyListeners();
    _hintTimer = Timer(hintTime, () {
      hinted = const {};
      hintedStock = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }
}
