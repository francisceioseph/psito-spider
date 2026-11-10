import 'package:flutter_test/flutter_test.dart';
import 'package:psito_spider/src/game/game_controller.dart';
import 'package:psito_spider/src/game/game_state.dart';

const _s = Suit.spades;
const _h = Suit.hearts;

PlayingCard card(Suit suit, int rank, [int copy = 0]) =>
    PlayingCard(suit, rank, copy);

/// A table with the given columns, the rest empty, everything face up.
GameState table({
  List<List<PlayingCard>> columns = const [],
  List<int>? hidden,
  List<PlayingCard> stock = const [],
  List<List<PlayingCard>> nests = const [],
}) => GameState(
  columns: [
    ...columns,
    for (var i = columns.length; i < columnCount; i++) <PlayingCard>[],
  ],
  hidden: [...?hidden, for (var i = hidden?.length ?? 0; i < columnCount; i++) 0],
  stock: stock,
  nests: nests,
);

/// Something on every column, so that dealing is allowed.
List<List<PlayingCard>> filler() => [
  for (var i = 0; i < columnCount; i++) [card(_h, 1, 7)],
];

/// King to [low] of one suit.
List<PlayingCard> run(Suit suit, int low, [int copy = 0]) => [
  for (var rank = 13; rank >= low; rank--) card(suit, rank, copy),
];

const a = Pile.column(0);
const b = Pile.column(1);
const c = Pile.column(2);

void main() {
  group('deal', () {
    test('has 54 cards on the table and 50 in the stock', () {
      final state = GameState.deal(42, Suits.four);
      expect(state.columns.map((c) => c.length), [6, 6, 6, 6, 5, 5, 5, 5, 5, 5]);
      expect(state.hidden, [5, 5, 5, 5, 4, 4, 4, 4, 4, 4]);
      expect(state.stock.length, 50);
      expect(state.dealsLeft, 5);
      final all = [...state.columns.expand((c) => c), ...state.stock];
      expect(all.map((c) => c.id).toSet().length, 104);
    });

    test('uses the suits chosen, eight of each card in all', () {
      for (final suits in Suits.values) {
        final deck = spiderDeck(suits);
        expect(deck.length, 104);
        expect(deck.map((c) => c.suit).toSet(), suits.suits.toSet());
        expect(deck.where((c) => c.rank == 13).length, 8);
      }
    });

    test('is the same for the same number', () {
      expect(shuffledDeck(7, Suits.two), shuffledDeck(7, Suits.two));
      expect(shuffledDeck(7, Suits.two), isNot(shuffledDeck(8, Suits.two)));
    });
  });

  group('moves', () {
    test('any card one rank lower can rest on another', () {
      final state = table(
        columns: [
          [card(_h, 7)],
          [card(_s, 8)],
        ],
      );
      expect(state.move(a, 1, b), isNotNull);
      expect(state.move(b, 1, a), isNull);
    });

    test('anything goes to an empty column', () {
      final state = table(columns: [[card(_h, 4)]]);
      expect(state.move(a, 1, c)!.columns[2], [card(_h, 4)]);
    });

    test('only a sequence in one suit moves together', () {
      final mixed = table(
        columns: [
          [card(_s, 9), card(_h, 8)],
          [card(_s, 10)],
        ],
      );
      expect(mixed.runLength(0), 1);
      expect(mixed.move(a, 2, b), isNull);
      final same = table(
        columns: [
          [card(_s, 9), card(_s, 8)],
          [card(_s, 10)],
        ],
      );
      expect(same.runLength(0), 2);
      expect(same.move(a, 2, b)!.columns[1].length, 3);
    });

    test('the card left on top turns face up', () {
      final state = table(
        columns: [
          [card(_s, 3), card(_h, 9), card(_h, 7)],
          [card(_s, 8)],
        ],
        hidden: [2],
      );
      expect(state.move(a, 1, b)!.hidden[0], 1);
    });

    test('a face-down card is never part of a sequence', () {
      final state = table(
        columns: [
          [card(_s, 8), card(_s, 7)],
        ],
        hidden: [1],
      );
      expect(state.runLength(0), 1);
    });
  });

  group('nests', () {
    test('a whole suit from king to ace leaves for a nest', () {
      final state = table(
        columns: [
          [card(_h, 5), ...run(_s, 2)],
          [card(_s, 1)],
        ],
        hidden: [1],
      );
      final next = state.move(b, 1, a)!;
      expect(next.nests.single.map((c) => c.suit).toSet(), {_s});
      expect(next.columns[0], [card(_h, 5)]);
      expect(next.hidden[0], 0);
    });

    test('a deal can complete a sequence too', () {
      final columns = filler();
      columns[3] = run(_s, 2);
      final stock = [for (var i = 0; i < columnCount; i++) card(_h, 2, 6)];
      stock[3] = card(_s, 1);
      final next = table(columns: columns, stock: stock).deal()!;
      expect(next.nests.single.map((c) => c.suit).toSet(), {_s});
      expect(next.columns[3], isEmpty);
    });

    test('eight nests win the game', () {
      expect(table(nests: List.filled(8, run(_s, 1))).isWon, isTrue);
      expect(table(nests: List.filled(7, run(_s, 1))).isWon, isFalse);
    });
  });

  group('the stock', () {
    test('deals one card on each column', () {
      final stock = [for (var i = 0; i < 20; i++) card(_h, 2, i % 8)];
      final next = table(columns: filler(), stock: stock).deal()!;
      expect(next.stock.length, 10);
      expect(next.columns.every((c) => c.length == 2), isTrue);
    });

    test('waits while a column is empty', () {
      final columns = filler()..[4] = [];
      final state = table(columns: columns, stock: [card(_h, 2)]);
      expect(state.canDeal, isFalse);
      expect(state.deal(), isNull);
    });
  });

  group('help', () {
    test('a double click prefers the same suit', () {
      final state = table(
        columns: [
          [card(_s, 5), card(_s, 4)],
          [card(_h, 5)],
          [card(_s, 5, 1)],
        ],
      );
      expect(state.bestDestination(const Pile.column(0), 1), c);
    });

    test('a double click does not move a whole column to an empty one', () {
      final state = table(columns: [[card(_s, 5)]]);
      expect(state.bestDestination(a, 1), isNull);
    });

    test('hints build in suit first and skip pointless moves', () {
      final state = table(
        columns: [
          [card(_s, 9), card(_s, 8)],
          [card(_h, 9)],
          [card(_s, 9, 1)],
          [card(_h, 7)],
        ],
      );
      final hints = state.hints();
      // The eight already rests on a nine of its suit: moving it is no help.
      expect(hints.any((h) => h.from == 0), isFalse);
      expect(hints.first.from, 3);
      expect(hints.first.to, 0);
    });
  });

  group('controller', () {
    GameController controller() => GameController(number: 3, suits: Suits.one);

    test('starts at 500 and each move costs a point', () {
      final game = controller();
      expect(game.score, 500);
      game.deal();
      expect(game.score, 499);
      expect(game.moves, 1);
    });

    test('undo brings the table back but still costs a point', () {
      final game = controller();
      final before = game.state;
      game.deal();
      game.undo();
      expect(game.state, same(before));
      expect(game.score, 499);
      expect(game.canUndo, isFalse);
    });

    test('a refused deal says why', () {
      final game = controller();
      game.state = table(columns: filler()..[0] = [], stock: [card(_h, 2)]);
      game.deal();
      expect(game.refusal, DealRefusal.emptyColumn);
      expect(game.moves, 0);
    });

    test('a nest is worth 100 points', () {
      final game = controller();
      game.state = table(
        columns: [
          run(_s, 2),
          [card(_s, 1)],
        ],
      );
      game.moveCards(b, 1, a);
      expect(game.score, 500 - 1 + 100);
    });

    test('hints light cards and then go out', () async {
      final game = GameController(
        number: 3,
        hintTime: const Duration(milliseconds: 10),
      );
      game.state = table(
        columns: [
          [card(_s, 9)],
          [card(_s, 8)],
        ],
      );
      game.hint();
      expect(game.hinted, {card(_s, 9).id, card(_s, 8).id});
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(game.hinted, isEmpty);
    });

    test('with nothing to do the hint says so', () {
      final game = controller();
      game.state = table(columns: [[card(_s, 9)]]);
      game.hint();
      expect(game.stuck, isTrue);
    });

    test('a new game can change the suits', () {
      final game = controller();
      game.newGame(5, Suits.four);
      expect(game.suits, Suits.four);
      expect(game.state.columns.expand((c) => c).map((c) => c.suit).toSet().length,
          greaterThan(1));
    });
  });
}
