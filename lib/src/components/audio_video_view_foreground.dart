// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

/// @nodoc
class ZegoCallAudioVideoForeground extends StatelessWidget {
  final Size size;
  final ZegoUIKitUser? user;

  final bool showMicrophoneStateOnView;
  final bool showCameraStateOnView;
  final bool showUserNameOnView;

  const ZegoCallAudioVideoForeground({
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

    return LayoutBuilder(builder: (context, constraints) {
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
                      constraints.maxWidth * 0.4,
                    ),
                    microphoneStateIcon(),
                    cameraStateIcon(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget userName(BuildContext context, double maxWidth) {
    return showUserNameOnView
        ? ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
            ),
            child: Text(
              user?.name ?? '',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 24.0.zR,
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

/// @nodoc
class ZegoWaitingCallAcceptAudioVideoForeground extends StatelessWidget {
  final Size size;
  final ZegoUIKitUser? user;
  final String invitationID;
  final String? cancelData;

  const ZegoWaitingCallAcceptAudioVideoForeground({
    Key? key,
    this.cancelData,
    this.user,
    required this.invitationID,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        padding: const EdgeInsets.all(5),
        child: Stack(
          children: [
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                backgroundColor: Colors.grey,
                color: Colors.grey,
              ),
            ),
            Positioned(
              bottom: 100.zR,
              left: 0,
              right: 0,
              child: Center(
                child: ZegoTextIconButton(
                  text: 'Cancel',
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 15.zR,
                  ),
                  iconTextSpacing: 5.zR,
                  buttonSize: Size(120.zR, 120.zR),
                  iconSize: Size(60.zR, 60.zR),
                  icon: ButtonIcon(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    await ZegoUIKit()
                        .getSignalingPlugin()
                        .cancelAdvanceInvitation(
                      invitees: [user?.id ?? ''],
                      data: cancelData ?? '',
                      invitationID: invitationID,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
