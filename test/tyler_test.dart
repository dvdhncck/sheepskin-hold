import 'dart:io';

import 'package:sheepskin/tyler.dart';
import 'package:test/test.dart';

void main() {
  test('Tyler The Creator', () async {
    var tyler = Tyler.empty();

    await tyler.notifyPathsUpdated(['test/images']);

    for(var i=0;i < 10; i++) {
      // landscape(ish)
      int targetH = 192;
      int targetW = 108;

      tyler.render(3, targetW, targetH, new File("test/result$i.jpg"));
    }
  });
}
