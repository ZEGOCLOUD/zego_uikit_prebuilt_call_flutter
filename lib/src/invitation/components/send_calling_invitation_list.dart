// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/inner_text.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/internal_instance.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/pages/page_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/service.dart';

/// Display a call invitation list pop-up.
///
/// Assign members to be invited to [waitingSelectUsers], and assign members who are already
/// invited or in a call to [selectedUsers].
///
/// If you need to default select members to be invited, you can set [defaultChecked] to true.
/// If sorting is needed, you can set [userSort].
/// In the [onPressed] callback, send a call invitation.
void showCallingInvitationListSheet(
  BuildContext context, {
  /// Members waiting to be selected (not in a call, not invited)
  required List<ZegoCallUser> waitingSelectUsers,

  /// Callback after clicking the invite button, initiate invitation here (invite not in call, or invite in call)
  required void Function(List<ZegoCallUser> selectedUsers) onPressed,

  /// Whether to default select waiting members
  bool defaultChecked = true,

  /// Selected members (in a call or invited)
  List<ZegoCallUser> selectedUsers = const [],

  /// Member list sorting
  List<ZegoCallUser> Function(List<ZegoCallUser>)? userSort,
  bool rootNavigator = false,
  ButtonIcon? buttonIcon,
  Size? buttonIconSize,
  Size? buttonSize,
  ZegoAvatarBuilder? avatarBuilder,
  Color? userNameColor,
  Color? backgroundColor,

  /// default is 'Invitees'
  String? popUpTitle,
  TextStyle? popUpTitleStyle,
  Widget? popUpBackIcon,

  /// default is 'Invite'
  Widget? inviteButtonIcon,
}) {
  showModalBottomSheet(
    context: context,
    barrierColor: ZegoUIKitDefaultTheme.viewBarrierColor,
    backgroundColor: backgroundColor ??
        ZegoUIKitDefaultTheme.viewBackgroundColor.withValues(alpha: 0.6),
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
        heightFactor: 0.75,
        child: AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 50),
          child: SafeArea(
            child: ZegoSendCallingInvitationList(
              waitingSelectUsers: waitingSelectUsers,
              selectedUsers: selectedUsers,
              userSort: userSort,
              onPressed: onPressed,
              buttonIcon: buttonIcon,
              popUpTitle: popUpTitle,
              popUpTitleStyle: popUpTitleStyle,
              buttonIconSize: buttonIconSize,
              buttonSize: buttonSize,
              avatarBuilder: avatarBuilder,
              userNameColor: userNameColor,
              popUpBackIcon: popUpBackIcon,
              inviteButtonIcon: inviteButtonIcon,
              defaultChecked: defaultChecked,
            ),
          ),
        ),
      );
    },
  );
}

class ZegoSendCallingInvitationList extends StatefulWidget {
  const ZegoSendCallingInvitationList({
    Key? key,
    required this.waitingSelectUsers,
    required this.onPressed,
    this.selectedUsers = const [],
    this.userSort,
    this.buttonIcon,
    this.popUpTitle,
    this.popUpTitleStyle,
    this.buttonIconSize,
    this.buttonSize,
    this.avatarBuilder,
    this.userNameColor,
    this.popUpBackIcon,
    this.inviteButtonIcon,
    this.defaultChecked = true,
  }) : super(key: key);

  final void Function(List<ZegoCallUser> selectedUsers) onPressed;

  final List<ZegoCallUser> waitingSelectUsers;
  final List<ZegoCallUser> selectedUsers;
  final List<ZegoCallUser> Function(List<ZegoCallUser>)? userSort;
  final bool defaultChecked;

  final ButtonIcon? buttonIcon;

  final Size? buttonIconSize;
  final Size? buttonSize;
  final ZegoAvatarBuilder? avatarBuilder;
  final Color? userNameColor;

  /// default is 'Invitees'
  final String? popUpTitle;
  final TextStyle? popUpTitleStyle;
  final Widget? popUpBackIcon;

  /// default is 'Invite'
  final Widget? inviteButtonIcon;

  @override
  State<ZegoSendCallingInvitationList> createState() =>
      _ZegoSendCallingInvitationListState();
}

class _ZegoSendCallingInvitationListState
    extends State<ZegoSendCallingInvitationList> {
  final userSelectedStatusNotifier = ValueNotifier<Map<String, bool>>({});

  List<ZegoCallUser> waitingSelectUsers = [];
  List<ZegoCallUser> selectedUsers = [];

  ZegoCallInvitationPageManager? get pageManager =>
      ZegoCallInvitationInternalInstance.instance.pageManager;

  ZegoUIKitPrebuiltCallInvitationData? get callInvitationConfig =>
      ZegoCallInvitationInternalInstance.instance.callInvitationData;

  ZegoCallInvitationInnerText? get innerText => callInvitationConfig?.innerText;

  @override
  void initState() {
    super.initState();

    final localInvitingUserIDs = ZegoUIKitPrebuiltCallInvitationService()
        .private
        .localInvitingUsersNotifier
        .value
        .map((e) => e.id)
        .toList();
    List<ZegoCallUser> invitingWaitingSelectUsers = [];
    for (var waitingSelectUser in widget.waitingSelectUsers) {
      if (localInvitingUserIDs.contains(waitingSelectUser.id)) {
        invitingWaitingSelectUsers.add(waitingSelectUser);
      } else {
        waitingSelectUsers.add(waitingSelectUser);
      }
    }
    selectedUsers = [
      ...invitingWaitingSelectUsers,
      ...widget.selectedUsers,
    ];

    if (widget.defaultChecked) {
      userSelectedStatusNotifier.value = waitingSelectUsers.asMap().map(
            (key, user) => MapEntry(
              user.id,
              true,
            ),
          );
    } else {
      userSelectedStatusNotifier.value = {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZegoScreenUtilInit(
      designSize: const Size(750, 1334),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final padding = 16.0.zR;
        final titleHeight = 80.zH;
        final controlsHeight = 100.zH;
        final totalHeight = MediaQuery.of(context).size.height * 0.75;
        return Container(
          height: totalHeight,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0.zR),
              topRight: Radius.circular(16.0.zR),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                popUpTitle(height: titleHeight),
                userListView(
                    height: totalHeight -
                        titleHeight -
                        controlsHeight -
                        2 * padding -
                        2),
                controls(height: controlsHeight),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget popUpTitle({required double height}) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: IconButton(
              onPressed: () {
                ZegoLoggerService.logInfo(
                  'pop from title, ',
                  tag: 'call',
                  subTag: 'sending calling invation list, Navigator',
                );
                Navigator.of(context).pop();
              },
              iconSize: 20,
              icon: widget.popUpBackIcon ??
                  const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                widget.popUpTitle ?? 'Invitees',
                style: widget.popUpTitleStyle ??
                    const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget controls({required double height}) {
    return GestureDetector(
      onTap: () {
        ZegoLoggerService.logInfo(
          'pop from controls, ',
          tag: 'call',
          subTag: 'sending calling invation list, Navigator',
        );

        Navigator.of(context).pop();

        final inviteeSelectedUsers = userSelectedStatusNotifier.value;
        inviteeSelectedUsers.removeWhere((_, checked) => !checked);
        final selectedUserIds = inviteeSelectedUsers.keys.toList();
        final invitees = List.generate(selectedUserIds.length, (userIDIndex) {
          final userID = selectedUserIds[userIDIndex];
          final userIndex = waitingSelectUsers.indexWhere(
            (user) => user.id == userID,
          );
          return waitingSelectUsers[userIndex];
        });

        widget.onPressed.call(invitees);
      },
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.all(Radius.circular(8.0.zR)),
        ),
        child: const Center(
          child: Icon(Icons.call, color: Colors.white),
        ),
      ),
    );
  }

  Widget userListView({required double height}) {
    final allUsers = [
      ...waitingSelectUsers,
      ...selectedUsers,
    ];
    final checkedUserIDs = selectedUsers.map((e) => e.id).toList();

    var listUsers = <ZegoCallUser>[];
    if (null != widget.userSort) {
      listUsers = widget.userSort!.call(allUsers);
    } else {
      allUsers.sort(
        (l, r) => l.name.compareTo(r.name),
      );
      listUsers = allUsers;
    }

    return SizedBox(
      height: height,
      child: ListView.builder(
        itemCount: listUsers.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(0.0.zR),
                child: Row(
                  children: [
                    checkbox(
                      listUsers[index],
                      !checkedUserIDs.contains(listUsers[index].id),
                    ),
                    SizedBox(width: 16.0.zR),
                    avatar(
                      user: ZegoUIKitUser(
                        id: listUsers[index].id,
                        name: listUsers[index].name,
                      ),
                      avatarBuilder: widget.avatarBuilder,
                      size: Size(72.zR, 72.zR),
                    ),
                    SizedBox(width: 16.0.zR),
                    name(listUsers[index]),
                  ],
                ),
              ),
              Divider(
                color: Colors.white.withValues(alpha: 0.1),
                thickness: 1.0,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget name(ZegoCallUser user) {
    return Expanded(
      child: Text(
        user.name,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: widget.userNameColor ?? Colors.white,
        ),
      ),
    );
  }

  Widget checkbox(ZegoCallUser user, bool canChecked) {
    return ValueListenableBuilder<Map<String, bool>>(
      valueListenable: userSelectedStatusNotifier,
      builder: (context, selectedStatus, _) {
        return Checkbox(
          value: canChecked ? (selectedStatus[user.id] ?? false) : true,
          onChanged: canChecked
              ? (value) {
                  userSelectedStatusNotifier.value = {
                    ...userSelectedStatusNotifier.value,
                    user.id: value!,
                  };
                }

              /// disable
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0.zR),
          ),
          //MaterialStateProperty
          fillColor: WidgetStateProperty.all(
            (selectedStatus[user.id] ?? false)
                ? Colors.grey
                : Colors.transparent,
          ),
          side: BorderSide(
            color: (selectedStatus[user.id] ?? false)
                ? Colors.transparent
                : Colors.grey,
          ),
        );
      },
    );
  }

  Widget avatar({
    required ZegoUIKitUser user,
    Size? size,
    ZegoAvatarBuilder? avatarBuilder,
  }) {
    final targetSize = size ?? Size(72.zR, 72.zR);
    return ValueListenableBuilder(
      valueListenable: ZegoUIKitUserPropertiesNotifier(user),
      builder: (context, _, __) {
        return Container(
          width: targetSize.width,
          height: targetSize.height,
          decoration: BoxDecoration(
            color: const Color(0xffDBDDE3),
            borderRadius: BorderRadius.circular(8.zR),
            shape: BoxShape.rectangle,
          ),
          child: avatarBuilder?.call(context, targetSize, user, {}) ??
              circleName(context, targetSize, user),
        );
      },
    );
  }

  Widget circleName(BuildContext context, Size size, ZegoUIKitUser? user) {
    final userName = user?.name ?? '';
    return Center(
      child: Text(
        userName.isNotEmpty ? userName.characters.first : '',
        style: TextStyle(
          fontSize: 24.zR,
          fontWeight: FontWeight.w600,
          color: const Color(0xff222222),
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
