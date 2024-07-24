import 'package:flutter/cupertino.dart';

import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/src/controller.dart';

/// When minimizing, it is not allowed to directly return to the previous page, otherwise the page will be destroyed
class ZegoUIKitPrebuiltCallMiniPopScope extends StatefulWidget {
  const ZegoUIKitPrebuiltCallMiniPopScope({
    Key? key,
    required this.child,
    this.canPop = false,
    this.onPopInvoked,
  }) : super(key: key);

  /// The widget below this widget in the tree.
  final Widget child;

  /// When in the minimizing state, is it allowed back to the desktop or not.
  /// If true, it will back to the desktop; if false, nothing will happen.
  final bool canPop;

  /// If you don't want to back to the desktop directly, you can customize the pop logic
  final void Function(bool isMinimizing)? onPopInvoked;

  @override
  ZegoUIKitPrebuiltCallMiniPopScopeState createState() =>
      ZegoUIKitPrebuiltCallMiniPopScopeState();
}

/// @nodoc
class ZegoUIKitPrebuiltCallMiniPopScopeState
    extends State<ZegoUIKitPrebuiltCallMiniPopScope> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable:
          ZegoUIKitPrebuiltCallController().minimize.isMinimizingNotifier,
      builder: (context, isMinimizing, _) {
        return PopScope(
          /// Don't pop current widget directly when in minimizing
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) {
              return;
            }

            if (isMinimizing) {
              if (widget.canPop) {
                onPopInvoked(isMinimizing);
              }

              /// not pop if in minimizing
              return;
            } else {
              onPopInvoked(isMinimizing);
            }
          },
          child: widget.child,
        );
      },
    );
  }

  void onPopInvoked(bool isMinimizing) {
    if (null == widget.onPopInvoked) {
      ZegoUIKit().backToDesktop();
    } else {
      widget.onPopInvoked?.call(isMinimizing);
    }
  }
}
