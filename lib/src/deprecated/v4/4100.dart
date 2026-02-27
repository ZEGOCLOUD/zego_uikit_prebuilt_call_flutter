// Project imports:
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

const deprecatedTipsV4100 = ', '
    'deprecated since 4.10.0, '
    'will be removed after 4.10.0,'
    'Migrate Guide:https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/topics/Migration_4.x-topic.html#4100';

@Deprecated('use ZegoCallAudioEffectConfig instead$deprecatedTipsV4100')
typedef ZegoCallingBackgroundBuilderInfo = ZegoCallAudioEffectConfig;
