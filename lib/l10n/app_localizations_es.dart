// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Psito Spider';

  @override
  String get youWon => '¡Ganaste!';

  @override
  String get emptyColumn => 'Columna vacía';

  @override
  String nest(int number) {
    return 'Nido $number';
  }

  @override
  String nestOf(int number, String suit) {
    return 'Nido $number: $suit';
  }

  @override
  String cardName(String rank, String suit) {
    return '$rank de $suit';
  }

  @override
  String get rankAce => 'As';

  @override
  String get rankJack => 'Jota';

  @override
  String get rankQueen => 'Reina';

  @override
  String get rankKing => 'Rey';

  @override
  String get suitClubs => 'tréboles';

  @override
  String get suitSpades => 'picas';

  @override
  String get suitHearts => 'corazones';

  @override
  String get suitDiamonds => 'diamantes';

  @override
  String winSummary(String points, String time) {
    return '$points en $time';
  }

  @override
  String get howToPlayBody =>
      'Forma ocho secuencias del Rey al As, cada una de un solo palo. Una secuencia completa vuela sola a un nido, y ocho nidos ganan la partida.\n\nEn las columnas, cualquier carta va sobre una carta un valor más alta, sea cual sea el palo. Pero solo las cartas del mismo palo, en orden, se mueven juntas. Cualquier cosa puede ir a una columna vacía.\n\nHaz clic en el mazo para repartir una carta más en cada columna. Solo reparte cuando ninguna columna está vacía.\n\nUn palo es la partida más tranquila, dos palos son más difíciles y cuatro palos son un verdadero desafío.\n\nPuntos: 500 al empezar, 1 menos por cada movimiento y 100 más por cada nido.\n\nH muestra un movimiento, D reparte, Ctrl+Z deshace, Ctrl+R reinicia esta partida y Ctrl+N empieza una nueva.';

  @override
  String get aboutBody =>
      'El solitario Spider con cacatúas ninfa. Sin anuncios, sin telemetría y sin cuenta.';

  @override
  String get aboutLegal =>
      'Código bajo la licencia Apache 2.0. Arte de las cartas bajo CC0.';

  @override
  String points(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count puntos',
      one: '1 punto',
    );
    return '$_temp0';
  }

  @override
  String get statScore => 'Puntos';

  @override
  String dealRow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Repartir una fila, quedan $count',
      one: 'Repartir la última fila',
    );
    return '$_temp0';
  }

  @override
  String get stockEmpty => 'No quedan cartas por repartir';

  @override
  String get faceDownCard => 'Carta boca abajo';

  @override
  String get fillEmptyColumns =>
      'Llena todas las columnas vacías antes de repartir.';

  @override
  String get noMoreCards => 'No quedan cartas por repartir.';

  @override
  String get noMoves =>
      'No queda ningún movimiento útil. Prueba a deshacer algunos movimientos.';

  @override
  String get hint => 'Mostrar un movimiento';

  @override
  String get deal => 'Repartir';

  @override
  String suitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palos',
      one: '1 palo',
    );
    return '$_temp0';
  }

  @override
  String get easy => 'fácil';

  @override
  String get medium => 'medio';

  @override
  String get hard => 'difícil';

  @override
  String suitsChoice(String suits, String level) {
    return '$suits, $level';
  }
}
