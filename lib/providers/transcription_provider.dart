// lib/providers/transcription_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/transcription_service.dart';
import '../models/recording.dart';
import 'recording_provider.dart';

// Transcription service provider
final transcriptionServiceProvider = Provider((ref) {
  final service = TranscriptionService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Initialize transcription
final initializeTranscriptionProvider = FutureProvider<bool>((ref) async {
  final transcriptionService = ref.watch(transcriptionServiceProvider);
  return await transcriptionService.initialize();
});

// Live transcription state
class LiveTranscriptionState {
  final String transcript;
  final bool isListening;

  LiveTranscriptionState({
    required this.transcript,
    required this.isListening,
  });

  LiveTranscriptionState copyWith({
    String? transcript,
    bool? isListening,
  }) =>
      LiveTranscriptionState(
        transcript: transcript ?? this.transcript,
        isListening: isListening ?? this.isListening,
      );
}

class LiveTranscriptionNotifier extends StateNotifier<LiveTranscriptionState> {
  final TranscriptionService _transcriptionService;

  LiveTranscriptionNotifier(this._transcriptionService)
      : super(LiveTranscriptionState(transcript: '', isListening: false));

  Future<void> startListening() async {
    await _transcriptionService.startLiveTranscription(
          (transcript) {
        state = state.copyWith(transcript: transcript);
      },
          (isListening) {
        state = state.copyWith(isListening: isListening);
      },
    );
  }

  Future<void> stopListening() async {
    await _transcriptionService.stopLiveTranscription((isListening) {
      state = state.copyWith(isListening: isListening);
    });
  }

  void reset() {
    state = LiveTranscriptionState(transcript: '', isListening: false);
  }
}

final liveTranscriptionProvider =
StateNotifierProvider<LiveTranscriptionNotifier, LiveTranscriptionState>(
      (ref) {
    final transcriptionService = ref.watch(transcriptionServiceProvider);
    return LiveTranscriptionNotifier(transcriptionService);
  },
);

// Async transcription for files
class FileTranscriptionNotifier extends StateNotifier<AsyncValue<String>> {
  final TranscriptionService _transcriptionService;
  final String _filePath;

  FileTranscriptionNotifier(this._transcriptionService, this._filePath)
      : super(const AsyncValue.loading()) {
    _transcribe();
  }

  Future<void> _transcribe() async {
    try {
      state = const AsyncValue.loading();
      final transcript = await _transcriptionService.transcribeFile(_filePath);
      state = AsyncValue.data(transcript!);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> retry() async {
    await _transcribe();
  }
}

// Family provider for file transcription
final fileTranscriptionProvider =
StateNotifierProvider.family<FileTranscriptionNotifier, AsyncValue<String>,
    String>((ref, filePath) {
  final transcriptionService = ref.watch(transcriptionServiceProvider);
  return FileTranscriptionNotifier(transcriptionService, filePath);
});

// Provider to transcribe and update recording
final transcribeAndUpdateRecordingProvider =
FutureProvider.family<void, Recording>((ref, recording) async {
  if (recording.transcript != null && recording.transcript!.isNotEmpty) {
    return; // Already transcribed
  }

  try {
    final transcriptionService = ref.watch(transcriptionServiceProvider);
    final recordingNotifier = ref.read(recordingProvider.notifier);

    // Mark as transcribing
    await recordingNotifier.updateRecording(
      recording.copyWith(isTranscribing: true),
    );

    // Transcribe
    final transcript =
    await transcriptionService.transcribeFile(recording.filePath);

    // Update recording with transcript
    await recordingNotifier.updateRecording(
      recording.copyWith(
        transcript: transcript,
        isTranscribing: false,
      ),
    );
  } catch (e) {
    print('Error transcribing: $e');
    // Mark transcription as failed but keep recording
    final recordingNotifier = ref.read(recordingProvider.notifier);
    await recordingNotifier.updateRecording(
      recording.copyWith(isTranscribing: false),
    );
  }
});