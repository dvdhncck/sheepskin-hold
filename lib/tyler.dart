import 'dart:io';
import 'package:image/image.dart';

import 'package:mime/mime.dart';

import 'layabout.dart';

class Tyler {
  static Future<List<Tile>> scanDirectory(String path) async {
    List<Tile> candidates = [];
    try {
      Directory dir = Directory(path);
      List<FileSystemEntity> entities =
          await dir.list(recursive: true).toList();
      for (var entity in entities) {
        if (entity is File) {
          String? mimeType = lookupMimeType(entity.path);
          if (mimeType!.startsWith('image/')) {
            Tile tile = await _scanImage(entity);
            candidates.add(tile);
          }
        }
      }
    } catch (e) {
      /*
        FileSystemException: Directory listing failed, path = '/storage/emulated/0/Pictures/backgrounds/' (OS Error: Permission denied,
         */
      print(e);
    }

    return candidates;
  }

  static Future<Tile> _scanImage(File entity) async {
    // var image = Image.file(entity);
    Image? image = decodeImage(entity.readAsBytesSync());
    return new Tile(
        entity.path, (image?.width ?? 0).floor(), (image?.height ?? 0).floor());
  }

  static void render(int tileDensity, int targetWidth, int targetHeight, List<Tile> tiles, File destination) {
    var layabout = new Layabout(tileDensity, targetWidth, targetHeight);

    var bins = layabout.getBins(2, tiles);
    List<PlacedTile> layout = layabout.getLayout(bins);

    var image = new Image(targetWidth, targetHeight);

    for (var placedTile in layout) {
      double deltaY = placedTile.tile.h / placedTile.scaledH.toDouble();
      double deltaX = placedTile.tile.w / placedTile.scaledW.toDouble();

      var tileImage =
          decodeImage(new File(placedTile.tile.path).readAsBytesSync());
      if (tileImage != null) {
        int destY = placedTile.y;
        double srcY = .0;
        for (var y = 0; y < placedTile.scaledH; y++) {
          int destX = placedTile.x;
          double srcX = .0;
          for (var x = 0; x < placedTile.scaledW; x++) {
            image.setPixel(destX, destY, tileImage.getPixel(srcX.floor(), srcY.floor()));
            srcX += deltaX;
            destX++;
          }
          srcY += deltaY;
          destY++;
        }
      }
    }

    destination.writeAsBytesSync(new JpegEncoder().encodeImage(image));
  }
}
