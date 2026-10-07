import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrLine {
  OcrLine(this.text, this.bounds);
  final String text;
  final Rect bounds;
}

class OcrResult {
  OcrResult(this.text, this.lines, this.elapsed);
  final String text;
  final List<OcrLine> lines;
  final Duration elapsed;
}

class OcrService {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  Future<OcrResult> recognize(String path) async {
    final timer = Stopwatch()..start();
    final result = await _recognizer.processImage(
      InputImage.fromFilePath(path),
    );
    timer.stop();
    final lines =
        result.blocks
            .expand((b) => b.lines)
            .map((l) => OcrLine(l.text, l.boundingBox))
            .toList()
          ..sort((a, b) => a.bounds.center.dy.compareTo(b.bounds.center.dy));
    // Reassemble horizontally aligned label/amount blocks into visual rows.
    final rows = <List<OcrLine>>[];
    for (final line in lines) {
      if (rows.isNotEmpty &&
          (rows.last.first.bounds.center.dy - line.bounds.center.dy).abs() <
              (rows.last.first.bounds.height < line.bounds.height
                      ? rows.last.first.bounds.height
                      : line.bounds.height) *
                  .5) {
        rows.last.add(line);
      } else {
        rows.add([line]);
      }
    }
    final text = rows
        .map((row) {
          row.sort((a, b) => a.bounds.left.compareTo(b.bounds.left));
          return row.map((l) => l.text).join(' ');
        })
        .join('\n');
    return OcrResult(text, lines, timer.elapsed);
  }

  Future<void> close() => _recognizer.close();
}
