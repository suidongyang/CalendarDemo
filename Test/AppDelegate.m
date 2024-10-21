//
//  AppDelegate.m
//  Test
//
//  Created by 隋冬阳 on 2023/8/24.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSDictionary *defaultValues = [NSDictionary dictionaryWithObjectsAndKeys: @1, @"instrumentIndex", @6, @"themeIndex", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[ViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    return YES;
}




@end
