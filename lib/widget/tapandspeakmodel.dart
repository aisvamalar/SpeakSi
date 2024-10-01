import 'package:flutter/foundation.dart';

class TapAndSpeakModel extends ChangeNotifier {
  String recognizedText = '';

  void updateText(String text) {
    recognizedText = text;
    notifyListeners();
  }
}