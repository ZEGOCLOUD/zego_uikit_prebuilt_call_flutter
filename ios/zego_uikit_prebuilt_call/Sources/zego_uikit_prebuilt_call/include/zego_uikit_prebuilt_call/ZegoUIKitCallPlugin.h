#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>
#import <UserNotifications/UserNotifications.h>

@interface ZegoUIKitCallPlugin : NSObject<FlutterPlugin, UNUserNotificationCenterDelegate>
@property (nonatomic, strong) FlutterMethodChannel *channel;
@end
