import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color color;

  WaveformPainter({
    required this.waveformData,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    if (waveformData.isEmpty) return;

    final width = size.width;
    final height = size.height;
    final centerY = height / 2;
    final barWidth = width / 50;
    final spacing = (width - (barWidth * waveformData.length)) / (waveformData.length + 1);

    for (var i = 0; i < waveformData.length; i++) {
      final x = spacing + (barWidth + spacing) * i;
      final amplitude = waveformData[i] * height / 2;

      canvas.drawLine(
        Offset(x + barWidth / 2, centerY - amplitude),
        Offset(x + barWidth / 2, centerY + amplitude),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.waveformData != waveformData;
  }
}