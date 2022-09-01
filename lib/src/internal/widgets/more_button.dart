// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/internal/internal.dart';

/// more button of menu bar
class ZegoMoreButton extends StatefulWidget {
  const ZegoMoreButton({
    Key? key,
    required this.menuButtonList,
    this.icon,
    this.menuItemSize = const Size(60.0, 60.0),
    this.menuItemCountPerRow = 5,
    this.menuRowHeight = 80.0,
    this.menuBackgroundColor = const Color(0xff262A2D),
    this.iconSize,
    this.buttonSize,
  }) : super(key: key);

  final ButtonIcon? icon;

  /// bottom list of menu
  final List<Widget> menuButtonList;

  /// the number of buttons per row
  final int menuItemCountPerRow;

  final double menuRowHeight;
  final Size menuItemSize;
  final Color menuBackgroundColor;

  /// the size of button's icon
  final Size? iconSize;

  /// the size of button
  final Size? buttonSize;

  @override
  State<ZegoMoreButton> createState() => _ZegoMoreButtonState();
}

class _ZegoMoreButtonState extends State<ZegoMoreButton> {
  @override
  Widget build(BuildContext context) {
    Size containerSize = widget.buttonSize ?? Size(96.r, 96.r);
    Size sizeBoxSize = widget.iconSize ?? Size(56.r, 56.r);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 96.r,
        height: 96.r,
        decoration: BoxDecoration(
          color: widget.icon?.backgroundColor ??
              controlBarButtonCheckedBackgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(
              math.min(containerSize.width, containerSize.height) / 2)),
        ),
        child: SizedBox.fromSize(
          size: sizeBoxSize,
          child: widget.icon?.icon ??
              PrebuiltCallImage.asset(
                  PrebuiltCallIconUrls.iconS1ControlBarMore),
        ),
      ),
    );
  }

  void onPressed() {
    showModalBottomSheet(
      backgroundColor: widget.menuBackgroundColor,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.0),
          topRight: Radius.circular(32.0),
        ),
      ),
      isDismissible: true,
      builder: (BuildContext context) {
        int rowCount =
            1 + widget.menuButtonList.length ~/ widget.menuItemCountPerRow;
        if (rowCount > 2) {
          /// at most two rows are displayed
          rowCount = 2;
        }
        return AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 50),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            height: rowCount * widget.menuRowHeight,
            child: menu(
              context,
              // List.from is for copy list，otherwise will lose items in next build
              splitButtonFromListsToRows(List.from(widget.menuButtonList)),
            ),
          ),
        );
      },
    );
  }

  ///
  Widget menu(BuildContext context, List<List<Widget>> rowButtonList) {
    if (rowButtonList.length > 1) {
      /// in order to align each row of buttons,
      /// if the last row of buttons is not filled,
      /// add some hidden buttons to fill the row
      if (rowButtonList.first.length != rowButtonList.last.length) {
        var lastShortList = rowButtonList.last;
        rowButtonList.removeLast();

        var copyWidget = rowButtonList.first.first;
        var diffCount = rowButtonList.first.length - lastShortList.length;
        for (var i = 0; i < diffCount; i++) {
          /// fill the vacant position
          lastShortList.add(Stack(
            fit: StackFit.passthrough,
            children: [
              copyWidget,
              Container(
                width: widget.menuItemSize.width,
                height: widget.menuItemSize.height,
                color: widget.menuBackgroundColor,
              ),
            ],
          ));
        }
        rowButtonList.add(lastShortList);
      }
    }

    /// scrollable
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ...rowButtonList
                .map((List<Widget> columnButtonList) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: columnButtonList
                          .map((Widget child) => SizedBox(
                                width: widget.menuItemSize.width,
                                height: widget.menuItemSize.height,
                                child: child,
                              ))
                          .toList(),
                    ))
                .toList()
          ],
        ));
  }

  /// split all buttons into multiple lines
  List<List<Widget>> splitButtonFromListsToRows(List<Widget> buttonList) {
    List<List<Widget>> listOfList = [];
    while (buttonList.length >= widget.menuItemCountPerRow) {
      listOfList.add(buttonList.sublist(0, widget.menuItemCountPerRow));
      buttonList.removeRange(0, widget.menuItemCountPerRow);
    }
    if (buttonList.isNotEmpty) {
      listOfList.add(buttonList);
    }
    return listOfList;
  }
}
