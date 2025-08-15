// Dart imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';

//

/// Widget for minimized invitation interface
class ZegoMinimizingCallingPage extends StatelessWidget {
  const ZegoMinimizingCallingPage({
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
          ? 'Waiting for video call answer'
          : 'Waiting for voice call answer';
    } else {
      text = invitationType == ZegoCallInvitationType.videoCall
          ? 'Video call invitation received'
          : 'Voice call invitation received';
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
      // Caller side: show cancel button
      return GestureDetector(
        onTap: () {
          // Logic for canceling invitation
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
            'Cancel',
            style: TextStyle(
              color: Colors.white,
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    } else {
      // Callee side: show accept/reject buttons
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              // Logic for accepting invitation
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
                'Accept',
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
              // Logic for rejecting invitation
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
                'Reject',
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
