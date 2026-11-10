// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Psito Spider';

  @override
  String get youWon => 'Vous avez gagné !';

  @override
  String get emptyColumn => 'Colonne vide';

  @override
  String nest(int number) {
    return 'Nid $number';
  }

  @override
  String nestOf(int number, String suit) {
    return 'Nid $number : $suit';
  }

  @override
  String cardName(String rank, String suit) {
    return '$rank de $suit';
  }

  @override
  String get rankAce => 'As';

  @override
  String get rankJack => 'Valet';

  @override
  String get rankQueen => 'Dame';

  @override
  String get rankKing => 'Roi';

  @override
  String get suitClubs => 'trèfle';

  @override
  String get suitSpades => 'pique';

  @override
  String get suitHearts => 'cœur';

  @override
  String get suitDiamonds => 'carreau';

  @override
  String winSummary(String points, String time) {
    return '$points en $time';
  }

  @override
  String get howToPlayBody =>
      'Formez huit suites du Roi à l’As, chacune d’une seule couleur. Une suite complète s’envole seule vers un nid, et huit nids gagnent la partie.\n\nDans les colonnes, n’importe quelle carte se pose sur une carte d’une valeur au-dessus, quelle que soit sa couleur. Mais seules les cartes de la même couleur, dans l’ordre, se déplacent ensemble. Tout peut aller dans une colonne vide.\n\nCliquez sur le talon pour donner une carte de plus sur chaque colonne. Il ne donne que lorsqu’aucune colonne n’est vide.\n\nUne couleur, c’est la partie la plus douce, deux couleurs sont plus difficiles, et quatre couleurs sont un vrai défi.\n\nPoints : 500 au départ, 1 de moins par coup et 100 de plus par nid.\n\nH montre un coup, D donne les cartes, Ctrl+Z annule, Ctrl+R recommence cette partie et Ctrl+N en lance une nouvelle.';

  @override
  String get aboutBody =>
      'La réussite Spider avec des calopsittes. Sans publicité, sans télémétrie et sans compte.';

  @override
  String get aboutLegal =>
      'Code sous licence Apache 2.0. Illustrations des cartes sous CC0.';

  @override
  String points(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count points',
      one: '1 point',
      zero: '0 point',
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
      other: 'Donner une rangée, il en reste $count',
      one: 'Donner la dernière rangée',
      zero: 'Donner la dernière rangée',
    );
    return '$_temp0';
  }

  @override
  String get stockEmpty => 'Plus de cartes à donner';

  @override
  String get faceDownCard => 'Carte face cachée';

  @override
  String get fillEmptyColumns =>
      'Remplissez toutes les colonnes vides avant de donner.';

  @override
  String get noMoreCards => 'Il n’y a plus de cartes à donner.';

  @override
  String get noMoves =>
      'Plus aucun coup utile. Essayez d’annuler quelques coups.';

  @override
  String get hint => 'Montrer un coup';

  @override
  String get deal => 'Donner';

  @override
  String suitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count couleurs',
      one: '1 couleur',
      zero: '0 couleur',
    );
    return '$_temp0';
  }

  @override
  String get easy => 'facile';

  @override
  String get medium => 'moyen';

  @override
  String get hard => 'difficile';

  @override
  String suitsChoice(String suits, String level) {
    return '$suits, $level';
  }
}
