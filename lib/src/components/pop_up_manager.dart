// Flutter imports:
import 'package:flutter/cupertino.dart';

/// @nodoc
class ZegoCallPopUpManager {
  final List<int> _popupSheetKeys = [];

  void addAPopUpSheet(int key) {
    _popupSheetKeys.add(key);
  }

  void removeAPopUpSheet(int key) {
    _popupSheetKeys.remove(key);
  }

  void autoPop(BuildContext context, bool rootNavigator) {
    for (final _ in _popupSheetKeys) {
      Navigator.of(
        context,
        rootNavigator: rootNavigator,
      ).pop();
    }

    _popupSheetKeys.clear();
  }
}
