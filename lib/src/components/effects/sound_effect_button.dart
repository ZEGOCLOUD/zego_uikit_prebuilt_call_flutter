// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/components/assets.dart';
import 'package:zego_uikit_prebuilt_call/src/components/effects/sound_effect_sheet.dart';
import 'package:zego_uikit_prebuilt_call/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_call/src/config.dart';
import 'package:zego_uikit_prebuilt_call/src/inner_text.dart';

/// @nodoc
class ZegoCallSoundEffectButton extends StatefulWidget {
  final List<VoiceChangerType> voiceChangeEffect;
  final List<ReverbType> reverbEffect;

  final Size? iconSize;
  final Size? buttonSize;
  final ButtonIcon? icon;
  final ZegoUIKitPrebuiltCallInnerText translationText;
  final bool rootNavigator;
  final ZegoCallPopUpManager popUpManager;

  final ZegoCallAudioEffectConfig effectConfig;

  const ZegoCallSoundEffectButton({
    Key? key,
    required this.translationText,
    required this.rootNavigator,
    required this.voiceChangeEffect,
    required this.reverbEffect,
    required this.effectConfig,
    required this.popUpManager,
    this.iconSize,
    this.buttonSize,
    this.icon,
  }) : super(key: key);

  @override
  State<ZegoCallSoundEffectButton> createState() =>
      _ZegoCallSoundEffectButtonState();
}

/// @nodoc
class _ZegoCallSoundEffectButtonState extends State<ZegoCallSoundEffectButton> {
  var voiceChangerSelectedIDNotifier = ValueNotifier<String>('');
  var reverbSelectedIDNotifier = ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    final containerSize = widget.buttonSize ?? Size(96.zR, 96.zR);
    final sizeBoxSize = widget.iconSize ?? Size(56.zR, 56.zR);
    return GestureDetector(
      onTap: () async {
        showSoundEffectSheet(
          context,
          translationText: widget.translationText,
          rootNavigator: widget.rootNavigator,
          voiceChangeEffect: widget.voiceChangeEffect,
          voiceChangerSelectedIDNotifier: voiceChangerSelectedIDNotifier,
          reverbEffect: widget.reverbEffect,
          reverbSelectedIDNotifier: reverbSelectedIDNotifier,
          config: widget.effectConfig,
          popUpManager: widget.popUpManager,
        );
      },
      child: Container(
        width: containerSize.width,
        height: containerSize.height,
        decoration: BoxDecoration(
          color: widget.icon?.backgroundColor ??
              ZegoUIKitDefaultTheme.buttonBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: SizedBox.fromSize(
          size: sizeBoxSize,
          child: widget.icon?.icon ??
              ZegoCallImage.asset(ZegoCallIconUrls.toolbarSoundEffect),
        ),
      ),
    );
  }
}
