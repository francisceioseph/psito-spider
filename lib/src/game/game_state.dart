import 'package:flutter/foundation.dart';

/// The four suits. Clubs and spades are black; hearts and diamonds are red.
enum Suit {
  clubs,
  spades,
  hearts,
  diamonds;

  bool get isRed => this == hearts || this == diamonds;
}

/// How many suits the two decks have: one is the gentlest game, four the
/// hardest.
enum Suits {
  one(1),
  two(2),
  four(4);

  const Suits(this.count);

  final int count;

  /// The suits in play, spades first and hearts second.
  List<Suit> get suits => switch (this) {
    one => const [Suit.spades],
    two => const [Suit.spades, Suit.hearts],
    four => Suit.values,
  };
}

@immutable
class PlayingCard {
  const PlayingCard(this.suit, this.rank, [this.copy = 0])
    : assert(rank >= 1 && rank <= 13);

  final Suit suit;

  /// 1 is the ace, 11 the jack, 12 the queen and 13 the king.
  final int rank;

  /// Which of the equal cards this is: the game has up to eight of each.
  final int copy;

  /// A number that tells this card from every other one on the table.
  int get id => copy * 52 + suit.index * 13 + rank - 1;

  /// Any card one rank lower can rest on another.
  bool canRestOn(PlayingCard other) => rank == other.rank - 1;

  /// Only cards of the same suit move together.
  bool followsInSuit(PlayingCard other) =>
      canRestOn(other) && suit == other.suit;

  @override
  bool operator ==(Object other) =>
      other is PlayingCard &&
      other.suit == suit &&
      other.rank == rank &&
      other.copy == copy;

  @override
  int get hashCode => id;

  @override
  String toString() => '$rank${suit.name[0]}';
}

enum PileKind { column, stock, nest }

/// A place on the table where cards can be.
@immutable
class Pile {
  const Pile.column(this.index) : kind = PileKind.column;
  const Pile.stock() : kind = PileKind.stock, index = 0;
  const Pile.nest(this.index) : kind = PileKind.nest;

  final PileKind kind;
  final int index;

  @override
  bool operator ==(Object other) =>
      other is Pile && other.kind == kind && other.index == index;

  @override
  int get hashCode => Object.hash(kind, index);

  @override
  String toString() => '${kind.name}[$index]';
}

const columnCount = 10;
const nestCount = 8;

/// The 104 cards of two decks, with the suits of [suits] repeated to fill
/// them.
List<PlayingCard> spiderDeck(Suits suits) {
  final kinds = suits.suits;
  final copies = 8 ~/ kinds.length;
  return [
    for (var copy = 0; copy < copies; copy++)
      for (final suit in kinds)
        for (var rank = 1; rank <= 13; rank++) PlayingCard(suit, rank, copy),
  ];
}

/// Shuffles the decks for a game number. The same number always gives the
/// same deal, on every platform, because the generator is written here.
List<PlayingCard> shuffledDeck(int number, Suits suits) {
  final deck = spiderDeck(suits);
  var seed = number & 0x7fffffff;
  int next(int bound) {
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    return (seed >> 8) % bound;
  }

  for (var i = deck.length - 1; i > 0; i--) {
    final j = next(i + 1);
    final swap = deck[i];
    deck[i] = deck[j];
    deck[j] = swap;
  }
  return deck;
}

/// A move the game can suggest.
@immutable
class Hint {
  const Hint(this.from, this.count, this.to);

  final int from;
  final int count;
  final int to;
}

/// The table at one moment. It never changes: a move gives a new state.
@immutable
class GameState {
  const GameState({
    required this.columns,
    required this.hidden,
    required this.stock,
    required this.nests,
  });

  /// Four columns of six cards and six of five, only the last one face up,
  /// and the other fifty in the stock.
  factory GameState.deal(int number, Suits suits) {
    final deck = shuffledDeck(number, suits);
    final columns = <List<PlayingCard>>[];
    var taken = 0;
    for (var i = 0; i < columnCount; i++) {
      final size = i < 4 ? 6 : 5;
      columns.add(deck.sublist(taken, taken + size));
      taken += size;
    }
    return GameState(
      columns: columns,
      hidden: [for (final column in columns) column.length - 1],
      stock: deck.sublist(taken),
      nests: const [],
    );
  }

  final List<List<PlayingCard>> columns;

  /// How many cards at the start of each column are face down.
  final List<int> hidden;

  /// The cards still to be dealt. The last ten go out first.
  final List<PlayingCard> stock;

  /// Each complete sequence, king to ace, in the order they left.
  final List<List<PlayingCard>> nests;

  bool get isWon => nests.length == nestCount;

  /// How many more rows the stock can deal.
  int get dealsLeft => stock.length ~/ columnCount;

  bool get hasEmptyColumn => columns.any((column) => column.isEmpty);

  /// How many cards at the end of [column] are face up and in suit.
  int runLength(int column) {
    final cards = columns[column];
    if (cards.isEmpty) return 0;
    var count = 1;
    for (var i = cards.length - 1; i > hidden[column]; i--) {
      if (!cards[i].followsInSuit(cards[i - 1])) break;
      count++;
    }
    return count;
  }

  bool canPick(Pile pile, int count) =>
      pile.kind == PileKind.column &&
      count >= 1 &&
      count <= runLength(pile.index);

  /// The cards that would leave [pile].
  List<PlayingCard> cardsFrom(Pile pile, int count) =>
      pile.kind == PileKind.column
      ? columns[pile.index].sublist(columns[pile.index].length - count)
      : const [];

  bool _accepts(int column, PlayingCard lead) {
    final target = columns[column];
    return target.isEmpty || lead.canRestOn(target.last);
  }

  /// The state after the move, or null if the rules do not allow it. A
  /// sequence completed by the move goes to its nest.
  GameState? move(Pile from, int count, Pile to) {
    if (from == to || to.kind != PileKind.column || !canPick(from, count)) {
      return null;
    }
    final moving = cardsFrom(from, count);
    if (!_accepts(to.index, moving.first)) return null;

    final newColumns = [for (final column in columns) [...column]];
    final newHidden = [...hidden];
    final source = newColumns[from.index];
    source.removeRange(source.length - count, source.length);
    _turnTop(newColumns, newHidden, from.index);
    newColumns[to.index].addAll(moving);
    return GameState(
      columns: newColumns,
      hidden: newHidden,
      stock: stock,
      nests: nests,
    )._collect(to.index);
  }

  /// The card that is now on top turns face up.
  static void _turnTop(
    List<List<PlayingCard>> columns,
    List<int> hidden,
    int column,
  ) {
    final cards = columns[column];
    if (hidden[column] >= cards.length) {
      hidden[column] = cards.isEmpty ? 0 : cards.length - 1;
    }
  }

  /// Takes a complete sequence, king down to ace in one suit, from the end of
  /// [column] to the nests.
  GameState _collect(int column) {
    if (runLength(column) < 13) return this;
    final cards = columns[column];
    if (cards[cards.length - 13].rank != 13) return this;
    final newColumns = [for (final column in columns) [...column]];
    final newHidden = [...hidden];
    final source = newColumns[column];
    final sequence = source.sublist(source.length - 13);
    source.removeRange(source.length - 13, source.length);
    _turnTop(newColumns, newHidden, column);
    return GameState(
      columns: newColumns,
      hidden: newHidden,
      stock: stock,
      nests: [...nests, sequence],
    );
  }

  /// Whether a new row can be dealt: there are cards, and no column is empty.
  bool get canDeal => stock.isNotEmpty && !hasEmptyColumn;

  /// One face-up card on each column. Null when the rules do not allow it.
  GameState? deal() {
    if (!canDeal) return null;
    final newStock = [...stock];
    final dealt = newStock.sublist(newStock.length - columnCount);
    newStock.removeRange(newStock.length - columnCount, newStock.length);
    var next = GameState(
      columns: [
        for (var i = 0; i < columnCount; i++) [...columns[i], dealt[i]],
      ],
      hidden: hidden,
      stock: newStock,
      nests: nests,
    );
    for (var i = 0; i < columnCount; i++) {
      next = next._collect(i);
    }
    return next;
  }

  /// Where a double click sends the cards: onto the same suit, then onto any
  /// card, then into an empty column.
  Pile? bestDestination(Pile from, int count) {
    if (!canPick(from, count)) return null;
    final lead = cardsFrom(from, count).first;
    for (final sameSuit in [true, false]) {
      for (var i = 0; i < columnCount; i++) {
        if (i == from.index || columns[i].isEmpty) continue;
        final top = columns[i].last;
        if (!lead.canRestOn(top)) continue;
        if (sameSuit && lead.suit != top.suit) continue;
        return Pile.column(i);
      }
    }
    // An empty column only helps when the cards leave something behind.
    if (count < columns[from.index].length) {
      for (var i = 0; i < columnCount; i++) {
        if (columns[i].isEmpty) return Pile.column(i);
      }
    }
    return null;
  }

  /// The moves worth showing, the most useful first: those that build in
  /// suit, then those that uncover a card or empty a column, then the rest.
  /// A move that only swaps one resting place for one no better is left out.
  List<Hint> hints() {
    final found = <(int, Hint)>[];
    for (var from = 0; from < columnCount; from++) {
      final run = runLength(from);
      final cards = columns[from];
      for (var count = run; count >= 1; count--) {
        final lead = cards[cards.length - count];
        final under = cards.length - count - 1;
        final restsAlready =
            under >= 0 && under >= hidden[from] && lead.canRestOn(cards[under]);
        final restsInSuit = restsAlready && lead.suit == cards[under].suit;
        if (restsInSuit) continue;
        for (var to = 0; to < columnCount; to++) {
          if (to == from || columns[to].isEmpty) continue;
          final top = columns[to].last;
          if (!lead.canRestOn(top)) continue;
          final inSuit = lead.suit == top.suit;
          if (restsAlready && !inSuit) continue;
          final opens = under < hidden[from] || under < 0;
          final rank = inSuit
              ? 0
              : opens
              ? 1
              : 2;
          found.add((rank, Hint(from, count, to)));
        }
      }
    }
    // Dart's sort is not stable, so each rank is taken in turn.
    return [
      for (var rank = 0; rank < 3; rank++)
        for (final (r, hint) in found)
          if (r == rank) hint,
    ];
  }
}
