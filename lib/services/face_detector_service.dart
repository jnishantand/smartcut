import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorService {
  late FaceDetector _photoFaceDetector;
  late FaceDetector _liveFaceDetector;

  FaceDetectorService() {
    _photoFaceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: true,
        enableContours: true,
        enableClassification: false,
      ),
    );

    _liveFaceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableLandmarks: true,
        enableContours: true,
        enableClassification: false,
      ),
    );
  }

  Future<List<Face>> processPhoto(InputImage inputImage) async {
    try {
      return await _photoFaceDetector.processImage(inputImage);
    } catch (e) {
      debugPrint("Error processing photo for face detection: $e");
      return [];
    }
  }

  Future<List<Face>> processLiveFrame(InputImage inputImage) async {
    try {
      return await _liveFaceDetector.processImage(inputImage);
    } catch (e) {
      debugPrint("Error processing live frame for face detection: $e");
      return [];
    }
  }

  void dispose() {
    _photoFaceDetector.close();
    _liveFaceDetector.close();
  }
}
