import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/design.dart';
import '../receipts/ocr_service.dart';
import '../receipts/receipt_parser.dart';
import '../transactions/expense_editor.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});
  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen>
    with WidgetsBindingObserver {
  CameraController? camera;
  bool busy = false, failed = false, flash = false;
  int generation = 0;
  Offset? focus;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initialize();
    recoverPicker();
  }

  Future<void> recoverPicker() async {
    try {
      final lost = await ImagePicker().retrieveLostData();
      if (mounted && !busy && lost.files?.isNotEmpty == true) {
        await process(lost.files!.first.path);
      }
    } catch (_) {
      /* Gallery recovery is optional; normal capture remains available. */
    }
  }

  Future<void> initialize() async {
    final ticket = ++generation;
    final old = camera;
    camera = null;
    await old?.dispose();
    if (!mounted || ticket != generation || busy) {
      return;
    }
    setState(() => failed = false);
    CameraController? next;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw StateError('No camera');
      }
      next = CameraController(
        cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        ),
        ResolutionPreset.high,
        enableAudio: false,
      );
      await next.initialize();
      if (!mounted || ticket != generation || busy) {
        await next.dispose();
        return;
      }
      await next.setFlashMode(FlashMode.off);
      setState(() {
        camera = next;
        flash = false;
      });
    } catch (_) {
      await next?.dispose();
      if (mounted && ticket == generation) {
        setState(() => failed = true);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      generation++;
      final old = camera;
      camera = null;
      old?.dispose();
    } else if (state == AppLifecycleState.resumed && !busy) {
      initialize();
    }
  }

  @override
  void dispose() {
    generation++;
    WidgetsBinding.instance.removeObserver(this);
    camera?.dispose();
    super.dispose();
  }

  Future<void> process(String source, {bool sample = false}) async {
    if (busy || !mounted) {
      return;
    }
    setState(() => busy = true);
    String? staged;
    String? croppedPath;
    final recognizer = OcrService();
    var handedOff = false;
    try {
      final crop = sample
          ? null
          : await ImageCropper().cropImage(
              sourcePath: source,
              compressFormat: ImageCompressFormat.jpg,
              compressQuality: 93,
              maxWidth: 2000,
              maxHeight: 3000,
              uiSettings: [
                AndroidUiSettings(
                  toolbarTitle: context.l.crop,
                  toolbarColor: ink,
                  toolbarWidgetColor: Colors.white,
                  lockAspectRatio: false,
                  hideBottomControls: false,
                ),
              ],
            );
      if (!sample && crop == null) {
        return;
      }
      croppedPath = crop?.path;
      final temporary = await getTemporaryDirectory();
      final folder = Directory('${temporary.path}/receiptflow_scans');
      await folder.create(recursive: true);
      staged = '${folder.path}/${DateTime.now().microsecondsSinceEpoch}.jpg';
      await File(croppedPath ?? source).copy(staged);
      final result = await recognizer.recognize(staged);
      final parsed = ReceiptParser().parse(result.text);
      if (mounted) {
        handedOff = true;
        context.pushReplacement(
          '/edit',
          extra: EditorInput(
            parsed: parsed,
            imagePath: staged,
            rawText: result.text,
            ocrMilliseconds: result.elapsed.inMilliseconds,
            ownsTemporaryImage: true,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        context.message(context.l.ocrError);
      }
    } finally {
      await recognizer.close();
      if (!handedOff && staged != null) {
        await _delete(staged);
      }
      if (croppedPath != null) {
        await _delete(croppedPath);
      }
      if (mounted && !handedOff) {
        setState(() => busy = false);
        if (camera == null) {
          initialize();
        }
      }
    }
  }

  Future<void> _delete(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) {
        await f.delete();
      }
    } on FileSystemException {
      /* Temp files may already be removed by Android. */
    }
  }

  Future<void> capture() async {
    final active = camera;
    if (busy ||
        active == null ||
        !active.value.isInitialized ||
        active.value.isTakingPicture) {
      return;
    }
    try {
      final photo = await active.takePicture();
      await process(photo.path);
      await _delete(photo.path);
    } catch (_) {
      if (mounted) {
        context.message(context.l.cameraError);
      }
    }
  }

  Future<void> gallery() async {
    if (busy) {
      return;
    }
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        await process(image.path);
      }
    } catch (_) {
      if (mounted) {
        context.message(context.l.genericError);
      }
    }
  }

  Future<void> sample() async {
    if (busy) {
      return;
    }
    try {
      final bytes = await rootBundle.load('assets/receipts/sample_receipt.jpg');
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/receiptflow_sample.jpg');
      await f.writeAsBytes(bytes.buffer.asUint8List());
      await process(f.path, sample: true);
      await _delete(f.path);
    } catch (_) {
      if (mounted) {
        context.message(context.l.genericError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = camera;
    return PopScope(
      canPop: !busy,
      child: Scaffold(
        backgroundColor: const Color(0xFF102320),
        appBar: AppBar(
          backgroundColor: const Color(0xFF102320),
          foregroundColor: Colors.white,
          title: Text(context.l.camera),
          actions: [
            IconButton(
              tooltip: context.l.flash,
              onPressed: busy || active == null
                  ? null
                  : () async {
                      try {
                        await active.setFlashMode(
                          flash ? FlashMode.off : FlashMode.torch,
                        );
                        if (mounted) {
                          setState(() => flash = !flash);
                        }
                      } catch (_) {
                        if (context.mounted) {
                          context.message(context.l.genericError);
                        }
                      }
                    },
              icon: Icon(
                flash ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              ),
            ),
          ],
        ),
        body: busy
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFFBDEAC8)),
                    const SizedBox(height: 28),
                    Text(
                      context.l.processing,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.l.processingHint,
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
              )
            : SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: LayoutBuilder(
                            builder: (_, box) {
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (active != null &&
                                      active.value.isInitialized)
                                    Center(
                                      child: AspectRatio(
                                        aspectRatio:
                                            1 / active.value.aspectRatio,
                                        child: GestureDetector(
                                          onTapDown: (details) async {
                                            final render =
                                                details.localPosition;
                                            // The GestureDetector has the same geometry as the visible preview.
                                            final previewHeight =
                                                (box.maxWidth *
                                                        active
                                                            .value
                                                            .aspectRatio)
                                                    .clamp(0.0, box.maxHeight);
                                            final previewWidth =
                                                previewHeight /
                                                active.value.aspectRatio;
                                            final point = Offset(
                                              (render.dx / previewWidth).clamp(
                                                0,
                                                1,
                                              ),
                                              (render.dy / previewHeight).clamp(
                                                0,
                                                1,
                                              ),
                                            );
                                            try {
                                              await active.setFocusPoint(point);
                                              await active.setExposurePoint(
                                                point,
                                              );
                                              if (mounted) {
                                                setState(() => focus = point);
                                              }
                                            } catch (_) {
                                              /* Fixed-focus camera: capture still works. */
                                            }
                                          },
                                          child: CameraPreview(active),
                                        ),
                                      ),
                                    )
                                  else
                                    Center(
                                      child: failed
                                          ? Padding(
                                              padding: const EdgeInsets.all(24),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.camera_alt_outlined,
                                                    size: 48,
                                                    color: Colors.white60,
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Text(
                                                    context.l.cameraError,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: initialize,
                                                    child: Text(
                                                      context.l.retry,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : const CircularProgressIndicator(),
                                    ),
                                  IgnorePointer(
                                    child: CustomPaint(
                                      painter: _FramePainter(),
                                    ),
                                  ),
                                  if (focus != null)
                                    const IgnorePointer(
                                      child: Center(
                                        child: Icon(
                                          Icons.center_focus_strong,
                                          color: Colors.white54,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        context.l.captureHint,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          tooltip: context.l.gallery,
                          onPressed: gallery,
                          icon: const Icon(
                            Icons.photo_library_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: context.l.shutter,
                          child: InkResponse(
                            onTap: active == null ? null : capture,
                            child: Container(
                              width: 76,
                              height: 76,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: active == null
                                      ? Colors.white30
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: context.l.manual,
                          onPressed: () => context.pushReplacement('/edit'),
                          icon: const Icon(
                            Icons.edit_note_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: sample,
                      icon: const Icon(Icons.receipt_outlined, size: 18),
                      label: Text(context.l.sampleReceipt),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFBDEAC8),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      size.width * .09,
      size.height * .09,
      size.width * .82,
      size.height * .82,
    );
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      paint,
    );
    paint
      ..strokeWidth = 4
      ..color = const Color(0xFFBDEAC8);
    const length = 24.0;
    for (final corner in [
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ]) {
      final dx = corner.dx == rect.left ? length : -length;
      final dy = corner.dy == rect.top ? length : -length;
      canvas.drawLine(corner.translate(dx, 0), corner, paint);
      canvas.drawLine(corner, corner.translate(0, dy), paint);
    }
  }

  @override
  bool shouldRepaint(_FramePainter old) => false;
}
