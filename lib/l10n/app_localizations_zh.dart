// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Psito Spider';

  @override
  String get youWon => '你赢了！';

  @override
  String get emptyColumn => '空列';

  @override
  String nest(int number) {
    return '鸟巢 $number';
  }

  @override
  String nestOf(int number, String suit) {
    return '鸟巢 $number：$suit';
  }

  @override
  String cardName(String rank, String suit) {
    return '$suit$rank';
  }

  @override
  String get rankAce => 'A';

  @override
  String get rankJack => 'J';

  @override
  String get rankQueen => 'Q';

  @override
  String get rankKing => 'K';

  @override
  String get suitClubs => '梅花';

  @override
  String get suitSpades => '黑桃';

  @override
  String get suitHearts => '红心';

  @override
  String get suitDiamonds => '方块';

  @override
  String winSummary(String points, String time) {
    return '用时 $time，得 $points';
  }

  @override
  String get howToPlayBody =>
      '从 K 到 A 排出八组同花色的顺序牌。一组完整的顺序牌会自己飞进鸟巢，八个鸟巢就赢得游戏。\n\n在列中，任何牌都可以放在比它大一点的牌上，花色不限。但只有同花色、按顺序排好的牌才能一起移动。空列里可以放任何牌。\n\n单击牌堆，会在每一列上再发一张牌。只有没有空列时才能发牌。\n\n一种花色最轻松，两种花色更难，四种花色是真正的挑战。\n\n得分：开局 500 分，每走一步减 1 分，每完成一个鸟巢加 100 分。\n\nH 显示一步可走的牌，D 发牌，Ctrl+Z 撤销，Ctrl+R 重新开始这一局，Ctrl+N 开始新的一局。';

  @override
  String get aboutBody => '与玄凤鹦鹉一起玩的蜘蛛纸牌。没有广告，没有遥测，也不需要账号。';

  @override
  String get aboutLegal => '代码采用 Apache 2.0 许可证。纸牌美术采用 CC0。';

  @override
  String points(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 分',
    );
    return '$_temp0';
  }

  @override
  String get statScore => '得分';

  @override
  String dealRow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '发一行，还剩 $count 行',
      one: '发最后一行',
    );
    return '$_temp0';
  }

  @override
  String get stockEmpty => '没有可发的牌了';

  @override
  String get faceDownCard => '背面朝上的牌';

  @override
  String get fillEmptyColumns => '发牌前请先填满所有空列。';

  @override
  String get noMoreCards => '没有可发的牌了。';

  @override
  String get noMoves => '没有有用的走法了。试着撤销几步。';

  @override
  String get hint => '显示一步走法';

  @override
  String get deal => '发牌';

  @override
  String suitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 种花色',
    );
    return '$_temp0';
  }

  @override
  String get easy => '简单';

  @override
  String get medium => '中等';

  @override
  String get hard => '困难';

  @override
  String suitsChoice(String suits, String level) {
    return '$suits，$level';
  }
}
