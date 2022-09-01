// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<bool> showAlertDialog(
  BuildContext context,
  String title,
  String content,
  List<Widget>? actions, {
  MainAxisAlignment? actionsAlignment,
}) async {
  return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30.0.w,
                fontWeight: FontWeight.bold,
                color: const Color(0xff2A2A2A),
              ),
            ),
            content: Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28.0.w,
                color: const Color(0xff2A2A2A),
              ),
            ),
            actions: actions,
            actionsAlignment: actionsAlignment,
          );
        },
      ) ??
      false;
}

Future<T?> showTopModalSheet<T>(BuildContext context, Widget widget,
    {bool barrierDismissible = true}) {
  return showGeneralDialog<T?>(
    context: context,
    barrierDismissible: barrierDismissible,
    transitionDuration: const Duration(milliseconds: 250),
    barrierLabel: MaterialLocalizations.of(context).dialogLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    pageBuilder: (context, _, __) => ScreenUtilInit(
      designSize: const Size(750, 1334),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return SafeArea(
            child: Column(
          children: [
            SizedBox(height: 16.h),
            widget,
          ],
        ));
      },
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        child: child,
        position: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)
            .drive(
                Tween<Offset>(begin: const Offset(0, -1.0), end: Offset.zero)),
      );
    },
  );
}
