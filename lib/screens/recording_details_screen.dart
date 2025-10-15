// lib/screens/recording_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../models/recording.dart';
import '../providers/recording_provider.dart';
import '../providers/playback_provider.dart';
import '../widgets/playback_controls.dart';
import '../widgets/speed_selector.dart';

class RecordingDetailsScreen extends ConsumerStatefulWidget {
  final Recording recording;

  const RecordingDetailsScreen({Key? key, required this.recording})
      : super(key: key);

  @override
  ConsumerState<RecordingDetailsScreen> createState() =>
      _RecordingDetailsScreenState();
}

class _RecordingDetailsScreenState
    extends ConsumerState<RecordingDetailsScreen> {
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recording.title);

    // Load audio in next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(playbackProvider.notifier).loadAndPlay(widget.recording.filePath);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    // Don't use ref here - it's unsafe when widget is unmounting
    // AudioPlayer will auto-stop when widget is disposed
    super.dispose();
  }

  void _updateTitle() {
    final newTitle = _titleController.text.trim();
    if (newTitle.isNotEmpty && newTitle != widget.recording.title) {
      ref.read(recordingProvider.notifier).updateRecording(
        widget.recording.copyWith(title: newTitle),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final playbackState = ref.watch(playbackProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            TextField(
              controller: _titleController,
              onSubmitted: (_) => _updateTitle(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Rename memo...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _updateTitle,
                ),
              ),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            // Playback Controls
            Container(
              decoration: BoxDecoration(
                color: AppTheme.teal.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (playbackState.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(color: AppTheme.teal),
                    )
                  else
                    const PlaybackControls(),
                  const SizedBox(height: 16),
                  const SpeedSelector(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Transcript
            Text(
              'Transcript',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            if (widget.recording.isTranscribing)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: AppTheme.teal),
                      const SizedBox(height: 12),
                      Text(
                        'Transcribing...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else if (widget.recording.transcript != null &&
                widget.recording.transcript!.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  widget.recording.transcript!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Text(
                  'No transcript available',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 24),

            // Organization
            Text(
              'Organization',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _OrgButton(
                  icon: widget.recording.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  label: 'Favorite',
                  isActive: widget.recording.isFavorite,
                  onPressed: () {
                    ref
                        .read(recordingProvider.notifier)
                        .toggleFavorite(widget.recording.id);
                  },
                ),
                _OrgButton(
                  icon: widget.recording.isPinned
                      ? Icons.push_pin
                      : Icons.push_pin_outlined,
                  label: 'Pin',
                  isActive: widget.recording.isPinned,
                  onPressed: () {
                    ref
                        .read(recordingProvider.notifier)
                        .togglePin(widget.recording.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Delete Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  ref
                      .read(recordingProvider.notifier)
                      .deleteRecording(widget.recording.id);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Delete Recording',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrgButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _OrgButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? AppTheme.teal : AppTheme.lightGray,
            foregroundColor: isActive ? Colors.white : AppTheme.darkText,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
        ),
      ),
    );
  }
}