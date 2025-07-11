// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

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
      ZegoLoggerService.logInfo(
        'pop, ',
        tag: 'call',
        subTag: 'popup manager, Navigator',
      );
      Navigator.of(
        context,
        rootNavigator: rootNavigator,
      ).pop();
    }

    _popupSheetKeys.clear();
  }
}
