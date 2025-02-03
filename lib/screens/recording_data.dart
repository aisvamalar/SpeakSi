import 'package:intl/intl.dart';

class RecordingData {
  final String path;
  final String text;
  final DateTime timestamp;

  RecordingData({
    required this.path,
    required this.text,
    required this.timestamp,
  });

  String get formattedTimestamp {
    return DateFormat('MMM d, y HH:mm').format(timestamp);
  }

  String get duration {
    // This would be replaced with actual duration calculation
    return "0:00";
  }
}