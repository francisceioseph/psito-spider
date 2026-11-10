// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Psito Spider';

  @override
  String get youWon => 'Gewonnen!';

  @override
  String get emptyColumn => 'Leere Spalte';

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
    return '$suit $rank';
  }

  @override
  String get rankAce => 'Ass';

  @override
  String get rankJack => 'Bube';

  @override
  String get rankQueen => 'Dame';

  @override
  String get rankKing => 'König';

  @override
  String get suitClubs => 'Kreuz';

  @override
  String get suitSpades => 'Pik';

  @override
  String get suitHearts => 'Herz';

  @override
  String get suitDiamonds => 'Karo';

  @override
  String winSummary(String points, String time) {
    return '$points in $time';
  }

  @override
  String get howToPlayBody =>
      'Lege acht Folgen vom König bis zum Ass, jede in einer einzigen Farbe. Eine vollständige Folge fliegt von selbst in ein Nest, und acht Nester gewinnen das Spiel.\n\nIn den Spalten passt jede Karte auf eine Karte, die einen Rang höher ist, egal welche Farbe. Aber nur Karten derselben Farbe, in der richtigen Reihenfolge, bewegen sich zusammen. In eine leere Spalte darf alles.\n\nKlicke auf den Stapel, um auf jede Spalte eine weitere Karte zu geben. Er gibt nur, wenn keine Spalte leer ist.\n\nEine Farbe ist das gemütlichste Spiel, zwei Farben sind schwerer, und vier Farben sind eine echte Herausforderung.\n\nPunkte: 500 zu Beginn, 1 weniger für jeden Zug und 100 mehr für jedes Nest.\n\nH zeigt einen Zug, D gibt Karten, Strg+Z macht rückgängig, Strg+R startet dieses Spiel neu und Strg+N beginnt ein neues.';

  @override
  String get aboutBody =>
      'Spider-Patience mit Nymphensittichen. Ohne Werbung, ohne Telemetrie und ohne Konto.';

  @override
  String get aboutLegal =>
      'Code unter der Apache-2.0-Lizenz. Kartengrafiken unter CC0.';

  @override
  String points(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Punkte',
      one: '1 Punkt',
    );
    return '$_temp0';
  }

  @override
  String get statScore => 'Punkte';

  @override
  String dealRow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eine Reihe geben, noch $count',
      one: 'Die letzte Reihe geben',
    );
    return '$_temp0';
  }

  @override
  String get stockEmpty => 'Keine Karten mehr zum Geben';

  @override
  String get faceDownCard => 'Verdeckte Karte';

  @override
  String get fillEmptyColumns => 'Fülle alle leeren Spalten, bevor du gibst.';

  @override
  String get noMoreCards => 'Es gibt keine Karten mehr zum Geben.';

  @override
  String get noMoves =>
      'Kein sinnvoller Zug mehr. Mach ein paar Züge rückgängig.';

  @override
  String get hint => 'Einen Zug zeigen';

  @override
  String get deal => 'Geben';

  @override
  String suitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Farben',
      one: '1 Farbe',
    );
    return '$_temp0';
  }

  @override
  String get easy => 'leicht';

  @override
  String get medium => 'mittel';

  @override
  String get hard => 'schwer';

  @override
  String suitsChoice(String suits, String level) {
    return '$suits, $level';
  }
}
