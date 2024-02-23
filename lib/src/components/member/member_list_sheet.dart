// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/components/assets.dart';

/// @nodoc
class ZegoCallMemberListSheet extends StatefulWidget {
  const ZegoCallMemberListSheet({
    Key? key,
    this.showMicrophoneState = true,
    this.showCameraState = true,
    this.itemBuilder,
    this.avatarBuilder,
    this.rootNavigator = false,
  }) : super(key: key);

  final bool showMicrophoneState;
  final bool showCameraState;
  final ZegoMemberListItemBuilder? itemBuilder;
  final ZegoAvatarBuilder? avatarBuilder;
  final bool rootNavigator;

  @override
  State<ZegoCallMemberListSheet> createState() =>
      _ZegoCallMemberListSheetState();
}

/// @nodoc
class _ZegoCallMemberListSheetState extends State<ZegoCallMemberListSheet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          header(98.zH),
          Container(height: 1.zR, color: Colors.white.withOpacity(0.15)),
          SizedBox(
            height: constraints.maxHeight - 1.zR - 98.zH,
            child: ZegoMemberList(
              showCameraState: widget.showCameraState,
              showMicrophoneState: widget.showMicrophoneState,
              avatarBuilder: widget.avatarBuilder,
              itemBuilder: widget.itemBuilder,
            ),
          ),
        ],
      );
    });
  }

  Widget header(double height) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(
                context,
                rootNavigator: widget.rootNavigator,
              ).pop();
            },
            child: SizedBox(
              width: 70.zR,
              height: 70.zR,
              child: ZegoCallImage.asset(ZegoCallIconUrls.back),
            ),
          ),
          SizedBox(width: 10.zR),
          Text(
            'Member',
            style: TextStyle(
              fontSize: 36.0.zR,
              color: const Color(0xffffffff),
              decoration: TextDecoration.none,
            ),
          )
        ],
      ),
    );
  }
}

void showMemberListSheet(
  BuildContext context, {
  showMicrophoneState = true,
  showCameraState = true,
  ZegoMemberListItemBuilder? itemBuilder,
  ZegoAvatarBuilder? avatarBuilder,
  bool rootNavigator = false,
}) {
  showModalBottomSheet(
    barrierColor: ZegoUIKitDefaultTheme.viewBarrierColor,
    backgroundColor: ZegoUIKitDefaultTheme.viewBackgroundColor,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32.0),
        topRight: Radius.circular(32.0),
      ),
    ),
    isDismissible: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: 0.85,
        child: AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 50),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            child: ZegoCallMemberListSheet(
              showCameraState: showCameraState,
              showMicrophoneState: showMicrophoneState,
              itemBuilder: itemBuilder,
              avatarBuilder: avatarBuilder,
              rootNavigator: rootNavigator,
            ),
          ),
        ),
      );
    },
  );
}
