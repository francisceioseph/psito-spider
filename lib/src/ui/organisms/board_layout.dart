import 'dart:math';

import 'package:flutter/widgets.dart';

import '../../game/game_state.dart';

/// Where everything goes for a given window size: the stock and the eight
/// nests along the top, and the ten columns under them.
class BoardLayout {
  BoardLayout._(this.size, this.cardWidth, this.cardHeight, this.gap, this.left);

  factory BoardLayout.fit(Size size) {
    final gap = (size.width * .01).clamp(4.0, 14.0);
    final byWidth = (size.width - pad * 2 - gap * (columnCount - 1)) / columnCount;
    final byHeight = (size.height - pad * 2 - gap * 2) / 4.4 / aspect;
    final width = max(20.0, min(byWidth, byHeight));
    final height = width * aspect;
    final left = (size.width - (width * columnCount + gap * (columnCount - 1))) / 2;
    return BoardLayout._(size, width, height, gap, left);
  }

  static const pad = 12.0;
  static const aspect = 1.4;

  final Size size;
  final double cardWidth;
  final double cardHeight;
  final double gap;
  final double left;

  double get _tableauTop => pad + cardHeight + gap * 2;

  double _columnX(int column) => left + column * (cardWidth + gap);

  /// How far apart the rows still in the stock are drawn.
  double get stockStep => cardWidth * .06;

  Offset slot(Pile pile) => switch (pile.kind) {
    PileKind.stock => Offset(_columnX(0), pad),
    PileKind.nest => Offset(_columnX(pile.index + 2), pad),
    PileKind.column => Offset(_columnX(pile.index), _tableauTop),
  };

  /// Where the row [row] of the stock waits, the next one to go on the right.
  Offset stockRow(int row) => slot(const Pile.stock()) + Offset(row * stockStep, 0);

  /// Where the card at [index] goes in a column of [count] cards, with the
  /// first [hidden] face down. The column shrinks when it would not fit.
  Offset columnCard(Pile pile, int index, int count, int hidden) {
    final faceDown = cardHeight * .08;
    final faceUp = cardHeight * .24;
    double height(int cards) =>
        min(cards, hidden) * faceDown + max(0, cards - hidden) * faceUp;

    final room = size.height - _tableauTop - pad - cardHeight;
    final total = height(count - 1);
    final squeeze = total > room && total > 0 ? room / total : 1.0;
    return slot(pile) + Offset(0, height(index) * squeeze);
  }

  /// The column under a point, if there is one.
  Pile? pileAt(Offset point) {
    final column = ((point.dx - left + gap / 2) / (cardWidth + gap)).floor();
    if (column < 0 || column >= columnCount) return null;
    if (point.dy < _tableauTop - gap) return null;
    return Pile.column(column);
  }
}
