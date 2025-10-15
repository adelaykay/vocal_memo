// lib/widgets/playback_controls.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/playback_provider.dart';

class PlaybackControls extends ConsumerWidget {
  const PlaybackControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(playbackProvider);
    final formattedPosition = ref.watch(formattedPositionProvider);
    final formattedDuration = ref.watch(formattedDurationProvider);

    return Column(
      children: [
        // Progress slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 12,
                  ),
                ),
                child: Slider(
                  value: playbackState.progress.clamp(0.0, 1.0),
                  onChanged: (value) {
                    final newPosition = Duration(
                      milliseconds: (value *
                          playbackState.duration.inMilliseconds)
                          .toInt(),
                    );
                    ref.read(playbackProvider.notifier).seek(newPosition);
                  },
                  activeColor: AppTheme.teal,
                  inactiveColor: AppTheme.mediumGray,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedPosition,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.darkText,
                      ),
                    ),
                    Text(
                      formattedDuration,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.darkText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Control buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded),
                color: AppTheme.teal,
                onPressed: () =>
                    ref.read(playbackProvider.notifier).skipBackward(),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppTheme.orange,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    playbackState.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: () =>
                      ref.read(playbackProvider.notifier).togglePlayPause(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded),
                color: AppTheme.teal,
                onPressed: () =>
                    ref.read(playbackProvider.notifier).skipForward(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}