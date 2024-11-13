// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/internal.dart';

/// @nodoc
class ZegoCallMessageListSheet extends StatefulWidget {
  const ZegoCallMessageListSheet({
    Key? key,
    this.avatarBuilder,
    this.itemBuilder,
    this.scrollController,
    this.rootNavigator = false,
  }) : super(key: key);

  final bool rootNavigator;
  final ZegoAvatarBuilder? avatarBuilder;
  final ZegoInRoomMessageItemBuilder? itemBuilder;
  final ScrollController? scrollController;

  @override
  State<ZegoCallMessageListSheet> createState() =>
      _ZegoCallMessageListSheetState();
}

class _ZegoCallMessageListSheetState extends State<ZegoCallMessageListSheet> {
  var focusNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    focusNotifier.addListener(onInputFocusChanged);
  }

  @override
  void dispose() {
    super.dispose();

    focusNotifier.removeListener(onInputFocusChanged);
  }

  @override
  Widget build(BuildContext context) {
    final viewHeight = MediaQuery.of(context).size.height * 0.85;
    final bottomBarHeight = 110.zH;
    final headerHeight = 98.zH;
    final lineHeight = 1.zR;

    return Stack(
      children: [
        header(height: headerHeight),
        Positioned(
          left: 0,
          right: 0,
          top: headerHeight,
          child: Container(height: 1.zR, color: Colors.white.withOpacity(0.15)),
        ),
        messageList(
          height: viewHeight -
              headerHeight -
              lineHeight -
              bottomBarHeight -
              lineHeight,
          top: headerHeight + lineHeight,
          lineHeight: lineHeight,
        ),
        bottomBar(height: bottomBarHeight),
      ],
    );
  }

  Widget bottomBar({required double height}) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: height,
      child: ZegoInRoomMessageInput(
        placeHolder: 'Send a message to everyone',
        autofocus: false,
        focusNotifier: focusNotifier,
      ),
    );
  }

  Widget messageList({
    required double height,
    required double top,
    required double lineHeight,
  }) {
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.zR),
            // height: height,
            child: ConstrainedBox(
              constraints: BoxConstraints.loose(Size(690.zW, height)),
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                backgroundColor: Colors.transparent,
                body: ZegoInRoomChatView(
                  avatarBuilder: widget.avatarBuilder,
                  itemBuilder: widget.itemBuilder,
                  scrollController: widget.scrollController,
                ),
              ),
            ),
          ),
          Container(height: lineHeight, color: Colors.white.withOpacity(0.15)),
        ],
      ),
    );
  }

  Widget header({required double height}) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
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
            'Chat',
            style: TextStyle(
              fontSize: 36.0.zR,
              color: const Color(0xffffffff),
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  void onInputFocusChanged() {
    if (focusNotifier.value) {
      Future.delayed(const Duration(milliseconds: 100), () {
        widget.scrollController
            ?.jumpTo(widget.scrollController?.position.maxScrollExtent ?? 0);
      });
    }
  }
}

void showMessageSheet(
  BuildContext context, {
  ZegoAvatarBuilder? avatarBuilder,
  ZegoInRoomMessageItemBuilder? itemBuilder,
  ScrollController? scrollController,
  bool rootNavigator = false,
  required ZegoCallPopUpManager popUpManager,
  required ValueNotifier<bool> visibleNotifier,
}) {
  visibleNotifier.value = true;

  final key = DateTime.now().millisecondsSinceEpoch;
  popUpManager.addAPopUpSheet(key);

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
            child: ZegoCallMessageListSheet(
              avatarBuilder: avatarBuilder,
              itemBuilder: itemBuilder,
              scrollController: scrollController,
              rootNavigator: rootNavigator,
            ),
          ),
        ),
      );
    },
  ).then((value) {
    visibleNotifier.value = false;
    popUpManager.removeAPopUpSheet(key);
  });
}
