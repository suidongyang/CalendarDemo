//
//  PDToast.m
//  PocketDoctor
//
//  Created by 隋冬阳 on 2023/5/24.
//

#import "PDToast.h"
#import <Toaster/Toaster-Swift.h>

@implementation PDToast

+ (void)load {
    ToastView.appearance.font = [UIFont systemFontOfSize:16];
    ToastView.appearance.bottomOffsetPortrait = kTabBarHeight + 20;
    ToastView.appearance.textInsets = UIEdgeInsetsMake(10, 14, 10, 14);
}

+ (void)showInfo:(NSString *)info {
    if ([info containsString: @"null"] || info.length < 2) return;
    Toast *toast = [[Toast alloc] initWithText:info delay:0 duration:1];
    [toast show];
}

@end
