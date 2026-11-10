import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../game/game_controller.dart';
import '../../game/game_state.dart';
import '../../game/scores.dart';
import '../atoms/card_face.dart';
import '../atoms/colors.dart';
import '../atoms/slot_view.dart';
import '../labels.dart';
import '../molecules/card_motion.dart';
import '../molecules/table_note.dart';
import 'board_layout.dart';
import 'victory_panel.dart';

class _Placed {
  const _Placed(
    this.card,
    this.pile,
    this.index,
    this.offset, {
    required this.faceUp,
    this.shadow = true,
    this.winOrder = 0,
    this.delay = 0,
  });

  final PlayingCard card;
  final Pile pile;
  final int index;
  final Offset offset;
  final bool faceUp;
  final bool shadow;

  /// When the card leaves its nest in the victory, the lowest first.
  final int winOrder;

  /// How many steps a dealt card waits, so that the row goes out one by one.
  final int delay;
}

class _Drag {
  _Drag(this.pile, this.index, this.count);

  final Pile pile;
  final int index;
  final int count;
  Offset delta = Offset.zero;

  bool holds(_Placed placed) => placed.pile == pile && placed.index >= index;
}

/// The table: every card is one widget that travels on its own.
class Board extends StatefulWidget {
  const Board({super.key, required this.game, this.scores = const ScoreStore()});

  final GameController game;
  final ScoreStore scores;

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> with SingleTickerProviderStateMixin {
  static const _doubleClick = Duration(milliseconds: 350);

  late final AnimationController _win = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  );
  _Drag? _drag;
  int? _lastTapCard;
  DateTime _lastTapTime = DateTime.fromMillisecondsSinceEpoch(0);
  bool _won = false;

  GameController get game => widget.game;

  @override
  void initState() {
    super.initState();
    game.addListener(_gameChanged);
  }

  @override
  void dispose() {
    game.removeListener(_gameChanged);
    _win.dispose();
    super.dispose();
  }

  void _gameChanged() {
    final won = game.state.isWon;
    if (won == _won) return;
    _won = won;
    if (won) {
      _win.forward(from: 0);
    } else {
      _win.value = 0;
    }
  }

  List<_Placed> _place(GameState state, BoardLayout layout) {
    final placed = <_Placed>[];

    // The stock, a row of ten cards for each deal still to come, the next
    // one on the right. Only the top card of a row has a shadow.
    final rows = state.dealsLeft;
    for (var row = 0; row < rows; row++) {
      for (var i = 0; i < columnCount; i++) {
        final index = row * columnCount + i;
        placed.add(
          _Placed(
            state.stock[index],
            const Pile.stock(),
            index,
            layout.stockRow(row),
            faceUp: false,
            shadow: i == columnCount - 1,
          ),
        );
      }
    }

    // The nests, with the king on top, as it was in the column.
    for (var nest = 0; nest < state.nests.length; nest++) {
      final cards = state.nests[nest];
      final arriving = game.lastMoved.contains(cards.first.id);
      for (var i = cards.length - 1; i >= 0; i--) {
        placed.add(
          _Placed(
            cards[i],
            Pile.nest(nest),
            i,
            layout.slot(Pile.nest(nest)),
            faceUp: true,
            shadow: i == 0 || arriving,
            winOrder: (13 - cards[i].rank) * nestCount + nest,
          ),
        );
      }
    }

    final dealt = game.dealt;
    for (var c = 0; c < state.columns.length; c++) {
      final cards = state.columns[c];
      final where = Pile.column(c);
      for (var i = 0; i < cards.length; i++) {
        placed.add(
          _Placed(
            cards[i],
            where,
            i,
            layout.columnCard(where, i, cards.length, state.hidden[c]),
            faceUp: i >= state.hidden[c],
            delay: dealt && i == cards.length - 1 ? c : 0,
          ),
        );
      }
    }

    int layer(_Placed placed) {
      if (_drag?.holds(placed) ?? false) return 2;
      return game.lastMoved.contains(placed.card.id) ? 1 : 0;
    }

    // Dart's sort is not stable, so the original order breaks the ties.
    final order = {for (var i = 0; i < placed.length; i++) placed[i]: i};
    placed.sort((a, b) {
      final byLayer = layer(a).compareTo(layer(b));
      return byLayer != 0 ? byLayer : order[a]!.compareTo(order[b]!);
    });
    return placed;
  }

  void _tap(_Placed placed) {
    if (placed.pile.kind == PileKind.stock) {
      game.deal();
      return;
    }
    if (placed.pile.kind != PileKind.column) return;
    final now = DateTime.now();
    final isDouble =
        _lastTapCard == placed.card.id &&
        now.difference(_lastTapTime) < _doubleClick;
    _lastTapCard = placed.card.id;
    _lastTapTime = now;
    if (isDouble) {
      _lastTapCard = null;
      game.sendAway(placed.pile, placed.index);
    } else {
      game.tapCard(placed.pile, placed.index);
    }
  }

  void _panStart(_Placed placed) {
    if (!placed.faceUp || placed.pile.kind != PileKind.column) return;
    final count = game.state.columns[placed.pile.index].length - placed.index;
    if (!game.state.canPick(placed.pile, count)) {
      game.rejectPick(placed.pile, placed.index);
      return;
    }
    game.clearSelection();
    setState(() => _drag = _Drag(placed.pile, placed.index, count));
  }

  void _panEnd(_Placed placed, BoardLayout layout) {
    final drag = _drag;
    if (drag == null) return;
    setState(() => _drag = null);
    final corner = placed.offset + drag.delta;
    final center =
        corner + Offset(layout.cardWidth / 2, layout.cardHeight * .3);
    final target = layout.pileAt(center);
    if (target == null || target == drag.pile) return;
    game.moveCards(drag.pile, drag.count, target);
  }

  String _cardName(AppLocalizations l10n, _Placed placed) {
    if (placed.pile.kind == PileKind.stock) {
      return l10n.dealRow(game.state.dealsLeft);
    }
    if (!placed.faceUp) return l10n.faceDownCard;
    return cardName(l10n, placed.card);
  }

  Widget _slot(
    BoardLayout layout,
    Pile pile,
    String label,
    Widget child, {
    VoidCallback? onTap,
  }) {
    final at = layout.slot(pile);
    return Positioned(
      left: at.dx,
      top: at.dy,
      width: layout.cardWidth,
      height: layout.cardHeight,
      child: Semantics(
        button: onTap != null,
        label: label,
        onTap: onTap,
        child: GestureDetector(
          excludeFromSemantics: true,
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }

  Widget _card(
    BoardLayout layout,
    _Placed placed,
    AppLocalizations l10n,
    bool still,
  ) {
    final drag = _drag;
    final dragging = drag?.holds(placed) ?? false;
    final held = game.selected;
    final cards = placed.pile.kind == PileKind.column
        ? game.state.columns[placed.pile.index].length
        : 0;
    final selected =
        held != null &&
        held.pile == placed.pile &&
        placed.index >= cards - held.count;
    final hinted =
        game.hinted.contains(placed.card.id) ||
        (game.hintedStock &&
            placed.pile.kind == PileKind.stock &&
            placed.index >= game.state.stock.length - columnCount);
    var at = placed.offset;
    if (dragging) at += drag!.delta;
    if (selected) at -= Offset(0, layout.cardHeight * .05);

    final travel = 240 + placed.delay * 45;
    return AnimatedPositioned(
      key: ValueKey(placed.card.id),
      left: at.dx,
      top: at.dy,
      width: layout.cardWidth,
      height: layout.cardHeight,
      duration: dragging || still
          ? Duration.zero
          : Duration(milliseconds: travel),
      curve: placed.delay > 0
          ? Interval(placed.delay * 45 / travel, 1, curve: Curves.easeOutBack)
          : Curves.easeOutBack,
      child: WinBounce(
        animation: _win,
        order: placed.winOrder,
        floor: layout.size.height - layout.cardHeight - placed.offset.dy,
        child: Shake(
          tick: game.rejectTick,
          active: game.rejected.contains(placed.card.id),
          child: Semantics(
            button: true,
            selected: selected,
            label: _cardName(l10n, placed),
            onTap: () => _tap(placed),
            child: GestureDetector(
              excludeFromSemantics: true,
              onTap: () => _tap(placed),
              onPanStart: (_) => _panStart(placed),
              onPanUpdate: (details) {
                if (_drag == null) return;
                setState(() => _drag!.delta += details.delta);
              },
              onPanEnd: (_) => _panEnd(placed, layout),
              onPanCancel: () => setState(() => _drag = null),
              child: CardFace(
                card: placed.card,
                selected: selected || hinted,
                faceUp: placed.faceUp,
                shadow: placed.shadow,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _note(AppLocalizations l10n) {
    if (game.stuck) return l10n.noMoves;
    return switch (game.refusal) {
      DealRefusal.emptyColumn => l10n.fillEmptyColumns,
      DealRefusal.noCards => l10n.noMoreCards,
      null => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final still = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, box) {
        final layout = BoardLayout.fit(box.biggest);
        return ListenableBuilder(
          listenable: game,
          builder: (context, _) {
            final state = game.state;
            final note = _note(l10n);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onTap: game.clearSelection,
              child: Stack(
                children: [
                  _slot(
                    layout,
                    const Pile.stock(),
                    state.stock.isEmpty
                        ? l10n.stockEmpty
                        : l10n.dealRow(state.dealsLeft),
                    const SlotView.stock(),
                    onTap: game.deal,
                  ),
                  for (var nest = 0; nest < nestCount; nest++)
                    _slot(
                      layout,
                      Pile.nest(nest),
                      nest < state.nests.length
                          ? l10n.nestOf(
                              nest + 1,
                              suitName(l10n, state.nests[nest].first.suit),
                            )
                          : l10n.nest(nest + 1),
                      const SlotView.nest(),
                    ),
                  for (var c = 0; c < columnCount; c++)
                    if (state.columns[c].isEmpty)
                      _slot(
                        layout,
                        Pile.column(c),
                        l10n.emptyColumn,
                        const SizedBox.expand(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color(0x14000000),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        onTap: () => game.tapEmpty(Pile.column(c)),
                      ),
                  for (final placed in _place(state, layout))
                    _card(layout, placed, l10n, still),
                  if (note != null)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 20,
                      child: TableNote(
                        key: ValueKey(game.refusalTick),
                        message: note,
                        color: PsitoColors.barBottom,
                      ),
                    ),
                  if (state.isWon) _victory(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _victory() => Center(
    child: FadeTransition(
      opacity: CurvedAnimation(parent: _win, curve: const Interval(.15, .2)),
      child: VictoryPanel(game: game, store: widget.scores),
    ),
  );
}
