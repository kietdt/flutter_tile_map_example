import 'package:flutter/material.dart';

enum MapTypeEnum {
  google,
  mapBox;

  static List<MapTypeEnum> available = values;
}

class MyMapTypeNotifier extends ChangeNotifier {
  MapTypeEnum mapType = MapTypeEnum.google;

  void onMapTypeChanged(MapTypeEnum mapType) {
    if (this.mapType != mapType) {
      this.mapType = mapType;
      notifyListeners();
    }
  }
}
