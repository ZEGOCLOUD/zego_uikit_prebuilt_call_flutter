# ZEGO Call Invitation Sequence Diagrams

The following sequence diagrams illustrate the API call flows for various operations in the ZEGO Call Invitation system, implemented based on the ZIM SDK.

## Send Invitation

```plantuml
@startuml
participant "Caller App" as AppA
participant "ZegoCallInvitationService" as ServiceA
participant "ZegoUIKitSignalingPlugin" as PluginA
participant "ZIM SDK" as ZIMA
participant "Server" as Server
participant "ZIM SDK" as ZIMB
participant "ZegoUIKitSignalingPlugin" as PluginB
participant "ZegoCallInvitationService" as ServiceB
participant "Callee App" as AppB

AppA -> ServiceA: send(invitees, isVideoCall, ...)
ServiceA -> PluginA: sendInvitation(invitees, timeout, ...)
activate PluginA
PluginA -> ZIMA: callInvite(invitees, ZIMCallInviteConfig)
activate ZIMA
ZIMA -> Server: Send invitation
activate Server
Server -> ZIMB: Push invitation
activate ZIMB
ZIMB -> PluginB: Trigger onCallInvitationReceived event
PluginB -> ServiceB: Trigger onIncomingInvitationReceived event
ServiceB -> AppB: Trigger onIncomingCallReceived callback
Server --> ZIMA: Return send result
deactivate Server
ZIMA --> PluginA: Return ZIMCallInvitationSentResult
deactivate ZIMA
PluginA --> ServiceA: Return ZegoSignalingPluginSendInvitationResult
deactivate PluginA
ServiceA --> AppA: Return send result (boolean)

@enduml
```

## Accept Invitation

```plantuml
@startuml
participant "Callee App" as AppB
participant "ZegoCallInvitationService" as ServiceB
participant "ZegoUIKitSignalingPlugin" as PluginB
participant "ZIM SDK" as ZIMB
participant "Server" as Server
participant "ZIM SDK" as ZIMA
participant "ZegoUIKitSignalingPlugin" as PluginA
participant "ZegoCallInvitationService" as ServiceA
participant "Caller App" as AppB

AppB -> ServiceB: accept(customData)
ServiceB -> PluginB: acceptInvitation(invitationID, extendedData)
activate PluginB
PluginB -> ZIMB: callAccept(invitationID, ZIMCallAcceptConfig)
activate ZIMB
ZIMB -> Server: Send accept request
activate Server
Server -> ZIMA: Push accept notification
activate ZIMA
ZIMA -> PluginA: Trigger onCallInvitationAccepted event
PluginA -> ServiceA: Trigger OutgoingInvitationAccepted event
ServiceA -> AppA: Trigger onOutgoingCallAccepted callback
Server --> ZIMB: Return accept result
deactivate Server
ZIMB --> PluginB: Return ZIMCallAcceptanceSentResult
deactivate ZIMB
PluginB --> ServiceB: Return ZegoSignalingPluginResponseInvitationResult
deactivate PluginB
ServiceB --> AppB: Return accept result (boolean)

@enduml
```

## Reject Invitation

```plantuml
@startuml
participant "Callee App" as AppB
participant "ZegoCallInvitationService" as ServiceB
participant "ZegoUIKitSignalingPlugin" as PluginB
participant "ZIM SDK" as ZIMB
participant "Server" as Server
participant "ZIM SDK" as ZIMA
participant "ZegoUIKitSignalingPlugin" as PluginA
participant "ZegoCallInvitationService" as ServiceA
participant "Caller App" as AppA

AppB -> ServiceB: reject(customData)
ServiceB -> PluginB: refuseInvitation(invitationID, extendedData)
activate PluginB
PluginB -> ZIMB: callReject(invitationID, ZIMCallRejectConfig)
activate ZIMB
ZIMB -> Server: Send reject request
activate Server
Server -> ZIMA: Push reject notification
activate ZIMA
ZIMA -> PluginA: Trigger onCallInvitationRejected event
PluginA -> ServiceA: Trigger onOutgoingInvitationRejected event
ServiceA -> AppA: Trigger onOutgoingCallRejectedCauseBusy/onOutgoingCallDeclined callback
Server --> ZIMB: Return reject result
deactivate Server
ZIMB --> PluginB: Return ZIMCallRejectionSentResult
deactivate ZIMB
PluginB --> ServiceB: Return ZegoSignalingPluginResponseInvitationResult
deactivate PluginB
ServiceB --> AppB: Return reject result (boolean)

@enduml
```

## Cancel Invitation

```plantuml
@startuml
participant "Caller App" as AppA
participant "ZegoCallInvitationService" as ServiceA
participant "ZegoUIKitSignalingPlugin" as PluginA
participant "ZIM SDK" as ZIMA
participant "Server" as Server
participant "ZIM SDK" as ZIMB
participant "ZegoUIKitSignalingPlugin" as PluginB
participant "ZegoCallInvitationService" as ServiceB
participant "Callee App" as AppB

AppA -> ServiceA: cancel(callees, customData)
ServiceA -> PluginA: cancelInvitation(invitationID, invitees, extendedData)
activate PluginA
PluginA -> ZIMA: callCancel(invitees, invitationID, ZIMCallCancelConfig)
activate ZIMA
ZIMA -> Server: Send cancel request
activate Server
Server -> ZIMB: Push cancel notification
activate ZIMB
ZIMB -> PluginB: Trigger onCallInvitationCancelled event
PluginB -> ServiceB: Trigger IncomingInvitationCancelled event
ServiceB -> AppB: Trigger onIncomingCallCanceled callback
Server --> ZIMA: Return cancel result
deactivate Server
ZIMA --> PluginA: Return ZIMCallCancelSentResult
deactivate ZIMA
PluginA --> ServiceA: Return ZegoSignalingPluginCancelInvitationResult
deactivate PluginA
ServiceA --> AppA: Return cancel result (boolean)

@enduml
```

## Timeout Handling

```plantuml
@startuml
participant "Caller App" as AppA
participant "ZegoCallInvitationService" as ServiceA
participant "ZegoUIKitSignalingPlugin" as PluginA
participant "ZIM SDK" as ZIMA
participant "Server" as Server
participant "ZIM SDK" as ZIMB
participant "ZegoUIKitSignalingPlugin" as PluginB
participant "ZegoCallInvitationService" as ServiceB
participant "Callee App" as AppB

... Wait for timeout ...

Server -> ZIMA: Timeout notification
activate ZIMA
ZIMA -> PluginA: Trigger onCallInviteesAnsweredTimeout event
PluginA -> ServiceA: Trigger onOutgoingInvitationTimeout event
ServiceA -> AppA: Trigger onOutgoingCallTimeout callback
deactivate ZIMA

Server -> ZIMB: Timeout notification
activate ZIMB
ZIMB -> PluginB: Trigger onCallInvitationTimeout event
PluginB -> ServiceB: Trigger onIncomingInvitationTimeout event
ServiceB -> AppB: Trigger onIncomingCallTimeout callback
deactivate ZIMB

@enduml
```

These sequence diagrams illustrate the detailed flows of various operations in the ZEGO Call Invitation system, including the complete API call chain from the application layer to the ZIM SDK.
