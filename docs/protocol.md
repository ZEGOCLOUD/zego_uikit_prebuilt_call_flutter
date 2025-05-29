

# 一、ZEGO呼叫邀请协议文档

ZEGO呼叫邀请系统通过一系列标准化的协议来处理通信，这些协议定义了在通信过程中交换的数据格式和结构。

## 1. 协议版本控制 (ZegoCallInvitationProtocolVersion)

所有协议都使用版本号标识，当前版本为"f1.0"，用于标准化不同版本间的兼容性处理。

```dart
mixin ZegoCallInvitationProtocolVersion {
  String version = 'f1.0';

  void _parseVersionFromMap(Map<String, dynamic> dict) {
    version = dict[ZegoCallInvitationProtocolKey.version] ?? 'f1.0';
  }
}
```

## 2. 协议键值定义 (ZegoCallInvitationProtocolKey)

通信过程中使用的标准键名：

| 键名 | 说明 |
|-----|-----|
| callID | 呼叫ID |
| invitationID | 邀请ID |
| timeout | 超时时间 |
| customData | 自定义数据 |
| invitees | 被邀请者列表 |
| inviterName | 邀请者名称 |
| userID | 用户ID |
| userName | 用户名称 |
| operationType | 操作类型 |
| reason | 拒绝原因 |
| refuseByDecline | 拒绝原因-拒绝 |
| refuseByBusy | 拒绝原因-忙碌 |
| version | 协议版本号 |

```dart
class ZegoCallInvitationProtocolKey {
  static String callID = 'call_id';
  static String invitationID = 'invitation_id';
  static String timeout = 'timeout';
  static String customData = 'custom_data';
  static String invitees = 'invitees';
  static String inviterName = 'inviter_name';
  static String userID = 'user_id';
  static String userName = 'user_name';
  static String operationType = 'operation_type';

  ///
  static String reason = 'reason';
  static String refuseByDecline = 'decline';
  static String refuseByBusy = 'busy';

  ///
  static String version = 'v';
}
```

# 二、协议

## 1. 发送邀请协议

在ZEGO呼叫邀请系统中，使用了两层协议封装：

1. **外层协议(ZegoUIKitInvitationSendProtocol)**: 用于ZIM SDK通信层
2. **内层协议(ZegoCallInvitationSendRequestProtocol等)**: 用于呼叫邀请业务逻辑

内层协议会被序列化为JSON字符串，然后作为外层协议的customData字段值传递。这种嵌套结构使得系统能够在保持底层通信协议稳定的同时，扩展上层业务逻辑。

### 外层发送邀请协议 (ZegoUIKitInvitationSendProtocol)

用于ZIM SDK底层通信的数据结构：

| 字段 | 类型 | 说明 |
|-----|-----|-----|
| inviter | ZegoUIKitUser | 邀请者信息 |
| type | int | 呼叫类型(0:语音呼叫, 1:视频呼叫) |
| customData | String | 自定义数据，其中包含序列化后的内层协议 |

JSON格式示例：
```json
{
  "inviter": {
    "id": "user123",
    "name": "张三"
  },
  "type": 1,
  "custom_data": "{\"call_id\":\"uniqueCallID\",\"inviter_name\":\"张三\",\"invitees\":[{\"user_id\":\"user1\",\"user_name\":\"李四\"}],\"timeout\":60,\"custom_data\":\"自定义数据\",\"v\":\"f1.0\"}"
}
```

### 内层发送邀请协议 (ZegoCallInvitationSendRequestProtocol)

用于发送呼叫邀请的数据结构，被封装在ZegoUIKitInvitationSendProtocol的customData字段中：

| 字段 | 类型 | 说明 |
|-----|-----|-----|
| callID | String | 呼叫ID |
| inviterName | String | 邀请者名称 |
| invitees | List<ZegoUIKitUser> | 被邀请者列表 |
| customData | String | 自定义数据 |
| timeout | int | 超时时间(秒)，默认60秒 |
| version | String | 协议版本号 |

JSON格式示例：
```json
{
  "call_id": "uniqueCallID",
  "inviter_name": "张三",
  "invitees": [
    {"user_id": "user1", "user_name": "李四"},
    {"user_id": "user2", "user_name": "王五"}
  ],
  "timeout": 60,
  "custom_data": "自定义数据",
  "v": "f1.0"
}
```

## 2. 取消邀请协议 (ZegoCallInvitationCancelRequestProtocol)

用于取消已发送的呼叫邀请：

| 字段 | 类型 | 说明 |
|-----|-----|-----|
| callID | String | 呼叫ID |
| customData | String | 自定义数据 |
| operationType | String | 操作类型，固定为"cancelInvitation" |
| version | String | 协议版本号 |

JSON格式示例：
```json
{
  "call_id": "uniqueCallID",
  "operation_type": "cancelInvitation",
  "custom_data": "取消原因",
  "v": "f1.0"
}
```

## 3. 拒绝邀请协议 (ZegoCallInvitationRejectRequestProtocol)

用于拒绝收到的呼叫邀请：

| 字段 | 类型 | 说明 |
|-----|-----|-----|
| targetInvitationID | String | 目标邀请ID |
| reason | String | 拒绝原因 |
| customData | String | 自定义数据 |
| version | String | 协议版本号 |

JSON格式示例：
```json
{
  "invitation_id": "invitationID",
  "reason": "decline/busy",
  "custom_data": "自定义拒绝原因",
  "v": "f1.0"
}
```

## 4. 接受邀请协议 (ZegoCallInvitationAcceptRequestProtocol)

用于接受收到的呼叫邀请：

| 字段 | 类型 | 说明 |
|-----|-----|-----|
| customData | String | 自定义数据 |
| version | String | 协议版本号 |

JSON格式示例：
```json
{
  "custom_data": "自定义接受信息",
  "v": "f1.0"
}
```

# 三、协议交互流程

## 1. 发起呼叫邀请
   - 构造内层`ZegoCallInvitationSendRequestProtocol`对象
   - 序列化为JSON字符串作为外层`ZegoUIKitInvitationSendProtocol`的customData
   - 将外层协议序列化为JSON并通过ZIM SDK发送

```dart
// 构造内层协议
final sendProtocol = ZegoCallInvitationSendRequestProtocol(
  callID: callID,
  inviterName: ZegoUIKit().getLocalUser().name,
  invitees: callees.map((invitee) => ZegoUIKitUser(
    id: invitee.id,
    name: invitee.name,
  )).toList(),
  timeout: timeoutSeconds,
  customData: customData,
).toJson();

// 构造外层协议并传递内层协议(作为外层协议的data参数)
final zimExtendedData = const JsonEncoder().convert(
  ZegoUIKitInvitationSendProtocol(
    inviter: ZegoUIKitUser(id: inviterID, name: inviterName),
    type: type,
    customData: sendProtocol,  // 内层协议作为data参数
  ).toJson(),
);
```

## 2. 取消呼叫邀请
   - 构造`ZegoCallInvitationCancelRequestProtocol`对象
   - 序列化为JSON并通过ZIM SDK发送

## 3. 接受呼叫邀请
   - 构造`ZegoCallInvitationAcceptRequestProtocol`对象
   - 序列化为JSON并通过ZIM SDK发送

## 4. 拒绝呼叫邀请
   - 构造`ZegoCallInvitationRejectRequestProtocol`对象
   - 序列化为JSON并通过ZIM SDK发送