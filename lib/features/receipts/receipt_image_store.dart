import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

Future<void> _thumbnail(Map<String, String> args) async {
  final decoded = img.decodeImage(await File(args['source']!).readAsBytes());
  if (decoded == null) {
    throw const FormatException('Unsupported image');
  }
  final oriented = img.bakeOrientation(decoded);
  await File(args['target']!).writeAsBytes(
    img.encodeJpg(img.copyResize(oriented, width: 320), quality: 78),
  );
}

class ReceiptImageStore {
  ReceiptImageStore(this.directory);
  final Directory directory;
  Future<({String image, String thumbnail})> save(
    String source,
    String id,
  ) async {
    await directory.create(recursive: true);
    final extension = p.extension(source).isEmpty
        ? '.jpg'
        : p.extension(source);
    final image = p.join(directory.path, '$id$extension');
    final thumbnail = p.join(directory.path, '${id}_thumb.jpg');
    try {
      await File(source).copy(image);
      await compute(_thumbnail, {'source': image, 'target': thumbnail});
      return (image: image, thumbnail: thumbnail);
    } catch (_) {
      await remove([image, thumbnail]);
      rethrow;
    }
  }

  Future<void> remove(Iterable<String?> paths) async {
    for (final path in paths) {
      if (path != null && p.isWithin(directory.path, path)) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
  }

  Future<void> prune(Set<String> referenced) async {
    if (!await directory.exists()) {
      return;
    }
    await for (final entry in directory.list()) {
      if (entry is File && !referenced.contains(entry.path)) {
        await entry.delete();
      }
    }
  }
}
