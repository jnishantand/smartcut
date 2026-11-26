import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorService {
  FaceDetector? _detector;
  FaceDetectorMode? _currentMode;

  FaceDetector _getDetector(FaceDetectorMode mode) {
    if (_detector == null || _currentMode != mode) {
      _detector?.close();
      _currentMode = mode;
      _detector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: mode,
          enableLandmarks: true,
          enableContours: true,
          enableClassification: false,
        ),
      );
    }
    return _detector!;
  }

  Future<List<Face>> processPhoto(InputImage inputImage) async {
    try {
      final detector = _getDetector(FaceDetectorMode.accurate);
      return await detector.processImage(inputImage);
    } catch (e) {
      debugPrint("Error processing photo for face detection: $e");
      return [];
    }
  }

  Future<List<Face>> processLiveFrame(InputImage inputImage) async {
    try {
      final detector = _getDetector(FaceDetectorMode.fast);
      return await detector.processImage(inputImage);
    } catch (e) {
      debugPrint("Error processing live frame for face detection: $e");
      return [];
    }
  }

  void dispose() {
    _detector?.close();
    _detector = null;
    _currentMode = null;
  }
}
