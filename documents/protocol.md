# ZEGO Call Invitation Protocol Documentation

The ZEGO Call Invitation system handles communication through a series of standardized protocols, defining the data formats and structures exchanged during communication.

## 1. Protocol Version Control (ZegoCallInvitationProtocolVersion)

All protocols use a version identifier. The current version is "f1.0", which is used for standardizing compatibility handling between different versions.

```dart
mixin ZegoCallInvitationProtocolVersion {
  String version = 'f1.0';

  void _parseVersionFromMap(Map<String, dynamic> dict) {
    version = dict[ZegoCallInvitationProtocolKey.version] ?? 'f1.0';
  }
}
```

## 2. Protocol Key Definitions (ZegoCallInvitationProtocolKey)

Standard key names used during communication:

| Key | Description |
|-----|-------------|
| callID | Call ID |
| invitationID | Invitation ID |
| timeout | Timeout duration |
| customData | Custom data |
| invitees | List of invitees |
| inviterName | Inviter's name |
| userID | User ID |
| userName | User's name |
| operationType | Operation type |
| reason | Rejection reason |
| refuseByDecline | Rejection reason - declined |
| refuseByBusy | Rejection reason - busy |
| version | Protocol version |

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

---

# Protocols

## 1. Send Invitation Protocol

The ZEGO Call Invitation system uses a two-layer protocol structure:

1. **Outer Protocol (ZegoUIKitInvitationSendProtocol)**: Used for ZIM SDK communication layer
2. **Inner Protocol (ZegoCallInvitationSendRequestProtocol, etc.)**: Used for call invitation business logic

The inner protocol is serialized as a JSON string and passed as the `customData` field value of the outer protocol. This nested structure allows the system to extend upper-layer business logic while keeping the underlying communication protocol stable.

### Outer Send Invitation Protocol (ZegoUIKitInvitationSendProtocol)

Data structure used for ZIM SDK underlying communication:

| Field | Type | Description |
|-------|------|-------------|
| inviter | ZegoUIKitUser | Inviter information |
| type | int | Call type (0: voice call, 1: video call) |
| customData | String | Custom data containing serialized inner protocol |

JSON format example:
```json
{
  "inviter": {
    "id": "user123",
    "name": "John"
  },
  "type": 1,
  "custom_data": "{\"call_id\":\"uniqueCallID\",\"inviter_name\":\"John\",\"invitees\":[{\"user_id\":\"user1\",\"user_name\":\"Alice\"}],\"timeout\":60,\"custom_data\":\"custom data\",\"v\":\"f1.0\"}"
}
```

### Inner Send Invitation Protocol (ZegoCallInvitationSendRequestProtocol)

Data structure for sending call invitations, encapsulated in the `customData` field of `ZegoUIKitInvitationSendProtocol`:

| Field | Type | Description |
|-------|------|-------------|
| callID | String | Call ID |
| inviterName | String | Inviter's name |
| invitees | List<ZegoUIKitUser> | List of invitees |
| customData | String | Custom data |
| timeout | int | Timeout in seconds, default is 60 seconds |
| version | String | Protocol version |

JSON format example:
```json
{
  "call_id": "uniqueCallID",
  "inviter_name": "John",
  "invitees": [
    {"user_id": "user1", "user_name": "Alice"},
    {"user_id": "user2", "user_name": "Bob"}
  ],
  "timeout": 60,
  "custom_data": "custom data",
  "v": "f1.0"
}
```

## 2. Cancel Invitation Protocol (ZegoCallInvitationCancelRequestProtocol)

Used to cancel a sent call invitation:

| Field | Type | Description |
|-------|------|-------------|
| callID | String | Call ID |
| customData | String | Custom data |
| operationType | String | Operation type, fixed as "cancelInvitation" |
| version | String | Protocol version |

JSON format example:
```json
{
  "call_id": "uniqueCallID",
  "operation_type": "cancelInvitation",
  "custom_data": "cancellation reason",
  "v": "f1.0"
}
```

## 3. Reject Invitation Protocol (ZegoCallInvitationRejectRequestProtocol)

Used to reject a received call invitation:

| Field | Type | Description |
|-------|------|-------------|
| targetInvitationID | String | Target invitation ID |
| reason | String | Rejection reason |
| customData | String | Custom data |
| version | String | Protocol version |

JSON format example:
```json
{
  "invitation_id": "invitationID",
  "reason": "decline/busy",
  "custom_data": "custom rejection reason",
  "v": "f1.0"
}
```

## 4. Accept Invitation Protocol (ZegoCallInvitationAcceptRequestProtocol)

Used to accept a received call invitation:

| Field | Type | Description |
|-------|------|-------------|
| customData | String | Custom data |
| version | String | Protocol version |

JSON format example:
```json
{
  "custom_data": "custom acceptance message",
  "v": "f1.0"
}
```

---

# Protocol Interaction Flow

## 1. Initiating a Call Invitation
- Construct the inner `ZegoCallInvitationSendRequestProtocol` object
- Serialize it as a JSON string as the `customData` of the outer `ZegoUIKitInvitationSendProtocol`
- Serialize the outer protocol as JSON and send it through the ZIM SDK

```dart
// Construct inner protocol
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

// Construct outer protocol and pass inner protocol (as data parameter of outer protocol)
final zimExtendedData = const JsonEncoder().convert(
  ZegoUIKitInvitationSendProtocol(
    inviter: ZegoUIKitUser(id: inviterID, name: inviterName),
    type: type,
    customData: sendProtocol,  // Inner protocol as data parameter
  ).toJson(),
);
```

## 2. Canceling a Call Invitation
- Construct the `ZegoCallInvitationCancelRequestProtocol` object
- Serialize as JSON and send through the ZIM SDK

## 3. Accepting a Call Invitation
- Construct the `ZegoCallInvitationAcceptRequestProtocol` object
- Serialize as JSON and send through the ZIM SDK

## 4. Rejecting a Call Invitation
- Construct the `ZegoCallInvitationRejectRequestProtocol` object
- Serialize as JSON and send through the ZIM SDK
