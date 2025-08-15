// Dart imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';

/// 邀请中最小化组件
class ZegoInvitingMinimizedWidget extends StatelessWidget {
  const ZegoInvitingMinimizedWidget({
    Key? key,
    required this.size,
    required this.invitationType,
    required this.inviter,
    required this.invitees,
    required this.isInviter,
    this.customData,
  }) : super(key: key);

  final Size size;
  final ZegoCallInvitationType invitationType;
  final ZegoUIKitUser inviter;
  final List<ZegoUIKitUser> invitees;
  final bool isInviter;
  final String? customData;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAvatar(),
          SizedBox(height: size.height * 0.05),
          _buildStatusText(),
          SizedBox(height: size.height * 0.05),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: size.width * 0.3,
      height: size.width * 0.3,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
      child: Center(
        child: Text(
          inviter.name.isNotEmpty ? inviter.name[0].toUpperCase() : 'U',
          style: TextStyle(
            color: Colors.white,
            fontSize: size.width * 0.15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusText() {
    String text;
    if (isInviter) {
      text = invitationType == ZegoCallInvitationType.videoCall
          ? '等待接听视频通话'
          : '等待接听语音通话';
    } else {
      text = invitationType == ZegoCallInvitationType.videoCall
          ? '收到视频通话邀请'
          : '收到语音通话邀请';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: size.width * 0.06,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildActionButtons() {
    if (isInviter) {
      // 呼叫端：显示取消按钮
      return GestureDetector(
        onTap: () {
          // 取消邀请的逻辑
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
            vertical: size.height * 0.03,
          ),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '取消',
            style: TextStyle(
              color: Colors.white,
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    } else {
      // 被呼叫端：显示接受/拒绝按钮
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              // 接受邀请的逻辑
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: size.height * 0.03,
              ),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '接受',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // 拒绝邀请的逻辑
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: size.height * 0.03,
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '拒绝',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}
