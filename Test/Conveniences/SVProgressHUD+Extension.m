//
//  SVProgressHUD+Extension.m
//  PocketDoctor
//
//  Created by 隋冬阳 on 2023/7/20.
//

#import "SVProgressHUD+Extension.h"

@implementation SVProgressHUD (Extension)

+ (void)showWithMask {
    [self setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [self show];
}

+ (void)dismissForMask {
    [self dismiss];
    [self setDefaultMaskType:SVProgressHUDMaskTypeNone];
}

@end
