// lib/services/audio_service.dart
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../models/recording.dart';

class AudioService {
  final _audioRecorder = AudioRecorder();
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;
  Duration? _recordingDuration;

  Future<bool> get isRecording => _audioRecorder.isRecording();

  Future<bool> requestMicrophonePermission() async {
    final hasPermission = await _audioRecorder.hasPermission();
    return hasPermission ?? false;
  }

  Future<Recording?> startRecording() async {
    try {
      // Request permission if needed
      final hasPermission = await requestMicrophonePermission();
      if (!hasPermission) {
        throw Exception('Microphone permission denied');
      }

      final dir = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${dir.path}/recordings');

      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      final fileName = '${const Uuid().v4()}.m4a';
      _currentRecordingPath = '${recordingsDir.path}/$fileName';
      _recordingStartTime = DateTime.now();

      await _audioRecorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 16000,
          bitRate: 128000,
          numChannels: 1,
        ),
        path: _currentRecordingPath!,
      );

      return null;
    } catch (e) {
      print('Error starting recording: $e');
      return null;
    }
  }

  Future<Recording?> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      if (path == null || _currentRecordingPath == null || _recordingStartTime == null) {
        return null;
      }

      final file = File(path);
      _recordingDuration = DateTime.now().difference(_recordingStartTime!);

      final recording = Recording(
        id: const Uuid().v4(),
        fileName: file.path.split('/').last,
        filePath: file.path,
        createdAt: _recordingStartTime!,
        duration: _recordingDuration!,
      );

      _currentRecordingPath = null;
      _recordingStartTime = null;
      _recordingDuration = null;

      return recording;
    } catch (e) {
      print('Error stopping recording: $e');
      return null;
    }
  }

  Future<void> pauseRecording() async {
    try {
      await _audioRecorder.pause();
    } catch (e) {
      print('Error pausing recording: $e');
    }
  }

  Future<void> resumeRecording() async {
    try {
      await _audioRecorder.resume();
    } catch (e) {
      print('Error resuming recording: $e');
    }
  }

  Future<void> deleteRecording(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting recording: $e');
    }
  }

  void dispose() {
    _audioRecorder.dispose();
  }
}
