import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psito_games_ui/psito_games_ui.dart';
import 'package:psito_spider/l10n/app_localizations.dart';
import 'package:psito_spider/src/game/game_controller.dart';
import 'package:psito_spider/src/game/game_state.dart';
import 'package:psito_spider/src/game/scores.dart';
import 'package:psito_spider/src/ui/atoms/card_face.dart';
import 'package:psito_spider/src/ui/organisms/board.dart';
import 'package:psito_spider/src/ui/pages/game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _s = Suit.spades;
const _h = Suit.hearts;

Widget app(Widget home) => MaterialApp(
  locale: const Locale('pt'),
  localizationsDelegates: const [
    ...AppLocalizations.localizationsDelegates,
    GamesUiLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

Future<void> pumpGame(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(app(const GameScreen(number: 3, suits: Suits.one)));
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> finish(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 4));
}

GameState tableOf(
  List<List<PlayingCard>> columns, {
  List<PlayingCard> stock = const [],
  List<List<PlayingCard>> nests = const [],
}) => GameState(
  columns: [
    ...columns,
    for (var i = columns.length; i < columnCount; i++) <PlayingCard>[],
  ],
  hidden: List.filled(columnCount, 0),
  stock: stock,
  nests: nests,
);

List<PlayingCard> run(Suit suit, int low, [int copy = 0]) => [
  for (var rank = 13; rank >= low; rank--) PlayingCard(suit, rank, copy),
];

/// A board with a seven of hearts in the first column and an eight of spades
/// in the second.
Future<GameController> pumpBoard(
  WidgetTester tester, {
  List<List<PlayingCard>>? columns,
  List<PlayingCard> stock = const [],
}) async {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final game = GameController(number: 1);
  addTearDown(game.dispose);
  game.state = tableOf(
    columns ??
        [
          [const PlayingCard(_h, 7)],
          [const PlayingCard(_s, 8)],
        ],
    stock: stock,
  );
  await tester.pumpWidget(app(Scaffold(body: Board(game: game))));
  await tester.pump();
  return game;
}

/// [count] different cards, none of them on the table already.
List<PlayingCard> distinct(int count, {int copy = 6}) => [
  for (var i = 0; i < count; i++)
    PlayingCard(Suit.values[i % 4], 1 + i ~/ 4, copy),
];

/// The stock, by its top card.
Finder stockCard() => find
    .byWidgetPredicate((widget) => widget is CardFace && !widget.faceUp)
    .last;

Finder faceOf(Suit suit, int rank) => find.byWidgetPredicate(
  (widget) =>
      widget is CardFace && widget.card.rank == rank && widget.card.suit == suit,
);

/// Seven nests done and the last sequence one ace away.
GameState almostWon() => tableOf(
  [
    run(_s, 2, 7),
    [const PlayingCard(_s, 1, 7)],
  ],
  nests: [for (var i = 0; i < 7; i++) run(_s, 1, i)],
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('the winner saves a name and sees the best games', (tester) async {
    final game = await pumpBoard(tester);
    game.state = almostWon();
    game.sendAway(const Pile.column(1), 0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(game.state.isWon, isTrue);
    expect(find.text('Você venceu!'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Ana');
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Ana'), findsOneWidget);
    final saved = await const ScoreStore().load(Suits.one);
    expect(saved.single.name, 'Ana');
    expect(saved.single.points, 500 - 1 + 100);
    await finish(tester);
  });

  testWidgets('h and d reach the name of the winner', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(const GameScreen(number: 3, suits: Suits.one)));
    await tester.pump();
    final game = tester.widget<Board>(find.byType(Board)).game;
    game.state = almostWon();
    game.sendAway(const Pile.column(1), 0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyH);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
    await tester.pump();
    expect(game.refusal, isNull);
    expect(game.hinted, isEmpty);
    expect(game.state.isWon, isTrue);
    await finish(tester);
  });

  testWidgets('the victory panel fits a small window', (tester) async {
    final game = await pumpBoard(tester);
    tester.view.physicalSize = const Size(480, 300);
    game.state = almostWon();
    game.sendAway(const Pile.column(1), 0);
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
    await finish(tester);
  });

  testWidgets('dragging a card drops it on a column', (tester) async {
    final game = await pumpBoard(tester);
    final from = tester.getCenter(faceOf(_h, 7));
    final to = tester.getCenter(faceOf(_s, 8));
    await tester.dragFrom(from, to - from + const Offset(0, 40));
    await tester.pump(const Duration(milliseconds: 300));
    expect(game.state.columns[1].length, 2);
    expect(game.state.columns[0], isEmpty);
    expect(game.moves, 1);
    await finish(tester);
  });

  testWidgets('a drop that the rules refuse keeps the card', (tester) async {
    final game = await pumpBoard(tester);
    final from = tester.getCenter(faceOf(_s, 8));
    final to = tester.getCenter(faceOf(_h, 7));
    final tick = game.rejectTick;
    await tester.dragFrom(from, to - from);
    await tester.pump(const Duration(milliseconds: 400));
    expect(game.state.columns[1].length, 1);
    expect(game.rejectTick, tick + 1);
    await finish(tester);
  });

  testWidgets('a double click sends the card away', (tester) async {
    final game = await pumpBoard(tester);
    await tester.tap(faceOf(_h, 7));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(faceOf(_h, 7));
    await tester.pump(const Duration(milliseconds: 300));
    expect(game.state.columns[1].length, 2);
    await finish(tester);
  });

  testWidgets('the stock refuses to deal over an empty column, and says so', (
    tester,
  ) async {
    final game = await pumpBoard(
      tester,
      stock: distinct(10),
    );
    await tester.tap(stockCard());
    await tester.pump(const Duration(milliseconds: 300));
    expect(game.state.stock.length, 10);
    expect(
      find.text('Preencha todas as colunas vazias antes de dar cartas.'),
      findsOneWidget,
    );
    await finish(tester);
  });

  testWidgets('the stock deals a row when every column has cards', (tester) async {
    final game = await pumpBoard(
      tester,
      columns: [
        for (final card in distinct(columnCount, copy: 5)) [card],
      ],
      stock: distinct(10),
    );
    await tester.tap(stockCard());
    await tester.pump(const Duration(seconds: 1));
    expect(game.state.stock, isEmpty);
    expect(game.state.columns.every((c) => c.length == 2), isTrue);
    await finish(tester);
  });

  testWidgets('wide windows say the suits in words', (tester) async {
    await pumpGame(tester, const Size(1600, 900));
    expect(find.text('1 naipe'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await finish(tester);
  });

  testWidgets('shows the table, the score and the suits', (tester) async {
    await pumpGame(tester, const Size(1280, 800));
    expect(find.text('Psito Spider'), findsOneWidget);
    expect(find.text('PONTOS'), findsOneWidget);
    expect(find.text('500'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.byType(CardFace), findsNWidgets(104));
    await finish(tester);
  });

  testWidgets('choosing four suits starts a new game with them', (tester) async {
    await pumpGame(tester, const Size(1280, 800));
    await tester.tap(find.byTooltip('Dificuldade'));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    await tester.tap(find.text('4 naipes, difícil').last);
    await tester.pump(const Duration(milliseconds: 400));
    final game = tester.widget<Board>(find.byType(Board)).game;
    expect(game.suits, Suits.four);
    expect(await const ScoreStore().lastSuits(), Suits.four);
    await finish(tester);
  });

  testWidgets('the hint button lights a move', (tester) async {
    await pumpGame(tester, const Size(1280, 800));
    await tester.tap(find.byIcon(Icons.lightbulb_outline_rounded));
    await tester.pump();
    final lit = tester
        .widgetList<CardFace>(find.byType(CardFace))
        .where((face) => face.selected);
    expect(lit, isNotEmpty);
    await finish(tester);
  });

  testWidgets('fits small and large windows without overflowing', (tester) async {
    for (final size in const [Size(480, 360), Size(1920, 1080), Size(800, 1200)]) {
      await pumpGame(tester, size);
      expect(tester.takeException(), isNull);
    }
    await finish(tester);
  });
}
