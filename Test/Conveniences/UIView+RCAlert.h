//
//  UIView+RCAlert.h
//  WLX
//
//  Created by SU on 2019/7/11.
//  Copyright © 2019 smn. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RCAlertContentView <NSObject>

@optional

- (void)willShow;
- (void)willhide;
- (void)didHide;

@end

@interface UIView (RCAlert)

- (void)present;
- (void)present2;
- (void)dismiss;

@end

