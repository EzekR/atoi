#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#include "../.symlinks/plugins/flutter_jpush/ios/Classes/FlutterJPushPlugin.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [self startupJPush:launchOptions appKey:@"3f7f5523e972c577860e6181" channel:@"developer-default" isProduction:true];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
