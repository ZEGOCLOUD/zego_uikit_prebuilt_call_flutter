// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/config.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/config.defines.dart';

Future<bool> permissionConfirmationDialog(
  BuildContext? context, {
  bool rootNavigator = true,
  required ZegoCallPermissionConfirmDialogConfig dialogConfig,
  required ZegoCallPermissionConfirmDialogInfo dialogInfo,
}) async {
  if (!(context?.mounted ?? false)) {
    ZegoLoggerService.logInfo(
      'context is not mounted, '
      'context:$context, ',
      tag: 'call-invitation',
      subTag: 'permission confirmation dialog',
    );

    return false;
  }

  var result = false;

  try {
    result = await showDialog(
          context: context!,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return CupertinoTheme(
              data: CupertinoThemeData(
                brightness:
                    dialogConfig.backgroundBrightness ?? Brightness.light,
              ),
              child: CupertinoAlertDialog(
                title: Text(
                  dialogInfo.title,
                  textAlign: TextAlign.center,
                  style: dialogConfig.titleStyle ??
                      const TextStyle(
                        fontSize: 18.0,
                        // fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                ),
                actions: [
                  CupertinoDialogAction(
                    child: Text(
                      dialogInfo.cancelButtonName,
                      style: dialogConfig.actionTextStyle ??
                          const TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                          ),
                    ),
                    onPressed: () {
                      //  pop this dialog
                      try {
                        Navigator.of(
                          context,
                          rootNavigator: rootNavigator,
                        ).pop(false);
                      } catch (e) {
                        ZegoLoggerService.logError(
                          'navigator exception:$e, ',
                          tag: 'call-invitation',
                          subTag: 'permission confirmation dialog',
                        );
                      }
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text(
                      dialogInfo.confirmButtonName,
                      style: dialogConfig.actionTextStyle ??
                          const TextStyle(fontSize: 18, color: Colors.blue),
                    ),
                    onPressed: () {
                      //  pop this dialog
                      try {
                        Navigator.of(
                          context,
                          rootNavigator: rootNavigator,
                        ).pop(true);
                      } catch (e) {
                        ZegoLoggerService.logError(
                          'navigator exception:$e, ',
                          tag: 'call-invitation',
                          subTag: 'permission confirmation dialog',
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ) ??
        false;
  } catch (e) {
    ZegoLoggerService.logError(
      'show dialog exception:$e, ',
      tag: 'call-invitation',
      subTag: 'permission confirmation dialog',
    );
  }

  return result;
}
