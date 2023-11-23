// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AppLifecycleState parseStateFromString(String state) {
  var values = <String, AppLifecycleState>{};
  for (var appLifecycleState in AppLifecycleState.values) {
    values[appLifecycleState.toString()] = appLifecycleState;
  }

  return values[state] ?? AppLifecycleState.resumed;
}
