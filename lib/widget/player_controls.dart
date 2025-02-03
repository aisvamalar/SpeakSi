import 'package:flutter/material.dart';

class PlayerControls extends StatelessWidget {
  final bool isPlaying;
  final Duration currentPosition;
  final Duration totalDuration;
  final VoidCallback onPlayPause;
  final Function(Duration) onSeek;

  const PlayerControls({
    Key? key,
    required this.isPlaying,
    required this.currentPosition,
    required this.totalDuration,
    required this.onPlayPause,
    required this.onSeek,
  }) : super(key: key);

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(currentPosition),
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  size: 48,
                  color: Colors.purple,
                ),
                onPressed: onPlayPause,
              ),
              Text(
                _formatDuration(totalDuration),
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Slider(
            value: currentPosition.inSeconds.toDouble(),
            min: 0,
            max: totalDuration.inSeconds.toDouble(),
            activeColor: Colors.purple,
            inactiveColor: Colors.purple.withOpacity(0.3),
            onChanged: (value) {
              onSeek(Duration(seconds: value.toInt()));
            },
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}