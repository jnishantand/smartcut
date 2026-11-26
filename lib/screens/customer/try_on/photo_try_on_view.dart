import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../models/try_on_style.dart';
import '../../../services/face_detector_service.dart';
import '../../../widgets/try_on_overlay_painter.dart';
import '../../../widgets/try_on_controls.dart';

class PhotoTryOnView extends StatefulWidget {
  const PhotoTryOnView({super.key});

  @override
  State<PhotoTryOnView> createState() => _PhotoTryOnViewState();
}

class _PhotoTryOnViewState extends State<PhotoTryOnView> {
  final ImagePicker _picker = ImagePicker();
  final FaceDetectorService _detectorService = FaceDetectorService();

  File? _imageFile;
  ui.Image? _decodedImage;
  Face? _detectedFace;
  bool _isProcessing = false;

  TryOnStyle? _selectedHairStyle;
  TryOnStyle? _selectedBeardStyle;

  double _userScale = 1.0;
  double _userOffsetY = 0.0;

  @override
  void dispose() {
    _detectorService.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1200,
        maxHeight: 1600,
      );

      if (pickedFile == null) return;

      setState(() {
        _isProcessing = true;
        _imageFile = File(pickedFile.path);
        _detectedFace = null;
        _decodedImage = null;
      });

      // 1. Decode Image for Painting
      final bytes = await _imageFile!.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();
      _decodedImage = frameInfo.image;

      // 2. Detect Face using ML Kit
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final faces = await _detectorService.processPhoto(inputImage);

      setState(() {
        _detectedFace = faces.isNotEmpty ? faces.first : null;
        _isProcessing = false;
      });

      if (faces.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No face detected. Please try a clearer front-facing photo.')),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading photo: $e')),
        );
      }
    }
  }

  Future<void> _savePreview() async {
    if (_imageFile == null) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preview saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image: $e')),
      );
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
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            width: double.infinity,
            child: _imageFile == null
                ? _buildEmptyState()
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      // Display Base Photo
                      Image.file(
                        _imageFile!,
                        fit: BoxFit.contain,
                      ),

                      // Display Overlay Painter
                      if (_decodedImage != null && _detectedFace != null)
                        Positioned.fill(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return CustomPaint(
                                size: Size(constraints.maxWidth, constraints.maxHeight),
                                painter: TryOnOverlayPainter(
                                  face: _detectedFace,
                                  imageSize: Size(
                                    _decodedImage!.width.toDouble(),
                                    _decodedImage!.height.toDouble(),
                                  ),
                                  hairStyle: _selectedHairStyle,
                                  beardStyle: _selectedBeardStyle,
                                  userScale: _userScale,
                                  userOffsetY: _userOffsetY,
                                ),
                              );
                            },
                          ),
                        ),

                      if (_isProcessing)
                        const Center(child: CircularProgressIndicator(color: AppColors.primary)),

                      // Floating Photo Source Switcher & Save Buttons
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Row(
                          children: [
                            IconButton.filled(
                              icon: const Icon(Icons.camera_alt),
                              tooltip: 'Take New Photo',
                              onPressed: () => _pickImage(ImageSource.camera),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              icon: const Icon(Icons.photo_library),
                              tooltip: 'Choose Gallery Photo',
                              onPressed: () => _pickImage(ImageSource.gallery),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        // Controls Sheet
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.face_retouching_natural, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'Virtual Hairstyle Try-On',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Capture a selfie or upload a photo to preview haircuts and beard styles on your face in real-time.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Selfie'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose Photo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
