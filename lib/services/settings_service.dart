import 'package:hive_flutter/hive_flutter.dart';
import '../models/recording_settings.dart';

class SettingsService {
  static const String boxName = 'recording_settings_box';
  static late Box<RecordingSettings> _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(RecordingSettingsAdapter());

    _settingsBox = await Hive.openBox<RecordingSettings>(boxName);

    // Ensure defaults exist
    if (_settingsBox.isEmpty) {
      await _settingsBox.put('settings', RecordingSettings());
    }
  }

  RecordingSettings getSettings() {
    final box = Hive.box<RecordingSettings>(boxName);
    return box.get('settings', defaultValue: RecordingSettings())!;
  }

  Future<void> updateSettings(RecordingSettings newSettings) async {
    final box = Hive.box<RecordingSettings>(boxName);
    await box.put('settings', newSettings);
  }

  Future<void> resetSettings() async {
    final box = Hive.box<RecordingSettings>(boxName);
    await box.put('settings', RecordingSettings());
  }

}
