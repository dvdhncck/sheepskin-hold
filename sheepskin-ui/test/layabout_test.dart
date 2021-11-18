import 'package:sheepskin/layabout.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

void main() {
  test('Layout of one rectangle results in a single bin', () {
    var actual = new Layabout(5, 200, 300).getBins(1, [Tile.of(10, 3)]);

    expect(actual.keys.length, equals(1));
    expect(actual.keys.first, equals(Tile.of(10, 3)));
  });

  test('Layout of 2 identical rectangles results in a single bin', () {
    var actual =
        new Layabout(5, 200, 300).getBins(1, [Tile.of(10, 3), Tile.of(10, 3)]);

    expect(actual.keys.length, equals(1));
    expect(actual.values.first.length, equals(2));
  });

  test('Layout of 2 different rectangles results in 2 bins', () {
    var actual =
        new Layabout(5, 100, 300).getBins(2, [Tile.of(10, 3), Tile.of(5, 5)]);

    expect(actual.keys.length, equals(2));
    expect(actual.keys.toList()[0], equals(Tile.of(10, 3)));
    expect(actual.keys.toList()[1], equals(Tile.of(5, 5)));
  });

  test(
      'Layout of a collection with repeats of 2 \\'
      'identical aspects results in 2 bins', () {
    var actual = new Layabout(5, 200, 300).getBins(2, [
      // 4 lots of 10x3 and 2 lots of 5x5
      Tile.of(10, 3),
      Tile.of(5, 5),
      Tile.of(10, 3),
      Tile.of(5, 5),
      Tile.of(10, 3),
      Tile.of(10, 3),
    ]);

    expect(actual.keys.length, equals(2));

    var bin1Key = actual.keys.toList()[0];
    var bin2Key = actual.keys.toList()[1];

    expect(actual[bin1Key]?.length, equals(4)); // 4 of 10x3
    expect(actual[bin2Key]?.length, equals(2)); // 2 of 5x5
  });

  test(
      'Layout of a collection with repeats of 2 similar, \\'
      'but not identical aspects, results in 2 bins', () {
    var actual = new Layabout(2, 200, 300).getBins(2, [
      // none are the same, but they are broadly 10x3 and 5x5
      Tile.of(11, 3),
      Tile.of(5, 6),
      Tile.of(9, 3),
      Tile.of(66, 64),
      Tile.of(10, 4),
      Tile.of(33, 12),
    ]);

    expect(actual.keys.length, equals(2));

    var bin1Key = actual.keys.toList()[0];
    var bin2Key = actual.keys.toList()[1];

    print("bin1: ${actual[bin1Key]}\nbin2: ${actual[bin2Key]}");

    expect(actual[bin1Key]?.length, equals(4)); // 4 of mostly short wide things
    expect(
        actual[bin2Key]?.length, equals(2)); // 2 of more or less square things
  });

  test(
      'Layout of a collection with repeats of 2 similar, \\'
      'but not identical aspects, results in 2 bins', () {
    Bins bins = new Map();
    bins[Tile.of(100, 200)] = [
      Tile.of(75, 150),
      Tile.of(75, 150),
      Tile.of(75, 150)
    ];

    List<PlacedTile> actual = new Layabout(2, 300, 280).getLayout(bins);

    print(actual);

    expect(actual.length, equals(2)); // grid of 2x2
  });

  test('Landscape into Portrait', () {
    List<Tile> stack = [Tile.of(75, 151), Tile.of(74, 150), Tile.of(76, 150)];

    Tuple2<int, int> portrait = new Layabout(4, 80, 30).getArrangement(stack);

    print("Landscape into Portrait: $portrait");
  });

  test('Landscape into Landscape', () {
    List<Tile> stack = [Tile.of(640,480), Tile.of(640,480), Tile.of(640,480)];

    Tuple2<int, int> portrait = new Layabout(4, 80, 30).getArrangement(stack);

    print("Landscape into Landscape: $portrait");
  });

  test('Portrait into Landscape', () {
    List<Tile> stack = [Tile.of(108,192), Tile.of(108,192), Tile.of(108,192)];

    Tuple2<int, int> portrait = new Layabout(4, 1400, 900).getArrangement(stack);

    print("Portrait into Landscape: $portrait");
  });

  test('Portrait into Portrait', () {
    List<Tile> stack = [Tile.of(108,192), Tile.of(108,192), Tile.of(108,192)];

    Tuple2<int, int> portrait = new Layabout(4, 900, 1600).getArrangement(stack);

    // why does this pick 4x4 ?

    print("Portrait into Portrait: $portrait");
  });
}
