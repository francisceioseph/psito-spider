// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Psito Spider';

  @override
  String get youWon => 'You won!';

  @override
  String get emptyColumn => 'Empty column';

  @override
  String nest(int number) {
    return 'Nest $number';
  }

  @override
  String nestOf(int number, String suit) {
    return 'Nest $number: $suit';
  }

  @override
  String cardName(String rank, String suit) {
    return '$rank of $suit';
  }

  @override
  String get rankAce => 'Ace';

  @override
  String get rankJack => 'Jack';

  @override
  String get rankQueen => 'Queen';

  @override
  String get rankKing => 'King';

  @override
  String get suitClubs => 'clubs';

  @override
  String get suitSpades => 'spades';

  @override
  String get suitHearts => 'hearts';

  @override
  String get suitDiamonds => 'diamonds';

  @override
  String winSummary(String points, String time) {
    return '$points in $time';
  }

  @override
  String get howToPlayBody =>
      'Build eight sequences from King down to Ace, each in a single suit. A complete sequence flies to a nest by itself, and eight nests win the game.\n\nIn the columns, any card goes on a card one rank higher, whatever the suit. But only cards of the same suit, in order, move together. Anything can go to an empty column.\n\nClick the stock to deal one more card on each column. It only deals when no column is empty.\n\nOne suit is the gentlest game, two suits are harder, and four suits are a real challenge.\n\nPoints: 500 to start, minus 1 for each move and plus 100 for each nest.\n\nH shows a move, D deals, Ctrl+Z undoes, Ctrl+R restarts this game and Ctrl+N starts a new one.';

  @override
  String get aboutBody =>
      'Spider solitaire with cockatiels. No ads, no telemetry and no account.';

  @override
  String get aboutLegal =>
      'Code under the Apache 2.0 license. Card art under CC0.';

  @override
  String points(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count points',
      one: '1 point',
    );
    return '$_temp0';
  }

  @override
  String get statScore => 'Points';

  @override
  String dealRow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Deal a row, $count left',
      one: 'Deal the last row',
    );
    return '$_temp0';
  }

  @override
  String get stockEmpty => 'No more cards to deal';

  @override
  String get faceDownCard => 'Face-down card';

  @override
  String get fillEmptyColumns => 'Fill every empty column before dealing.';

  @override
  String get noMoreCards => 'There are no more cards to deal.';

  @override
  String get noMoves => 'No useful move left. Try undoing a few moves.';

  @override
  String get hint => 'Show a move';

  @override
  String get deal => 'Deal';

  @override
  String suitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count suits',
      one: '1 suit',
    );
    return '$_temp0';
  }

  @override
  String get easy => 'easy';

  @override
  String get medium => 'medium';

  @override
  String get hard => 'hard';

  @override
  String suitsChoice(String suits, String level) {
    return '$suits, $level';
  }
}
