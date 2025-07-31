# CallKit 文件结构说明

## 概述

CallKit模块采用平台分离的架构设计，Android和iOS各自有独立的实现，但保持相同的文件结构和处理逻辑。

## 文件结构对比

### Android 结构

```
android/
├── defines.dart              # Android配置定义和消息处理类
├── entry_point.dart          # Android后台消息入口点
├── handler.dart              # 主消息处理器
├── handler.call.dart         # 呼叫邀请处理器
└── handler.im.dart           # IM消息处理器
```

### iOS 结构

```
ios/
├── defines.dart              # iOS配置定义和消息处理类
├── entry_point.dart          # iOS VoIP推送入口点
├── handler.dart              # 主消息处理器
├── handler.call.dart         # 呼叫邀请处理器
├── handler.im.dart           # IM消息处理器
```

## 核心文件说明

### 1. entry_point.dart

- **Android**: 处理后台静默通知，使用 `@pragma('vm:entry-point')` 标记
- **iOS**: 处理VoIP推送通知，实现 `onIncomingPushReceived` 回调

### 2. handler.dart

- **功能**: 主消息处理器，负责消息类型判断和分发
- **逻辑**:
  - 解析消息类型
  - 根据类型分发到IM处理器或呼叫处理器
  - 统一的错误处理和日志记录

### 3. handler.call.dart

- **功能**: 处理呼叫邀请相关消息
- **特性**:
  - 支持普通邀请和高级邀请模式
  - 处理邀请取消
  - 显示CallKit界面
  - 保持原有iOS离线呼叫逻辑

### 4. handler.im.dart

- **功能**: 处理IM消息
- **特性**:
  - 显示通知
  - 处理点击事件
  - 缓存会话信息
  - 打开应用并跳转

### 5. defines.dart

- **功能**: 定义消息处理相关的数据结构和配置
- **包含**:
  - HandlerPrivateInfo: 平台特定配置
  - BackgroundMessageHandlerMessage: 消息处理类
  - 消息类型枚举和扩展

## 消息处理流程

### Android 流程

1. 后台静默通知触发 `onBackgroundMessageReceived`
2. 检查应用是否运行，决定是否使用isolate
3. 解析消息类型
4. 分发到相应的处理器

### iOS 流程

1. VoIP推送触发 `onIncomingPushReceived`
2. 检查消息类型（IM消息 vs 呼叫邀请）
3. 分发到相应的处理器
4. 保持原有CallKit逻辑

## 消息类型支持

| 类型              | Android | iOS | 说明                                              |
| ----------------- | ------- | --- | ------------------------------------------------- |
| invitation        | ✅      | ✅  | 呼叫邀请                                          |
| text_message      | ✅      | ✅  | 文本消息 (Android: text_message, iOS: text_msg)   |
| media_message     | ✅      | ✅  | 媒体消息 (Android: media_message, iOS: media_msg) |
| cancel_invitation | ✅      | ✅  | 取消邀请                                          |

## 配置管理

### Android 配置

- `androidCallChannelID`: 呼叫通知渠道ID
- `androidMessageChannelID`: IM消息通知渠道ID
- `androidCallIcon/Sound/Vibrate`: 呼叫通知配置
- `androidMessageIcon/Sound/Vibrate`: IM消息通知配置

### iOS 配置

- `iosCallChannelID`: 呼叫通知渠道ID
- `iosMessageChannelID`: IM消息通知渠道ID
- `iosCallIcon/Sound/Vibrate`: 呼叫通知配置
- `iosMessageIcon/Sound/Vibrate`: IM消息通知配置

## 设计原则

1. **一致性**: Android和iOS保持相同的文件结构和处理逻辑
2. **分离性**: 平台特定代码完全分离，便于维护
3. **扩展性**: 易于添加新的消息类型和处理器
4. **兼容性**: 保持原有功能的完全兼容

## 消息结构差异

### Android 消息结构
```dart
extras: {
  'body': '消息内容',
  'title': '消息标题',
  'payload': '{"operation_type":"text_message",...}',
  'zego': {...}
}
```

### iOS 消息结构
```dart
extras: {
  'aps': {
    'alert': {
      'title': '消息标题',
      'body': '消息内容'
    }
  },
  'payload': '{"operation_type":"text_msg",...}',
  'zego': {...}
}
```

### 关键差异
1. **消息内容位置**: Android直接在extras中，iOS在extras['aps']['alert']中
