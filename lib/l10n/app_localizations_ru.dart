// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Psito Spider';

  @override
  String get youWon => 'Вы победили!';

  @override
  String get emptyColumn => 'Пустая колонка';

  @override
  String nest(int number) {
    return 'Гнездо $number';
  }

  @override
  String nestOf(int number, String suit) {
    return 'Гнездо $number: $suit';
  }

  @override
  String cardName(String rank, String suit) {
    return '$rank $suit';
  }

  @override
  String get rankAce => 'Туз';

  @override
  String get rankJack => 'Валет';

  @override
  String get rankQueen => 'Дама';

  @override
  String get rankKing => 'Король';

  @override
  String get suitClubs => 'треф';

  @override
  String get suitSpades => 'пик';

  @override
  String get suitHearts => 'червей';

  @override
  String get suitDiamonds => 'бубен';

  @override
  String winSummary(String points, String time) {
    return '$points за $time';
  }

  @override
  String get howToPlayBody =>
      'Соберите восемь последовательностей от короля до туза, каждую одной масти. Полная последовательность сама улетает в гнездо, а восемь гнёзд приносят победу.\n\nВ колонках любую карту можно положить на карту на одно значение старше, любой масти. Но вместе перемещаются только карты одной масти, по порядку. В пустую колонку можно положить что угодно.\n\nЩёлкните по колоде, чтобы сдать ещё по одной карте в каждую колонку. Она сдаёт, только когда пустых колонок нет.\n\nОдна масть — самая спокойная игра, две масти сложнее, а четыре масти — настоящее испытание.\n\nОчки: 500 в начале, минус 1 за каждый ход и плюс 100 за каждое гнездо.\n\nH показывает ход, D сдаёт карты, Ctrl+Z отменяет, Ctrl+R начинает эту партию заново, а Ctrl+N — новую.';

  @override
  String get aboutBody =>
      'Пасьянс «Паук» с кореллами. Без рекламы, без телеметрии и без учётной записи.';

  @override
  String get aboutLegal =>
      'Код под лицензией Apache 2.0. Рисунки карт под CC0.';

  @override
  String points(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count очков',
      few: '$count очка',
      one: '$count очко',
      zero: '0 очков',
    );
    return '$_temp0';
  }

  @override
  String get statScore => 'Очки';

  @override
  String dealRow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Сдать ряд, осталось $count',
      few: 'Сдать ряд, осталось $count',
      one: 'Сдать последний ряд',
    );
    return '$_temp0';
  }

  @override
  String get stockEmpty => 'Карт для сдачи больше нет';

  @override
  String get faceDownCard => 'Карта рубашкой вверх';

  @override
  String get fillEmptyColumns =>
      'Заполните все пустые колонки, прежде чем сдавать.';

  @override
  String get noMoreCards => 'Карт для сдачи больше нет.';

  @override
  String get noMoves =>
      'Полезных ходов не осталось. Попробуйте отменить несколько ходов.';

  @override
  String get hint => 'Показать ход';

  @override
  String get deal => 'Сдать';

  @override
  String suitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count мастей',
      few: '$count масти',
      one: '$count масть',
    );
    return '$_temp0';
  }

  @override
  String get easy => 'легко';

  @override
  String get medium => 'средне';

  @override
  String get hard => 'сложно';

  @override
  String suitsChoice(String suits, String level) {
    return '$suits, $level';
  }
}
