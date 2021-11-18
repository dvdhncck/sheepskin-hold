import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:local_image_provider/local_image.dart';

import 'package:mime/mime.dart';

import 'layabout.dart';
import 'package:local_image_provider/local_image_provider.dart';
import 'package:local_image_provider/local_album.dart';
import 'package:local_image_provider_platform_interface/local_album_type.dart';

class Tyler {
  Map<String, Tile> tileCache = new Map();

  Tyler(this.tileCache);

  Tyler.empty() : this(new Map());

  static const platform = MethodChannel('com.quackomatic.sheepskin/tilecache');

  Future<Map<String, Tile>> notifyPathsUpdated(List<String> paths) async {
    try {
      final List<double> result = await platform.invokeMethod('doSomething');
      print("gosh, this is exciting: ${result}");
    } on PlatformException catch (e) {
      print("Failed to get battery level: '${e.message}'.");
    }

    return tileCache;
  }

  Future<Map<String, Tile>> notifyPathsUpdated_LOCAL(List<String> paths) async {
    LocalImageProvider imageProvider = LocalImageProvider();
    bool hasPermission = await imageProvider.initialize();
    if (hasPermission) {
      List<LocalAlbum> albums =
          await imageProvider.findAlbums(LocalAlbumType.all);
      print('Got ${albums.length} albums.');
      for (var album in albums) {
        var images = await imageProvider.findImagesInAlbum(album.id!, 1024);
        for (var image in images) {
          print(
              "${album.title} : ${image.id} @ ${image.pixelWidth}x${image.pixelHeight}");
        }
      }
    } else {
      print("Images access denied.");
    }

    return tileCache;
  }

  Future<Map<String, Tile>> OLD_notifyPathsUpdated(List<String> paths) async {
    for (var path in paths) {
      try {
        Directory dir = Directory(path);
        List<FileSystemEntity> entities =
            await dir.list(recursive: true).toList();
        for (var entity in entities) {
          if (entity is File) {
            // TODO: detect if a file has changed since last time
            if (!tileCache.containsKey(entity.path)) {
              String? mimeType = lookupMimeType(entity.path);
              if (mimeType!.startsWith('image/')) {
                Tile tile = await _scanImage(entity);
                tileCache[entity.path] = tile;
              }
            }
          }
        }
      } catch (e) {
        /*
        FileSystemException: Directory listing failed, path = '/storage/emulated/0/Pictures/backgrounds/' (OS Error: Permission denied,
         */
        print(e);
      }
    }
    return tileCache;
  }

  Future<Tile> _scanImage(File entity) async {
    Image? image = decodeImage(entity.readAsBytesSync());
    return new Tile(
        entity.path, (image?.width ?? 0).floor(), (image?.height ?? 0).floor());
  }

  void render(
      int tileDensity, int targetWidth, int targetHeight, File destination) {
    var layabout = new Layabout(tileDensity, targetWidth, targetHeight);

    var tiles = tileCache.values.toList(growable: false);
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
            image.setPixel(
                destX, destY, tileImage.getPixel(srcX.floor(), srcY.floor()));
            srcX += deltaX;
            destX++;
          }
          srcY += deltaY;
          destY++;
        }
      }
    }

    destination.writeAsBytesSync(new JpegEncoder().encodeImage(image));
    print("written ${targetWidth}x$targetHeight image to ${destination.path}");
  }
}
