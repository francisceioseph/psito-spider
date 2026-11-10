import 'package:flutter_test/flutter_test.dart';
import 'package:psito_spider/src/game/game_state.dart';
import 'package:psito_spider/src/game/scores.dart';
import 'package:shared_preferences/shared_preferences.dart';

Score score(String name, int points, [int seconds = 60]) =>
    Score(name: name, points: points, seconds: seconds, game: 1);

void main() {
  test('more points come first, and the time breaks ties', () {
    var scores = insertScore(const [], score('slow', 500, 90));
    scores = insertScore(scores, score('best', 700));
    scores = insertScore(scores, score('quick', 500, 30));
    expect(scores.map((s) => s.name), ['best', 'quick', 'slow']);
  });

  test('only the ten best are kept', () {
    var scores = <Score>[];
    for (var i = 0; i < 12; i++) {
      scores = insertScore(scores, score('$i', 100 - i));
    }
    expect(scores.length, maxScores);
    expect(scores.last.name, '9');
  });

  test('each number of suits keeps its own scores', () async {
    SharedPreferences.setMockInitialValues({});
    const store = ScoreStore();
    await store.save(Suits.two, [score('Ana', 90)]);
    expect((await store.load(Suits.two)).single.name, 'Ana');
    expect(await store.load(Suits.one), isEmpty);

    SharedPreferences.setMockInitialValues({'scores_two': 'not json'});
    expect(await store.load(Suits.two), isEmpty);
  });

  test('the suits chosen are remembered', () async {
    SharedPreferences.setMockInitialValues({});
    const store = ScoreStore();
    expect(await store.lastSuits(), Suits.one);
    await store.saveSuits(Suits.four);
    expect(await store.lastSuits(), Suits.four);
  });
}
