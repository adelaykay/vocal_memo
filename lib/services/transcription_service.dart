// lib/services/transcription_service.dart
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class TranscriptionService {
  final _speechToText = SpeechToText();
  bool _isInitialized = false;
  String _currentTranscript = '';
  bool _isListening = false;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  String get currentTranscript => _currentTranscript;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      final initialized = await _speechToText.initialize(
        onError: (error) => print('Speech-to-text error: ${error.errorMsg}'),
        onStatus: (status) => print('Speech-to-text status: $status'),
      );
      _isInitialized = initialized;
      return initialized;
    } catch (e) {
      print('Error initializing speech-to-text: $e');
      return false;
    }
  }

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<String> transcribeFile(String audioFilePath) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // For on-device transcription, we'll use speech_to_text
      // This works best with live audio, so for file transcription,
      // we'll need to use the native platform channels

      // For now, returning placeholder - will be implemented via platform channels
      return _transcribeFileNative(audioFilePath);
    } catch (e) {
      print('Error transcribing file: $e');
      return '';
    }
  }

  Future<String> _transcribeFileNative(String audioFilePath) async {
    // Placeholder - will be called via platform channel
    // Implementation in Android/iOS native code
    return '';
  }

  Future<void> startLiveTranscription(
      Function(String) onTranscriptUpdate,
      Function(bool) onListeningChanged,
      ) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final permissionGranted = await requestMicrophonePermission();
      if (!permissionGranted) {
        throw Exception('Microphone permission denied');
      }

      _currentTranscript = '';

      await _speechToText.listen(
        onResult: (result) {
          _currentTranscript = result.recognizedWords;
          onTranscriptUpdate(_currentTranscript);
        },
        listenMode: ListenMode.dictation,
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        cancelOnError: true,
      );

      _isListening = true;
      onListeningChanged(true);
    } catch (e) {
      print('Error starting live transcription: $e');
      _isListening = false;
      onListeningChanged(false);
    }
  }

  Future<void> stopLiveTranscription(Function(bool) onListeningChanged) async {
    try {
      await _speechToText.stop();
      _isListening = false;
      onListeningChanged(false);
    } catch (e) {
      print('Error stopping live transcription: $e');
    }
  }

  void dispose() {
    _speechToText.cancel();
  }
}