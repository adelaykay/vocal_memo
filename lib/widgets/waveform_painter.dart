// lib/widgets/waveform_painter.dart
import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final List<double> samples;
  final Color color;
  final double height;

  WaveformPainter({
    required this.samples,
    required this.color,
    this.height = 100,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final pixelWidth = size.width / samples.length;

    for (int i = 0; i < samples.length - 1; i++) {
      final x1 = i * pixelWidth;
      final y1 = centerY - (samples[i] * centerY);
      final x2 = (i + 1) * pixelWidth;
      final y2 = centerY - (samples[i + 1] * centerY);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) => oldDelegate.samples != samples;
}