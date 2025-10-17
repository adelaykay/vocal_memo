// lib/services/audio_service.dart
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../models/recording.dart';
import '../models/recording_settings.dart';

class AudioService {
  final _audioRecorder = AudioRecorder();
  String? _currentRecordingPath;
  DateTime? _recordingStartTime;
  Duration? _recordingDuration;
  Duration _accumulatedDuration = Duration.zero;
  DateTime? _pauseStartTime;
  bool _isPaused = false;


  Future<bool> get isRecording => _audioRecorder.isRecording();

  Future<bool> requestMicrophonePermission() async {
    final hasPermission = await _audioRecorder.hasPermission();
    return hasPermission ?? false;
  }

  Future<Recording?> startRecording(RecordingSettings settings) async {
    try {
      final hasPermission = await requestMicrophonePermission();
      if (!hasPermission) throw Exception('Microphone permission denied');

      final dir = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${dir.path}/recordings');
      if (!await recordingsDir.exists()) await recordingsDir.create(recursive: true);

      final fileName = '${const Uuid().v4()}.${settings.audioFormat}';
      _currentRecordingPath = '${recordingsDir.path}/$fileName';
      _recordingStartTime = DateTime.now();
      _accumulatedDuration = Duration.zero;
      _isPaused = false;

      await _audioRecorder.start(
        RecordConfig(
          encoder: _getEncoderFromFormat(settings.audioFormat),
          sampleRate: settings.sampleRate,
          bitRate: settings.bitRate,
          autoGain: settings.autoGainControl,
          noiseSuppress: settings.noiseSuppression,
          echoCancel: settings.echoCancellation,
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

  AudioEncoder _getEncoderFromFormat(String format) {
    switch (format) {
      case 'wav':
        return AudioEncoder.wav;
      case 'aac':
        return AudioEncoder.aacLc;
      default:
        return AudioEncoder.aacLc;
    }
  }


  Future<Recording?> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      if (path == null || _currentRecordingPath == null) {
        return null;
      }

      // Add the last active segment if not paused
      if (!_isPaused && _recordingStartTime != null) {
        _accumulatedDuration += DateTime.now().difference(_recordingStartTime!);
      }

      final file = File(path);

      final recording = Recording(
        id: const Uuid().v4(),
        fileName: file.path.split('/').last,
        filePath: file.path,
        createdAt: DateTime.now().subtract(_accumulatedDuration),
        duration: _accumulatedDuration,
      );

      _currentRecordingPath = null;
      _recordingStartTime = null;
      _pauseStartTime = null;
      _accumulatedDuration = Duration.zero;
      _isPaused = false;

      return recording;
    } catch (e) {
      print('Error stopping recording: $e');
      return null;
    }
  }


  Future<void> pauseRecording() async {
    try {
      await _audioRecorder.pause();

      // Add time from last start to now
      if (!_isPaused && _recordingStartTime != null) {
        _accumulatedDuration += DateTime.now().difference(_recordingStartTime!);
        _pauseStartTime = DateTime.now();
        _isPaused = true;
      }
    } catch (e) {
      print('Error pausing recording: $e');
    }
  }


  Future<void> resumeRecording() async {
    try {
      await _audioRecorder.resume();

      // Reset the segment timer
      _recordingStartTime = DateTime.now();
      _isPaused = false;
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