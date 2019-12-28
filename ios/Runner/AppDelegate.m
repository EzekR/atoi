#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#include "../.symlinks/plugins/flutter_jpush/ios/Classes/FlutterJPushPlugin.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [self startupJPush:launchOptions appKey:@"55de4e9a04eb39338afc99db" channel:@"developer-default" isProduction:true];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
