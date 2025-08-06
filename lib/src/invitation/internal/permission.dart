// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/config.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/config.defines.dart';

Future<bool> showSystemConfirmationDialog(
  BuildContext? context, {
  bool rootNavigator = true,
  required ZegoCallSystemConfirmDialogConfig dialogConfig,
  required ZegoCallSystemConfirmDialogInfo dialogInfo,
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
            return ZegoScreenUtilInit(
              designSize: const Size(750, 1334),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, child) {
                return CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness:
                        dialogConfig.backgroundBrightness ?? Brightness.light,
                    primaryColor: CupertinoColors.systemBlue,
                  ),
                  child: CupertinoAlertDialog(
                    title: Text(
                      dialogInfo.title,
                      textAlign: TextAlign.center,
                      style: dialogConfig.titleStyle ??
                          TextStyle(
                            fontSize: 25.zR,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.label,
                          ),
                    ),
                    content: Padding(
                      padding: EdgeInsets.only(top: 8.zR),
                      child: Text(
                        dialogInfo.message,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 25.zR,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ),
                    actions: [
                      CupertinoDialogAction(
                        isDestructiveAction: false,
                        child: Text(
                          dialogInfo.cancelButtonName,
                          style: dialogConfig.actionTextStyle ??
                              TextStyle(
                                fontSize: 25.zR,
                                fontWeight: FontWeight.w400,
                                color: CupertinoColors.systemBlue,
                              ),
                        ),
                        onPressed: () {
                          ZegoLoggerService.logInfo(
                            'pop from cancel, ',
                            tag: 'call',
                            subTag: 'permission confirmation dialog, Navigator',
                          );
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
                        isDefaultAction: true,
                        child: Text(
                          dialogInfo.confirmButtonName,
                          style: dialogConfig.actionTextStyle ??
                              TextStyle(
                                fontSize: 25.zR,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.systemBlue,
                              ),
                        ),
                        onPressed: () {
                          ZegoLoggerService.logInfo(
                            'pop from confrim, ',
                            tag: 'call',
                            subTag: 'permission confirmation dialog, Navigator',
                          );
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
