# ZEGO UIKit Prebuilt Call Flutter - 应用内最小化功能文档

## 概述

应用内最小化功能允许用户将通话界面最小化为应用内的可拖拽悬浮窗口。该功能支持**通话中最小化**和**邀请中最小化**两种场景，为用户提供无缝的通话体验。

## 架构概览

### 核心组件

```
lib/src/minimizing/
├── data.dart              # 最小化数据结构
├── defines.dart           # 状态定义和枚举
├── overlay_machine.dart   # 悬浮窗状态机
├── overlay_page.dart      # 主悬浮窗组件
└── mini_button.dart       # 最小化按钮组件

lib/src/controller/
├── minimize.dart          # 主最小化控制器
└── private/
    └── minimize.dart      # 私有实现细节

lib/src/invitation/
└── pages/
    ├── page_manager.dart  # 邀请页面管理
    └── calling/
        └── machine.dart   # 邀请状态机
```

## 数据结构

### ZegoCallMinimizeData

最小化的主数据容器，使用联合类型模式：

```dart
class ZegoCallMinimizeData {
  final int appID;
  final String appSign;
  final String token;
  final String userID;
  final String userName;
  final String callID;
  final VoidCallback? onDispose;
  
  // 联合类型，使用命名构造函数
  final ZegoInCallMinimizeData? inCall;
  final ZegoInvitingMinimizeData? inviting;
  
  // 命名构造函数
  const ZegoCallMinimizeData.inCall({
    required this.appID,
    required this.appSign,
    required this.token,
    required this.userID,
    required this.userName,
    required this.callID,
    this.onDispose,
    required ZegoInCallMinimizeData inCallData,
  }) : inCall = inCallData, inviting = null;
  
  const ZegoCallMinimizeData.inviting({
    required this.appID,
    required this.appSign,
    required this.token,
    required this.userID,
    required this.userName,
    required this.callID,
    this.onDispose,
    required ZegoInvitingMinimizeData invitingData,
  }) : inviting = invitingData, inCall = null;
}
```

### ZegoInCallMinimizeData

通话中最小化数据：

```dart
class ZegoInCallMinimizeData {
  final ZegoUIKitPrebuiltCallConfig config;
  final ZegoUIKitPrebuiltCallEvents events;
  final bool isPrebuiltFromMinimizing;
  final List<IZegoUIKitPlugin>? plugins;
  final DateTime durationStartTime;
}
```

### ZegoInvitingMinimizeData

邀请中最小化数据：

```dart
class ZegoInvitingMinimizeData {
  final ZegoUIKitPrebuiltCallingConfig callingConfig;
  final ZegoUIKitPrebuiltCallInvitationData callInvitationData;
  final ZegoCallInvitationPageManager pageManager;
}
```

## 状态管理

### ZegoCallMiniOverlayPageState

```dart
enum ZegoCallMiniOverlayPageState {
  idle,               // 无悬浮窗显示
  inCallMinimized,    // 通话界面已最小化
  invitingMinimized,  // 邀请界面已最小化
}
```

### ZegoCallMiniOverlayMachine

管理悬浮窗可见性和状态转换的状态机：

```dart
class ZegoCallMiniOverlayMachine {
  static final ZegoCallMiniOverlayMachine _instance = ZegoCallMiniOverlayMachine._internal();
  factory ZegoCallMiniOverlayMachine() => _instance;
  
  ZegoCallMiniOverlayPageState _state = ZegoCallMiniOverlayPageState.idle;
  final List<Function(ZegoCallMiniOverlayPageState)> _listeners = [];
  
  ZegoCallMiniOverlayPageState state() => _state;
  
  void changeState(ZegoCallMiniOverlayPageState newState) {
    if (_state != newState) {
      final oldState = _state;
      _state = newState;
      _notifyListeners(oldState, newState);
    }
  }
}
```

## 关键工作流程

### 1. 通话中最小化

**触发条件**: 用户在通话过程中点击最小化按钮

**流程**:

```
1. 用户点击最小化按钮
2. ZegoCallMinimizingButton.onPressed() 被调用
3. ZegoUIKitPrebuiltCallController().minimize.minimize() 被调用
4. 悬浮窗状态变为 inCallMinimized
5. ZegoCallMiniOverlayPage 显示最小化通话界面
6. 完整通话界面从导航栈中弹出
```

**代码路径**:

```dart
// lib/src/minimizing/mini_button.dart
onPressed: () {
  ZegoUIKitPrebuiltCallController().minimize.minimize();
}

// lib/src/controller/minimize.dart
void minimize() {
  final minimizeData = private.minimizeData;
  if (minimizeData?.inCall != null) {
    // 创建包含通话数据的悬浮窗
    ZegoCallMiniOverlayMachine().changeState(
      ZegoCallMiniOverlayPageState.inCallMinimized
    );
    // 弹出完整界面
    Navigator.of(context).pop();
  }
}
```

### 2. 邀请中最小化

**触发条件**: 用户在邀请过程中点击最小化按钮

**流程**:

```
1. 用户在邀请界面点击最小化按钮
2. ZegoCallMinimizingButton.onPressed() 被调用
3. ZegoUIKitPrebuiltCallController().minimize.minimizeInviting() 被调用
4. 悬浮窗状态变为 invitingMinimized
5. ZegoCallMiniOverlayPage 显示最小化邀请界面
6. 完整邀请界面从导航栈中弹出
```

**代码路径**:

```dart
// lib/src/controller/minimize.dart
void minimizeInviting() {
  final minimizeData = private.minimizeData;
  if (minimizeData?.inviting != null) {
    // 创建包含邀请数据的悬浮窗
    ZegoCallMiniOverlayMachine().changeState(
      ZegoCallMiniOverlayPageState.invitingMinimized
    );
    // 弹出完整界面
    Navigator.of(context).pop();
  }
}
```

### 3. 状态转换

**触发条件**: 邀请界面最小化时，对端同意邀请

**流程**:

```
1. 对端用户同意邀请
2. page_manager.dart 中调用 onInvitationAccepted()
3. 检查当前状态是否为 invitingMinimized
4. 立即将悬浮窗状态转换为 idle
5. 清除最小化数据
6. 通话页面以正确的空闲状态初始化
7. 音视频连接成功建立
```

**代码路径**:

```dart
// lib/src/invitation/pages/page_manager.dart
void onInvitationAccepted(Map<String, dynamic> params) {
  // ... 现有逻辑 ...
  
  // 关键修复：如果邀请界面当前处于最小化状态，
  // 立即转换悬浮窗状态，确保通话页面能正确初始化
  if (ZegoCallMiniOverlayPageState.invitingMinimized ==
      ZegoUIKitPrebuiltCallController().minimize.state) {
  
    // 立即隐藏悬浮窗，将状态设置为空闲
    ZegoCallMiniOverlayMachine()
        .changeState(ZegoCallMiniOverlayPageState.idle);

    // 清除最小化数据，防止通话页面在初始化时检测到
    // 非空闲的悬浮窗状态
    ZegoUIKitPrebuiltCallController().minimize.private.clearMinimizeData();
  }
  
  // 继续正常流程
  if (isInCalling) {
    callingMachine?.stateOnlineAudioVideo.enter();
  }
}
```

## 控制器实现

### ZegoUIKitPrebuiltCallController.minimize

最小化操作的主要公共接口：

```dart
class ZegoUIKitPrebuiltCallController {
  ZegoCallControllerMinimizingImpl get minimize => 
    ZegoCallControllerMinimizingImpl();
}

class ZegoCallControllerMinimizingImpl {
  /// 最小化当前通话界面
  void minimize();
  
  /// 最小化当前邀请界面
  void minimizeInviting();
  
  /// 恢复最小化的通话界面
  void restore();
  
  /// 恢复最小化的邀请界面
  void restoreInviting();
  
  /// 隐藏悬浮窗（通话结束时使用）
  void hide();
}
```

### 私有实现

```dart
class ZegoCallControllerMinimizingImpl {
  ZegoCallControllerMinimizePrivate get private => 
    ZegoCallControllerMinimizePrivateImpl();
  
  /// 监听邀请状态变化
  void _listenInvitationStateChanged(ZegoCallInvitationPageManager pageManager);
  
  /// 邀请被接受时自动转换最小化状态
  void _autoConvertToInCallMinimized();
  
  /// 将邀请配置转换为预构建通话配置
  ZegoUIKitPrebuiltCallConfig _convertCallingConfigToPrebuiltConfig(
    ZegoUIKitPrebuiltCallingConfig callingConfig
  );
}
```

## 悬浮窗组件实现

### ZegoUIKitPrebuiltCallMiniOverlayPage

根据状态显示不同内容的主悬浮窗组件：

```dart
class ZegoUIKitPrebuiltCallMiniOverlayPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return OverlayEntry(
      builder: (context) => _buildOverlayContent(),
    );
  }
  
  Widget _buildOverlayContent() {
    switch (ZegoCallMiniOverlayMachine().state()) {
      case ZegoCallMiniOverlayPageState.inCallMinimized:
        return _buildInCallMinimizedWidget();
      case ZegoCallMiniOverlayPageState.invitingMinimized:
        return _buildInvitingMinimizedWidget();
      default:
        return const SizedBox.shrink();
    }
  }
}
```

### 组件类型

#### ZegoMinimizingCallPage

显示最小化通话界面，包含：

- 用户头像和姓名
- 通话时长
- 最小化/恢复按钮
- 挂断按钮

#### ZegoMinimizingCallingPage

显示最小化邀请界面，包含：

- 邀请者信息
- 通话类型指示器
- 最小化/恢复按钮
- 接听/拒绝按钮

## 关键技术要点

### 1. 状态同步

悬浮窗状态必须与实际通话状态同步，防止初始化问题：

```dart
// 修复前：通话页面看到 invitingMinimized 状态
{call} {prebuilt} {mini machine state is not idle, context will not be init}

// 修复后：立即状态转换
ZegoCallMiniOverlayMachine().changeState(ZegoCallMiniOverlayPageState.idle);
private.clearMinimizeData();
```

### 2. 导航栈管理

最小化涉及弹出完整界面和管理导航栈：

```dart
// 最小化时弹出完整界面
Navigator.of(context).pop();

// 恢复时推送界面
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => ZegoUIKitPrebuiltCall(...),
  ),
);
```

### 3. 数据持久化

最小化数据必须在状态变化间持久化，并在适当时机清理：

```dart
// 转换状态时更新数据
private.updateMinimizeData(newMinimizeData);

// 不再需要时清除数据
private.clearMinimizeData();
```

### 4. 事件处理

系统必须在最小化状态下处理各种邀请事件：

```dart
// 监听邀请状态变化
pageManager.callingMachine?.onStateChanged = (CallingState state) {
  if (state == CallingState.kOnlineAudioVideo) {
    _autoConvertToInCallMinimized();
  }
};
```

## 性能考虑

1. **状态机效率**: 悬浮窗机器使用单例模式
2. **内存管理**: 适当清理最小化数据
3. **导航优化**: 最小化导航栈操作
4. **事件监听器管理**: 正确注册和清理

## 测试场景

### 1. 基本最小化

- 通话过程中最小化
- 邀请过程中最小化
- 从最小化状态恢复

### 2. 状态转换

- 最小化时邀请被接受
- 最小化时邀请被拒绝
- 最小化时通话结束

### 3. 边界情况

- 多次最小化/恢复操作
- 最小化时应用后台化
- 最小化时网络状态变化

## 未来增强

1. **动画支持**: 状态间的平滑过渡
2. **自定义悬浮窗样式**: 用户可配置的外观
3. **手势控制**: 滑动恢复、拖拽重新定位

## 总结

应用内最小化功能为通话和邀请提供了强大且用户友好的最小化状态处理方式。最近对邀请最小化时被接受的修复确保了可靠的状态转换和正确的通话初始化。该架构设计为可扩展和可维护的，在数据、状态管理和UI组件之间有清晰的关注点分离。
