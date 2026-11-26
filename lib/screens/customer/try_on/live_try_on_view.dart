import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../theme/app_colors.dart';
import '../../../models/try_on_style.dart';
import '../../../services/face_detector_service.dart';
import '../../../widgets/try_on_overlay_painter.dart';
import '../../../widgets/try_on_controls.dart';

class LiveTryOnView extends StatefulWidget {
  const LiveTryOnView({super.key});

  @override
  State<LiveTryOnView> createState() => _LiveTryOnViewState();
}

class _LiveTryOnViewState extends State<LiveTryOnView> with WidgetsBindingObserver {
  CameraController? _cameraController;
  final FaceDetectorService _detectorService = FaceDetectorService();

  List<CameraDescription> _cameras = [];
  Face? _detectedFace;
  bool _isProcessingFrame = false;
  bool _isCameraInitialized = false;

  TryOnStyle? _selectedHairStyle = TryOnStyle.hairstyles.first; // Default: Classic Fade
  TryOnStyle? _selectedBeardStyle = TryOnStyle.beardStyles[3]; // Default: Short Beard

  double _userScale = 1.0;
  double _userOffsetY = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopLiveStream();
    _cameraController?.dispose();
    _detectorService.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      final frontCamera = _cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();

      if (!mounted) return;

      setState(() => _isCameraInitialized = true);

      _cameraController!.startImageStream((CameraImage image) {
        _processFrame(image, frontCamera);
      });
    } catch (e) {
      debugPrint("Error initializing live camera: $e");
    }
  }

  void _stopLiveStream() {
    if (_cameraController != null && _cameraController!.value.isStreamingImages) {
      _cameraController!.stopImageStream();
    }
  }

  Future<void> _processFrame(CameraImage image, CameraDescription camera) async {
    if (_isProcessingFrame) return; // Drop frame if ML Kit is still processing current frame

    _isProcessingFrame = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final InputImageRotation imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation0deg;
      final InputImageFormat inputImageFormat = Platform.isIOS
          ? InputImageFormat.bgra8888
          : (InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21);

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: imageSize,
          rotation: imageRotation,
          format: inputImageFormat,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final faces = await _detectorService.processLiveFrame(inputImage);

      if (mounted) {
        setState(() {
          _detectedFace = faces.isNotEmpty ? faces.first : null;
        });
      }
    } catch (e) {
      debugPrint("Error processing live camera frame: $e");
    } finally {
      _isProcessingFrame = false;
    }
  }

  void _reset() {
    setState(() {
      _selectedHairStyle = null;
      _selectedBeardStyle = null;
      _userScale = 1.0;
      _userOffsetY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Live Camera Preview
                CameraPreview(_cameraController!),

                // Mirrored Live Overlay
                if (_detectedFace != null)
                  CustomPaint(
                    size: size,
                    painter: TryOnOverlayPainter(
                      face: _detectedFace,
                      imageSize: Size(
                        _cameraController!.value.previewSize!.height,
                        _cameraController!.value.previewSize!.width,
                      ),
                      hairStyle: _selectedHairStyle,
                      beardStyle: _selectedBeardStyle,
                      userScale: _userScale,
                      userOffsetY: _userOffsetY,
                      isMirrored: true,
                    ),
                  ),

                // Live Camera Feedback Badge
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _detectedFace != null ? AppColors.success : AppColors.warning,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _detectedFace != null ? 'Face Tracked' : 'Position Face in Frame',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Style Selector Controls
        TryOnControls(
          selectedHairStyle: _selectedHairStyle,
          selectedBeardStyle: _selectedBeardStyle,
          onSelectHairStyle: (style) => setState(() => _selectedHairStyle = style),
          onSelectBeardStyle: (style) => setState(() => _selectedBeardStyle = style),
          onReset: _reset,
          scale: _userScale,
          offsetY: _userOffsetY,
          onScaleChanged: (val) => setState(() => _userScale = val),
          onOffsetYChanged: (val) => setState(() => _userOffsetY = val),
        ),
      ],
    );
  }
}
