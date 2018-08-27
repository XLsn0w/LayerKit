//
//  AppDelegate.m
//  LayerKit
//
//  Created by HL on 2018/8/8.
//  Copyright © 2018年 XL. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 创建标签的ICON图标。
    UIApplicationShortcutIcon *icon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeAdd];
    // 创建一个标签，并配置相关属性。
    UIApplicationShortcutItem *item = [[UIApplicationShortcutItem alloc] initWithType:@"two" localizedTitle:@"么么哒" localizedSubtitle:@"爱你呦" icon:icon userInfo:nil];
    // 将标签添加进Application的shortcutItems中。
    [UIApplication sharedApplication].shortcutItems = @[item];

    
    return YES;
}

// 程序在后台运行，或者从死亡被激活，从3d进来的页面
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    if ([shortcutItem.localizedTitle isEqualToString:@"点我"]) {
        self.window.rootViewController.view.backgroundColor = [UIColor yellowColor];
    } else if ([shortcutItem.localizedTitle isEqualToString:@"么么哒"]) {
        self.window.rootViewController.view.backgroundColor = [UIColor redColor];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
