part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

/// @nodoc
mixin ZegoCallControllerMinimizePrivate {
  final _private = ZegoCallControllerMinimizePrivateImpl();

  /// Don't call that
  ZegoCallControllerMinimizePrivateImpl get private => _private;
}

/// @nodoc
class ZegoCallControllerMinimizePrivateImpl {
  ZegoCallMinimizeData? get minimizeData => _minimizeData;

  List<IZegoUIKitPlugin>? plugins = [];
  ZegoCallMinimizeData? _minimizeData;
  ZegoUIKitPrebuiltCallConfig? config;

  final activeUser = ZegoCallControllerMinimizePrivateActiveUser();

  final isMinimizingNotifier = ValueNotifier<bool>(false);

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  void initByPrebuilt({
    required ZegoCallMinimizeData minimizeData,
    required ZegoUIKitPrebuiltCallConfig? config,
    required List<IZegoUIKitPlugin>? plugins,
  }) {
    ZegoLoggerService.logInfo(
      'init by prebuilt',
      tag: 'call',
      subTag: 'controller.minimize.p',
    );

    this.plugins = plugins;
    _minimizeData = minimizeData;
    this.config = config;

    activeUser.setConfig(config: config);

    isMinimizingNotifier.value = ZegoCallMiniOverlayMachine().isMinimizing;
    ZegoCallMiniOverlayMachine()
        .listenStateChanged(onMiniOverlayMachineStateChanged);
  }

  /// Please do not call this interface. It is the internal logic of Prebuilt.
  void uninitByPrebuilt() {
    ZegoLoggerService.logInfo(
      'un-init by prebuilt',
      tag: 'call',
      subTag: 'controller.minimize.p',
    );

    plugins = [];
    _minimizeData = null;
    config = null;
    activeUser.setConfig(config: null);

    ZegoCallMiniOverlayMachine()
        .removeListenStateChanged(onMiniOverlayMachineStateChanged);
  }

  void onMiniOverlayMachineStateChanged(
    ZegoCallMiniOverlayPageState state,
  ) {
    isMinimizingNotifier.value =
        ZegoCallMiniOverlayPageState.minimizing == state;
  }
}

class ZegoCallControllerMinimizePrivateActiveUser {
  bool isStarted = false;
  ZegoUIKitPrebuiltCallConfig? config;
  bool showLocalUserView = false;

  final activeUserIDNotifier = ValueNotifier<String?>(null);
  StreamSubscription<dynamic>? audioVideoListSubscription;
  List<StreamSubscription<dynamic>?> soundLevelSubscriptions = [];
  Timer? activeUserTimer;
  final Map<String, List<double>> rangeSoundLevels = {};

  bool get ignoreLocalUser {
    /// Under ios pip, only remote pull-based streaming can be rendered, so filtering is required
    bool ignore = false;
    if (Platform.isIOS) {
      if ((ZegoUIKitPrebuiltCallController().pip.private.pipImpl()
              as ZegoCallControllerIOSPIP)
          .isSupportInConfig) {
        ignore = true;
      }
    }

    return ignore ? ignore : !showLocalUserView;
  }

  void setConfig({
    required ZegoUIKitPrebuiltCallConfig? config,
  }) {
    this.config = config;
  }

  void start({
    bool showLocalUserView = false,
  }) {
    if (isStarted) {
      ZegoLoggerService.logInfo(
        'start, but already start',
        tag: 'call',
        subTag: 'controller.minimize.active_user',
      );

      return;
    }
    isStarted = true;
    this.showLocalUserView = showLocalUserView;

    ZegoLoggerService.logInfo(
      'start',
      tag: 'call',
      subTag: 'controller.minimize.active_user',
    );

    listenAudioVideoList();
    activeUserTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateActiveUserByTimer();
    });
  }

  void stop() {
    if (!isStarted) {
      ZegoLoggerService.logInfo(
        'stop, but not start',
        tag: 'call',
        subTag: 'controller.minimize.active_user',
      );

      return;
    }
    isStarted = false;

    ZegoLoggerService.logInfo(
      'stop',
      tag: 'call',
      subTag: 'controller.minimize.active_user',
    );

    audioVideoListSubscription?.cancel();
    activeUserTimer?.cancel();
    activeUserTimer = null;
  }

  void listenAudioVideoList() {
    audioVideoListSubscription =
        ZegoUIKit().getAudioVideoListStream().listen(onAudioVideoListUpdated);

    final audioVideoList = ZegoUIKit().getAudioVideoList();
    if (ignoreLocalUser) {
      audioVideoList
          .removeWhere((user) => user.id == ZegoUIKit().getLocalUser().id);
    }
    onAudioVideoListUpdated(audioVideoList);

    if (audioVideoList.isEmpty) {
      if (!ignoreLocalUser) {
        activeUserIDNotifier.value = ZegoUIKit().getLocalUser().id;
      }
    } else {
      activeUserIDNotifier.value = audioVideoList.first.id;
    }
  }

  void onAudioVideoListUpdated(List<ZegoUIKitUser> users) {
    for (final subscription in soundLevelSubscriptions) {
      subscription?.cancel();
    }
    rangeSoundLevels.clear();

    if (ignoreLocalUser) {
      users.removeWhere((user) => user.id == ZegoUIKit().getLocalUser().id);
    }
    for (final user in users) {
      soundLevelSubscriptions.add(user.soundLevel.listen((soundLevel) {
        if (rangeSoundLevels.containsKey(user.id)) {
          rangeSoundLevels[user.id]!.add(soundLevel);
        } else {
          rangeSoundLevels[user.id] = [soundLevel];
        }
      }));
    }
  }

  void updateActiveUserByTimer() {
    var maxAverageSoundLevel = 0.0;
    var activeUserID = '';

    rangeSoundLevels.forEach((userID, soundLevels) {
      final averageSoundLevel =
          soundLevels.reduce((a, b) => a + b) / soundLevels.length;

      if (averageSoundLevel > maxAverageSoundLevel) {
        activeUserID = userID;
        maxAverageSoundLevel = averageSoundLevel;
      }
    });

    if (activeUserID.isEmpty) {
      return;
    }

    if (activeUserID != activeUserIDNotifier.value) {
      ZegoLoggerService.logInfo(
        'update active user:$activeUserID',
        tag: 'call',
        subTag: 'controller.minimize.active_user',
      );
    }

    activeUserIDNotifier.value = activeUserID;
    if (activeUserIDNotifier.value?.isEmpty ?? true) {
      if (!ignoreLocalUser) {
        activeUserIDNotifier.value = ZegoUIKit().getLocalUser().id;
      }
    }

    rangeSoundLevels.clear();
  }

  String? switchActiveUserToRemoteUser() {
    if (activeUserIDNotifier.value != ZegoUIKit().getLocalUser().id) {
      return activeUserIDNotifier.value;
    }

    final audioVideoList = ZegoUIKit().getAudioVideoList();
    for (int idx = 0; idx < audioVideoList.length; ++idx) {
      final audioVideoUser = audioVideoList[idx];
      if (ZegoUIKit().getLocalUser().id == audioVideoUser.id) {
        continue;
      }

      if (audioVideoUser.id != activeUserIDNotifier.value) {
        ZegoLoggerService.logInfo(
          'switch remote active user:${audioVideoUser.id}',
          tag: 'call',
          subTag: 'controller.minimize.active_user',
        );
      }

      activeUserIDNotifier.value = audioVideoUser.id;

      break;
    }

    return activeUserIDNotifier.value;
  }
}
