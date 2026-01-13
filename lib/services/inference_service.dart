import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/sensor_data.dart';
import '../models/inference_result.dart';

/// Service for managing TFLite model inference
class InferenceService {
  static const String modelPath = 'assets/models/fall_multitask_model.tflite';
  static const int windowSize = 200;
  static const int numChannels = 9;
  static const int numActivities = 13;

  Interpreter? _interpreter;
  bool _isLoaded = false;

  /// Whether the model is loaded and ready
  bool get isLoaded => _isLoaded;

  /// Model configuration
  int get requiredWindowSize => windowSize;
  int get channelCount => numChannels;

  /// Load the TFLite model
  Future<void> loadModel() async {
    if (_isLoaded) return;

    debugPrint("🧠 [INFERENCE_SERVICE] Loading model from $modelPath...");
    try {
      _interpreter = await Interpreter.fromAsset(modelPath);
      _isLoaded = true;
      debugPrint("✅ [INFERENCE_SERVICE] Model loaded successfully!");
      debugPrint(
        "🧠 [INFERENCE_SERVICE] Input: ${_interpreter!.getInputTensors()}",
      );
      debugPrint(
        "🧠 [INFERENCE_SERVICE] Output: ${_interpreter!.getOutputTensors()}",
      );
    } catch (e) {
      debugPrint("❌ [INFERENCE_SERVICE] Failed to load model: $e");
      rethrow;
    }
  }

  /// Run inference on a buffer of sensor data
  InferenceResult? runInference(List<SensorData> buffer) {
    if (!_isLoaded || _interpreter == null) {
      debugPrint("⚠️ [INFERENCE_SERVICE] Model not loaded");
      return null;
    }

    if (buffer.length != windowSize) {
      debugPrint(
        "⚠️ [INFERENCE_SERVICE] Invalid buffer size: ${buffer.length}, expected: $windowSize",
      );
      return null;
    }

    final stopwatch = Stopwatch()..start();

    // Prepare input: [1, windowSize, numChannels]
    final input = [List.generate(windowSize, (i) => buffer[i].toModelInput())];

    // Prepare outputs
    final eventOutput = List.generate(1, (_) => List.filled(1, 0.0));
    final activityOutput = List.generate(
      1,
      (_) => List.filled(numActivities, 0.0),
    );

    try {
      _interpreter!.runForMultipleInputs(
        [input],
        {
          0: activityOutput, // activity output first
          1: eventOutput, // event (fall) output second
        },
      );

      stopwatch.stop();

      final fallProb = eventOutput[0][0];
      final activityProbs = activityOutput[0];
      final activityClass = activityProbs.indexOf(activityProbs.reduce(max));

      final result = InferenceResult(
        fallProbability: fallProb,
        activityClass: activityClass,
        activityProbabilities: List.from(activityProbs),
        inferenceTimeMs: stopwatch.elapsedMilliseconds,
        timestamp: DateTime.now(),
      );

      // Debug: show all activity probabilities
      debugPrint(
        "🔮 [INFERENCE] Fall prob: ${fallProb.toStringAsFixed(3)}, Activity: $activityClass (${result.activityName})",
      );
      debugPrint(
        "📊 [INFERENCE] All probs: ${activityProbs.map((p) => p.toStringAsFixed(2)).toList()}",
      );

      if (result.isFallDetected) {
        debugPrint("🚨🚨🚨 [INFERENCE_SERVICE] FALL DETECTED! 🚨🚨🚨");
      }

      return result;
    } catch (e) {
      debugPrint("❌ [INFERENCE_SERVICE] Inference error: $e");
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
    debugPrint("🗑️ [INFERENCE_SERVICE] Disposed");
  }
}
