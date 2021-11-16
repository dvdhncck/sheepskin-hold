import 'package:flutter/cupertino.dart';
import 'package:tuple/tuple.dart';
import 'dart:math';

class Tile {
  final String path;
  final int w;
  final int h;
  late final int id;
  late final aspect;

  static int nextId = 1;

  static Tile NotTile = new Tile("NotTile",0,0);

  Tile(this.path, this.w, this.h) {
    this.id = nextId++;
    this.aspect = w.toDouble() / h.toDouble();
  }

  Tile.of(int w, int h) : this("${w}x$h", w, h);

  bool fitsSpace(Tile space, double tolerance) {
    double fit = aspect / space.aspect;
    return (1.0 - fit).abs() <= tolerance;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tile &&
          runtimeType == other.runtimeType &&
          aspect == other.aspect;

  @override
  int get hashCode => aspect.hashCode;

  @override
  String toString() {
    return "{${w}x$h:$aspect}";
  }
}

typedef Bins = Map<Tile, List<Tile>>;

class PlacedTile {
  Tile tile;
  int x;
  int y;
  int scaledW;
  int scaledH;

  PlacedTile(this.tile, this.x, this.y, this.scaledW, this.scaledH);

  @override
  String toString() {
    return "{$tile->${scaledW}x$scaledH@$x,$y}";
  }
}

class Layabout {
  int gridDensity;
  int width;
  int height;
  late double targetAspect;

  // GridDensity of 2 selects a layout of the nicest fit of  2x1, 1x2 or 2x2

  Layabout(this.gridDensity, this.width, this.height) {
    this.targetAspect = width.toDouble() / height.toDouble();
  }

  // Attempts to create the desired number of bins where each bin
  // contains tiles of a similar aspect ratio.
  // Each tile will be in exactly 1 bin.
  // Each bin will contain at least one tile.
  // May return more or less than the desired number of bins.
  Bins getBins(int desiredBinCount, List<Tile> tiles) {
    var tolerance = 0.0;
    var bins = _getBinsRequired(tolerance, tiles);

    while (bins.length != desiredBinCount && tolerance <= 1.0) {
      tolerance += 0.1;
      bins = _getBinsRequired(tolerance, tiles);
    }

    return bins;
  }

  // Returns a collection of tiles arranged in a grid layout.
  // Tiles may appear more than once in the collection if there are not enough.
  // the size and density of the layout is determined by the constructor parameters
  List<PlacedTile> getLayout(Bins bins) {
    Tile key = (bins.keys.toList()..shuffle()).first;
    List<Tile> stack = bins[key] ??
        bins.values
            .first; // pick a random key, and look up the associate List<Tile>

    var dimension = getArrangement(stack);

    var tileWidth = (width.toDouble() / dimension.item1.toDouble()).floor();
    var tileHeight = (height.toDouble() / dimension.item2.toDouble()).floor();
    List<PlacedTile> layout = [];
    int y = 0;
    for (var v = 0; v < dimension.item2; v++) {
      int x = 0;
      for (var h = 0; h < dimension.item1; h++) {
        stack.shuffle();
        layout.add(new PlacedTile(stack[0], x, y, tileWidth, tileHeight));
        x += tileWidth;
      }
      y += tileHeight;
    }
    return layout;
  }

  // gets the 'best' option based on gridDensity
  Tuple2<int, int> getArrangement(List<Tile> stack) {
    Tuple3<int, int, double> exact = getArrangementFor(gridDensity, stack);
    Tuple3<int, int, double> lower = getArrangementFor(gridDensity - 1, stack);

    // pick the best score; in the event of a tie, pick the smaller tile count
    if (exact.item3 == lower.item3) {
      int exactTileCount = exact.item1 * exact.item2;
      int lowerTileCount = lower.item1 * lower.item2;
      if(lowerTileCount <= 1) {
        return new Tuple2(exact.item1, exact.item2);
      }
      if(exactTileCount <= 1) {
        return new Tuple2(lower.item1, lower.item2);
      }
      if (exactTileCount <= lowerTileCount) {
        return new Tuple2(exact.item1, exact.item2);
      } else {
        return new Tuple2(lower.item1, lower.item2);
      }
    } else {
      if (exact.item3 <= lower.item3) {
        return new Tuple2(exact.item1, exact.item2);
      } else {
        return new Tuple2(lower.item1, lower.item2);
      }
    }
  }

  String describeAspect(double aspect) {
    if (aspect == 1.0) {
      return "square";
    } else {
      return aspect > 1.0 ? "portrait" : "landscape";
    }
  }

  // density of N selects a layout of the nicest fit of  NxN, NxM or MxN
  Tuple3<int, int, double> getArrangementFor(int density, List<Tile> stack) {
    print("target aspect=$targetAspect (${describeAspect(targetAspect)})");

    // find the average aspect of the stack
    double tileAspectSum = .0;
    for (var tile in stack) {
      tileAspectSum += tile.aspect;
    }
    double stackAspect = tileAspectSum / stack.length.toDouble();

    print("stack tile aspect=$stackAspect (${describeAspect(stackAspect)})");

    // tile arrangement will be NxM   (M can be == N)
    // if we fix one dimension as N tile, what is the 'best'' value of M?

    // layout A; N on the horizontal
    int nA = density;
    double tileWidthA = width.toDouble() / nA.toDouble();
    double tileHeightA = tileWidthA / stackAspect;
    int mA = (height.toDouble() / tileHeightA).round();

    // layout B; N on the vertical
    int mB = density;
    double tileHeightB = height.toDouble() / mB.toDouble();
    double tileWidthB = tileHeightB * stackAspect;
    int nB = (width.toDouble() / tileWidthB).round();

    // layout C; NxN
    int nC = density;
    int mC = density;
    double tileWidthC = width.toDouble() / nC.toDouble();
    double tileHeightC = height.toDouble() / mC.toDouble();

    double scaledTileAspectA = tileWidthA / tileHeightA;
    double scaledTileAspectB = tileWidthB / tileHeightB;
    double scaledTileAspectC = tileWidthC / tileHeightC;

    // score each of the possible arrangements based on how distorted the tiles are
    var fitA = score(density, stackAspect, nA, mA, scaledTileAspectA);
    var fitB = score(density, stackAspect, nB, mB, scaledTileAspectB);
    var fitC = score(density, stackAspect, nC, mC, scaledTileAspectC);

    print("A: ${nA}x$mA (${describeAspect(scaledTileAspectA)} ... $fitA)");
    print("B: ${nB}x$mB (${describeAspect(scaledTileAspectB)} ... $fitB)");
    print("C: ${nC}x$mC (${describeAspect(scaledTileAspectC)} ... $fitC)");

    if (fitA <= fitB && fitA <= fitC) {
      return new Tuple3(nA, mA, fitA);
    }
    if (fitB <= fitC) {
      return new Tuple3(nB, mB, fitB);
    }
    return new Tuple3(nC, mC, fitC);
  }

  // Return a score based on how similar the candidate arrangement
  // is to the desired one.
  // Lower scores are better
  // if either the count in either dimension is 0, give massive score
  // if the scaled is of the wrong aspect (portrait vs landscape), give massive score
  double score(
      int density, double tileAspect, int tilesV, int tilesH, double scaledTileAspect) {
    if (tilesH == 0 || tilesV == 0) {
      return double.maxFinite;
    }
    if(tileAspect < 1.0 && scaledTileAspect > 1.0) {
      return double.maxFinite;
    }
    if(tileAspect > 1.0 && scaledTileAspect < 1.0) {
      return double.maxFinite;
    }
    double aspectScore = (tileAspect - scaledTileAspect) * (tileAspect - scaledTileAspect);
    double dimensionScore = (gridDensity.toDouble() - tilesV).abs() + (gridDensity.toDouble() - tilesH).abs();
    return aspectScore + dimensionScore;
  }

  Bins _getBinsRequired(double tolerance, List<Tile> tiles) {
    var bins = new Map<Tile, List<Tile>>();
    for (var t in tiles) {
      // is there a suitable bin?
      var chosen = _bestBin(t, bins, tolerance);
      if (chosen == null) {
        // no, so create a new one
        bins[t] = [t];
      } else {
        // otherwise, add this tiles to the chosen bin
        bins[chosen]?.add(t);
      }
    }
    // print("${rectangles.length} items, tolerance=$tolerance, bins_required=${bins.length}");

    return bins;
  }

  // find the 1st bin with an aspect ratio close enough to that
  // of the candidate tile, or null if no bins are suitable
  Tile? _bestBin(Tile candidate, Map bins, double tolerance) {
    for (var bin in bins.keys) {
      if (candidate.fitsSpace(bin, tolerance)) {
        return bin;
      }
    }
    return null;
  }
}
