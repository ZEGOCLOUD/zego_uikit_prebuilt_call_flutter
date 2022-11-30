// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

class ZegoAudioVideoForeground extends StatelessWidget {
  final Size size;
  final ZegoUIKitUser? user;

  final bool showMicrophoneStateOnView;
  final bool showCameraStateOnView;
  final bool showUserNameOnView;

  const ZegoAudioVideoForeground({
    Key? key,
    this.user,
    required this.size,
    this.showMicrophoneStateOnView = true,
    this.showCameraStateOnView = true,
    this.showUserNameOnView = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Container(color: Colors.transparent);
    }
    return LayoutBuilder(builder: ((context, constraints) {
      return Container(
        padding: const EdgeInsets.all(5),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    userName(
                      context,
                      constraints.maxWidth * 0.8,
                    ),
                    microphoneStateIcon(),
                    cameraStateIcon(),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    }));
  }

  Widget userName(BuildContext context, double maxWidth) {
    return showUserNameOnView
        ? ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
            ),
            child: Text(
              user?.name ?? "",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 24.0.r,
                color: const Color(0xffffffff),
                decoration: TextDecoration.none,
              ),
            ),
          )
        : const SizedBox();
  }

  Widget microphoneStateIcon() {
    if (!showMicrophoneStateOnView) {
      return const SizedBox();
    }

    return ZegoMicrophoneStateIcon(targetUser: user);
  }

  Widget cameraStateIcon() {
    if (!showCameraStateOnView) {
      return const SizedBox();
    }

    return ZegoCameraStateIcon(targetUser: user);
  }
}
