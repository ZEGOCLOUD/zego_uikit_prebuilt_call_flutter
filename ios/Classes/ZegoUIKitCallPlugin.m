#import "ZegoUIKitCallPlugin.h"

@implementation ZegoUIKitCallPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"call_plugin"
            binaryMessenger:[registrar messenger]];
  ZegoUIKitCallPlugin* instance = [[ZegoUIKitCallPlugin alloc] init];
  instance.channel = channel;
  [registrar addMethodCallDelegate:instance channel:channel];
  
  // 请求通知权限
  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
  center.delegate = instance;
  
  // 请求所有通知权限
  UNAuthorizationOptions options = UNAuthorizationOptionAlert |
                                 UNAuthorizationOptionSound |
                                 UNAuthorizationOptionBadge |
                                 UNAuthorizationOptionProvisional;
  
  [center requestAuthorizationWithOptions:options
                        completionHandler:^(BOOL granted, NSError * _Nullable error) {
    if (granted) {
      NSLog(@"通知权限获取成功");
      
      // 获取当前通知设置
      [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        NSLog(@"通知设置: %@", settings);
      }];
    } else {
      NSLog(@"通知权限获取失败: %@", error);
    }
  }];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"activeAudioByCallKit" isEqualToString:call.method]) {
    [self activeAudioByCallKit];
    result(nil);
  } else if ([@"showNormalNotification" isEqualToString:call.method]) {
    [self showNormalNotification:call.arguments result:result];
  } else if ([@"dismissNotification" isEqualToString:call.method]) {
    [self dismissNotification:call.arguments result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)showNormalNotification:(NSDictionary *)arguments result:(FlutterResult)result {
    NSString *title = arguments[@"title"];
    NSString *content = arguments[@"content"];
    NSString *notificationId = arguments[@"id"];

    UNMutableNotificationContent *notificationContent = [[UNMutableNotificationContent alloc] init];
    notificationContent.title = title;
    notificationContent.body = content;
    notificationContent.sound = [UNNotificationSound defaultSound];
    
    // 设置通知为持久性
    notificationContent.interruptionLevel = UNNotificationInterruptionLevelTimeSensitive;
    
    // 添加自定义数据
    notificationContent.userInfo = @{
        @"notificationId": notificationId ?: @"",
    };
    
    // 创建通知请求
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:notificationId
                                                                      content:notificationContent
                                                                      trigger:nil];
    
    // 添加通知
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"添加通知失败: %@", error);
            result(@(NO));
        } else {
            NSLog(@"添加通知成功");
            result(@(YES));
        }
    }];
}

// 处理前台通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    // 在前台也显示通知
    completionHandler(UNNotificationPresentationOptionBanner | 
                     UNNotificationPresentationOptionSound | 
                     UNNotificationPresentationOptionBadge |
                     UNNotificationPresentationOptionList);
}

// 处理通知点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSString *notificationId = userInfo[@"notificationId"];
    
    // 通知Flutter层，使用与Android相同的方法名和参数格式
    NSDictionary *arguments = @{
        @"notification_id": @([notificationId integerValue])
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.channel invokeMethod:@"onNormalNotificationClicked" arguments:arguments];
    });
    
    completionHandler();
}

- (void)activeAudioByCallKit {
    NSLog(@"activeAudioByCallKit");
    NSError *error = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) {
        NSLog(@"activeAudioByCallKit error: %@", error.localizedDescription);
    }

    error = nil;
    [audioSession setMode:AVAudioSessionModeVoiceChat error:&error];
    if (error) {
        NSLog(@"activeAudioByCallKit error: %@", error.localizedDescription);
    }

    error = nil;
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    if (error) {
        NSLog(@"activeAudioByCallKit error: %@", error.localizedDescription);
    }
}

- (void)dismissNotification:(NSDictionary *)arguments result:(FlutterResult)result {
    NSString *notificationId = arguments[@"notification_id"];
    if (!notificationId) {
        result(@(NO));
        return;
    }
    
    [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:@[notificationId]];
    result(@(YES));
}

@end
