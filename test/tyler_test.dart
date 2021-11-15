import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:sheepskin/layabout.dart';
import 'package:sheepskin/tyler.dart';
import 'package:test/test.dart';

void main() {
  test('Tyler The Creator', () async {
    //
    // Tyler.render(Layabout layabout) {
    //
    // }

    //var tiles = await Tyler.scanDirectory('/home/dave/projects/sheepskin/test/images');
    var tiles = await Tyler.scanDirectory('test/images');

    for(var i=0;i < 10; i++) {
      // landscape(ish)
      int targetH = 192 * 3;
      int targetW = 108 * 3;

      // we expect layouts of either 2 side-by-side portraits, or 2x2 landscape
      Tyler.render(3, targetW, targetH, tiles, new File("test/result$i.jpg"));
    }
  });
}
