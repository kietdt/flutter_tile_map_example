import 'package:flutter/material.dart';

class MyGoogleMapNotifier extends ChangeNotifier {
  String url = "";

  void onUrlChange(String url) {
    if (url != this.url) {
      this.url = url;
      notifyListeners();
    }
  }
}