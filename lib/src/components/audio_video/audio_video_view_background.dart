// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_uikit/zego_uikit.dart';

typedef ZegoAudioVideoBackgroundAvatarBuilder = Widget Function(
    BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo);

class ZegoAudioVideoBackground extends StatelessWidget {
  final Size size;
  final ZegoUIKitUser? user;
  final bool showAvatar;
  final bool showSoundLevel;
  final ZegoAudioVideoBackgroundAvatarBuilder? avatarBuilder;

  const ZegoAudioVideoBackground({
    Key? key,
    required this.size,
    this.user,
    this.showAvatar = true,
    this.showSoundLevel = true,
    this.avatarBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showAvatar || user == null) {
      return Container(color: Colors.transparent);
    }

    var screenSize = MediaQuery.of(context).size;
    var isSmallView = size.height < screenSize.height / 2;

    var avatarSize =
        Size(isSmallView ? 110.r : 258.r, isSmallView ? 110.r : 258.r);
    var centralAvatar = avatarBuilder?.call(context, avatarSize, user, {}) ??
        circleName(context, size, user, isSmallView ? 46.0.r : 68.0.r);

    return Center(
      child: SizedBox(
        width: avatarSize.width,
        height: avatarSize.height,
        child: showSoundLevel
            ? ZegoRippleAvatar(
                minRadius: avatarSize.width / 2.0,
                radiusIncrement: isSmallView ? 0.12 : 0.06,
                soundLevelStream:
                    ZegoUIKit().getSoundLevelStream(user?.id ?? ""),
                child: centralAvatar,
              )
            : centralAvatar,
      ),
    );
  }

  Widget circleName(
      BuildContext context, Size size, ZegoUIKitUser? user, double fontSize) {
    var userName = user?.name ?? "";
    return Container(
      decoration:
          const BoxDecoration(color: Color(0xffDBDDE3), shape: BoxShape.circle),
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName.characters.first : "",
          style: TextStyle(
            fontSize: fontSize,
            color: const Color(0xff222222),
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
