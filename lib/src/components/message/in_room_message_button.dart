// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/components/message/in_room_message_list_sheet.dart';
import 'package:zego_uikit_prebuilt_call/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/internal.dart';

/// @nodoc
/// switch cameras
class ZegoCallInRoomMessageButton extends StatefulWidget {
  const ZegoCallInRoomMessageButton({
    Key? key,
    required this.popUpManager,
    required this.viewVisibleNotifier,
    this.afterClicked,
    this.icon,
    this.iconSize,
    this.buttonSize,
    this.avatarBuilder,
    this.itemBuilder,
    this.rootNavigator = false,
  }) : super(key: key);

  final ButtonIcon? icon;

  ///  You can do what you want after pressed.
  final VoidCallback? afterClicked;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;

  final bool rootNavigator;

  final ZegoAvatarBuilder? avatarBuilder;
  final ZegoInRoomMessageItemBuilder? itemBuilder;

  final ValueNotifier<bool> viewVisibleNotifier;

  final ZegoCallPopUpManager popUpManager;

  @override
  State<ZegoCallInRoomMessageButton> createState() =>
      _ZegoCallInRoomMessageButtonState();
}

/// @nodoc
class _ZegoCallInRoomMessageButtonState
    extends State<ZegoCallInRoomMessageButton> {
  /// keep scroll position
  var scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final containerSize = widget.buttonSize ?? Size(96.zR, 96.zR);
    final sizeBoxSize = widget.iconSize ?? Size(56.zR, 56.zR);

    return GestureDetector(
      onTap: () {
        showMessageSheet(
          context,
          avatarBuilder: widget.avatarBuilder,
          itemBuilder: widget.itemBuilder,
          visibleNotifier: widget.viewVisibleNotifier,
          scrollController: scrollController,
          rootNavigator: widget.rootNavigator,
          popUpManager: widget.popUpManager,
        );

        if (widget.afterClicked != null) {
          widget.afterClicked!();
        }
      },
      child: Container(
        width: containerSize.width,
        height: containerSize.height,
        decoration: BoxDecoration(
          color: widget.icon?.backgroundColor ??
              const Color(0xff2C2F3E).withOpacity(0.6),
          borderRadius: BorderRadius.all(
            Radius.circular(
                math.min(containerSize.width, containerSize.height) / 2),
          ),
        ),
        child: SizedBox.fromSize(
          size: sizeBoxSize,
          child: widget.icon?.icon ?? ZegoCallImage.asset(ZegoCallIconUrls.im),
        ),
      ),
    );
  }
}
