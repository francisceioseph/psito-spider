// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Psito Spider';

  @override
  String get youWon => 'Você venceu!';

  @override
  String get emptyColumn => 'Coluna vazia';

  @override
  String nest(int number) {
    return 'Ninho $number';
  }

  @override
  String nestOf(int number, String suit) {
    return 'Ninho $number: $suit';
  }

  @override
  String cardName(String rank, String suit) {
    return '$rank de $suit';
  }

  @override
  String get rankAce => 'Ás';

  @override
  String get rankJack => 'Valete';

  @override
  String get rankQueen => 'Dama';

  @override
  String get rankKing => 'Rei';

  @override
  String get suitClubs => 'paus';

  @override
  String get suitSpades => 'espadas';

  @override
  String get suitHearts => 'copas';

  @override
  String get suitDiamonds => 'ouros';

  @override
  String winSummary(String points, String time) {
    return '$points em $time';
  }

  @override
  String get howToPlayBody =>
      'Monte oito sequências do Rei ao Ás, cada uma de um só naipe. Uma sequência completa voa sozinha para um ninho, e oito ninhos vencem o jogo.\n\nNas colunas, qualquer carta vai sobre uma carta um valor acima, de qualquer naipe. Mas só cartas do mesmo naipe, em ordem, se movem juntas. Qualquer coisa pode ir para uma coluna vazia.\n\nClique no monte para dar mais uma carta em cada coluna. Ele só dá cartas quando nenhuma coluna está vazia.\n\nUm naipe é o jogo mais tranquilo, dois naipes são mais difíceis, e quatro naipes são um desafio de verdade.\n\nPontos: 500 no começo, menos 1 por jogada e mais 100 por ninho.\n\nH mostra uma jogada, D dá cartas, Ctrl+Z desfaz, Ctrl+R recomeça este jogo e Ctrl+N começa um novo.';

  @override
  String get aboutBody =>
      'Paciência Spider com calopsitas. Sem anúncios, sem telemetria e sem conta.';

  @override
  String get aboutLegal =>
      'Código sob a licença Apache 2.0. Arte das cartas sob CC0.';

  @override
  String points(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pontos',
      one: '1 ponto',
      zero: '0 ponto',
    );
    return '$_temp0';
  }

  @override
  String get statScore => 'Pontos';

  @override
  String dealRow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dar uma fileira, restam $count',
      one: 'Dar a última fileira',
      zero: 'Dar a última fileira',
    );
    return '$_temp0';
  }

  @override
  String get stockEmpty => 'Não há mais cartas para dar';

  @override
  String get faceDownCard => 'Carta virada para baixo';

  @override
  String get fillEmptyColumns =>
      'Preencha todas as colunas vazias antes de dar cartas.';

  @override
  String get noMoreCards => 'Não há mais cartas para dar.';

  @override
  String get noMoves =>
      'Não sobrou jogada útil. Tente desfazer algumas jogadas.';

  @override
  String get hint => 'Mostrar uma jogada';

  @override
  String get deal => 'Dar cartas';

  @override
  String suitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count naipes',
      one: '1 naipe',
      zero: '0 naipe',
    );
    return '$_temp0';
  }

  @override
  String get easy => 'fácil';

  @override
  String get medium => 'médio';

  @override
  String get hard => 'difícil';

  @override
  String suitsChoice(String suits, String level) {
    return '$suits, $level';
  }
}
