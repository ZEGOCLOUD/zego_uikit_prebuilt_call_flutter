# ZEGO呼叫邀请时序图

以下时序图展示了ZEGO呼叫邀请系统中各种操作的API调用流程，基于ZIM SDK实现。

## 发起呼叫邀请 (Send Invitation)

```plantuml
@startuml
participant "发起方应用" as AppA
participant "ZegoCallInvitationService" as ServiceA
participant "ZegoUIKitSignalingPlugin" as PluginA
participant "ZIM SDK" as ZIMA
participant "服务器" as Server
participant "ZIM SDK" as ZIMB
participant "ZegoUIKitSignalingPlugin" as PluginB
participant "ZegoCallInvitationService" as ServiceB
participant "接收方应用" as AppB

AppA -> ServiceA: send(invitees, isVideoCall, ...)
ServiceA -> PluginA: sendInvitation(invitees, timeout, ...)
activate PluginA
PluginA -> ZIMA: callInvite(invitees, ZIMCallInviteConfig)
activate ZIMA
ZIMA -> Server: 发送邀请
activate Server
Server -> ZIMB: 推送邀请
activate ZIMB
ZIMB -> PluginB: 触发onCallInvitationReceived事件
PluginB -> ServiceB: 触发onIncomingInvitationReceived事件
ServiceB -> AppB: 触发onIncomingCallReceived回调
Server --> ZIMA: 返回发送结果
deactivate Server
ZIMA --> PluginA: 返回ZIMCallInvitationSentResult
deactivate ZIMA
PluginA --> ServiceA: 返回ZegoSignalingPluginSendInvitationResult
deactivate PluginA
ServiceA --> AppA: 返回发送结果(布尔值)

@enduml
```

## 接受呼叫邀请 (Accept Invitation)

```plantuml
@startuml
participant "接收方应用" as AppB
participant "ZegoCallInvitationService" as ServiceB
participant "ZegoUIKitSignalingPlugin" as PluginB
participant "ZIM SDK" as ZIMB
participant "服务器" as Server
participant "ZIM SDK" as ZIMA
participant "ZegoUIKitSignalingPlugin" as PluginA
participant "ZegoCallInvitationService" as ServiceA
participant "发起方应用" as AppA

AppB -> ServiceB: accept(customData)
ServiceB -> PluginB: acceptInvitation(invitationID, extendedData)
activate PluginB
PluginB -> ZIMB: callAccept(invitationID, ZIMCallAcceptConfig)
activate ZIMB
ZIMB -> Server: 发送接受请求
activate Server
Server -> ZIMA: 推送接受通知
activate ZIMA
ZIMA -> PluginA: 触发onCallInvitationAccepted事件
PluginA -> ServiceA: 触发OutgoingInvitationAccepted事件
ServiceA -> AppA: 触发onOutgoingCallAccepted回调
Server --> ZIMB: 返回接受结果
deactivate Server
ZIMB --> PluginB: 返回ZIMCallAcceptanceSentResult
deactivate ZIMB
PluginB --> ServiceB: 返回ZegoSignalingPluginResponseInvitationResult
deactivate PluginB
ServiceB --> AppB: 返回接受结果(布尔值)

@enduml
```

## 拒绝呼叫邀请 (Reject Invitation)

```plantuml
@startuml
participant "接收方应用" as AppB
participant "ZegoCallInvitationService" as ServiceB
participant "ZegoUIKitSignalingPlugin" as PluginB
participant "ZIM SDK" as ZIMB
participant "服务器" as Server
participant "ZIM SDK" as ZIMA
participant "ZegoUIKitSignalingPlugin" as PluginA
participant "ZegoCallInvitationService" as ServiceA
participant "发起方应用" as AppA

AppB -> ServiceB: reject(customData)
ServiceB -> PluginB: refuseInvitation(invitationID, extendedData)
activate PluginB
PluginB -> ZIMB: callReject(invitationID, ZIMCallRejectConfig)
activate ZIMB
ZIMB -> Server: 发送拒绝请求
activate Server
Server -> ZIMA: 推送拒绝通知
activate ZIMA
ZIMA -> PluginA: 触发onCallInvitationRejected事件
PluginA -> ServiceA: 触发onOutgoingInvitationRejected事件
ServiceA -> AppA: 触发onOutgoingCallRejectedCauseBusy/onOutgoingCallDeclined回调
Server --> ZIMB: 返回拒绝结果
deactivate Server
ZIMB --> PluginB: 返回ZIMCallRejectionSentResult
deactivate ZIMB
PluginB --> ServiceB: 返回ZegoSignalingPluginResponseInvitationResult
deactivate PluginB
ServiceB --> AppB: 返回拒绝结果(布尔值)

@enduml
```

## 取消呼叫邀请 (Cancel Invitation)

```plantuml
@startuml
participant "发起方应用" as AppA
participant "ZegoCallInvitationService" as ServiceA
participant "ZegoUIKitSignalingPlugin" as PluginA
participant "ZIM SDK" as ZIMA
participant "服务器" as Server
participant "ZIM SDK" as ZIMB
participant "ZegoUIKitSignalingPlugin" as PluginB
participant "ZegoCallInvitationService" as ServiceB
participant "接收方应用" as AppB

AppA -> ServiceA: cancel(callees, customData)
ServiceA -> PluginA: cancelInvitation(invitationID, invitees, extendedData)
activate PluginA
PluginA -> ZIMA: callCancel(invitees, invitationID, ZIMCallCancelConfig)
activate ZIMA
ZIMA -> Server: 发送取消请求
activate Server
Server -> ZIMB: 推送取消通知
activate ZIMB
ZIMB -> PluginB: 触发onCallInvitationCancelled事件
PluginB -> ServiceB: 触发IncomingInvitationCancelled事件
ServiceB -> AppB: 触发onIncomingCallCanceled回调
Server --> ZIMA: 返回取消结果
deactivate Server
ZIMA --> PluginA: 返回ZIMCallCancelSentResult
deactivate ZIMA
PluginA --> ServiceA: 返回ZegoSignalingPluginCancelInvitationResult
deactivate PluginA
ServiceA --> AppA: 返回取消结果(布尔值)

@enduml
```

## 超时处理 (Timeout Handling)

```plantuml
@startuml
participant "发起方应用" as AppA
participant "ZegoCallInvitationService" as ServiceA
participant "ZegoUIKitSignalingPlugin" as PluginA
participant "ZIM SDK" as ZIMA
participant "服务器" as Server
participant "ZIM SDK" as ZIMB
participant "ZegoUIKitSignalingPlugin" as PluginB
participant "ZegoCallInvitationService" as ServiceB
participant "接收方应用" as AppB

... 等待超时时间 ...

Server -> ZIMA: 超时通知
activate ZIMA
ZIMA -> PluginA: 触发onCallInviteesAnsweredTimeout事件
PluginA -> ServiceA: 触发onOutgoingInvitationTimeout事件
ServiceA -> AppA: 触发onOutgoingCallTimeout回调
deactivate ZIMA

Server -> ZIMB: 超时通知
activate ZIMB
ZIMB -> PluginB: 触发onCallInvitationTimeout事件
PluginB -> ServiceB: 触发onIncomingInvitationTimeout事件
ServiceB -> AppB: 触发onIncomingCallTimeout回调
deactivate ZIMB

@enduml
```

这些时序图展示了ZEGO呼叫邀请系统中各种操作的详细流程，包括从应用层到ZIM SDK的完整API调用链。
