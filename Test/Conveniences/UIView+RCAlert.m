//
//  UIView+RCAlert.m
//  WLX
//
//  Created by SU on 2019/7/11.
//  Copyright © 2019 smn. All rights reserved.
//

#import "UIView+RCAlert.h"
#import <objc/runtime.h>
#import "UIView+Extension.h"
#import "PDCommonUtility.h"
#import "UIViewController+Extension.h"

float viewHeight(void) {
    if (@available(iOS 13.0, *)) {
        return [UIScreen mainScreen].bounds.size.height;
    }else {
        return [UIViewController current].view.bounds.size.height;
    }
}

float viewWidth(void) {
    if (@available(iOS 13.0, *)) {
        return [UIScreen mainScreen].bounds.size.width;
    }else {
        return [UIViewController current].view.bounds.size.width;
    }
}


@interface RCAlertContainer : UIView

@property (nonatomic, strong) UIView *background;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, assign) BOOL didKeyboardShow;
@property (nonatomic, assign) UIEdgeInsets safeInsets;
@property (nonatomic, assign) CGFloat inset;

- (instancetype)initWithContentView:(UIView *)contentView
                              inset:(CGFloat)inset
                       cornerRadius:(CGFloat)cornerRadius;

- (void)show;
- (void)hide;
- (void)destruct;

@end


@implementation RCAlertContainer

- (instancetype)initWithContentView:(UIView *)contentView
                              inset:(CGFloat)inset
                       cornerRadius:(CGFloat)cornerRadius {
    
    self = [super initWithFrame:CGRectMake(inset, viewHeight(), MIN( viewWidth(), viewHeight()) - inset * 2, contentView.height + kBottomSafeHeight)];
    self.center = CGPointMake(0.5 *  viewWidth(), self.center.y);
    self.inset = inset;

    contentView.frame = CGRectMake(0, 0, self.width, contentView.height);
    [self addSubview:contentView];
    
    UIView *safeAreaView = [[UIView alloc] initWithFrame:CGRectMake(self.inset, contentView.height, self.width, kBottomSafeHeight)];
    safeAreaView.backgroundColor = [UIColor whiteColor];
    [self addSubview:safeAreaView];
    
    self.background = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.background.backgroundColor = [UIColor blackColor];
    self.background.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [self.background addGestureRecognizer:tap];
    self.tap = tap;
    
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
    
    return self;
}

- (void)onKeyboardWillShow:(NSNotification *)note {
    self.didKeyboardShow = YES;
    CGSize keyboardSize = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [self animateWithActions:^{
        self.y = viewHeight() - self.height - self.inset - keyboardSize.height;
    }];
}

- (void)onKeyboardWillHide:(NSNotification *)note {
    self.didKeyboardShow = NO;
    [self animateWithActions:^{
        self.y = viewHeight() - self.height - self.inset;
    }];
}

- (void)show {
    
    [self observe:UIKeyboardWillShowNotification selector:@selector(onKeyboardWillShow:)];
    [self observe:UIKeyboardWillHideNotification selector:@selector(onKeyboardWillHide:)];
    
    if (@available(iOS 13.0, *)) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow addSubview:self.background];
        [keyWindow addSubview:self];
    }else {
        UIViewController *currentVC = [UIViewController current];
        [currentVC.view addSubview:self.background];
        [currentVC.view addSubview:self];
    }
    
    self.hidden = NO;
    self.background.hidden = NO;
    self.y = viewHeight();
    self.background.alpha = 0;
    
    [self animateWithActions:^{
        self.y = viewHeight() - self.height - self.inset;
        self.background.alpha = 0.2;
    }];
    
}

- (void)hide {
    
    if ([self.subviews.firstObject respondsToSelector:@selector(willhide)]) {
        [(UIView<RCAlertContentView> *)self.subviews.firstObject willhide];
    }
    
    if (self.didKeyboardShow) {
        [self endEditing:YES];
        return;
    }
    [self animateWithActions:^{
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(destruct)];
        self.y = viewHeight();
        self.background.alpha = 0;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self cancelObserve:UIKeyboardWillShowNotification];
        [self cancelObserve:UIKeyboardWillHideNotification];
        
        if ([self.subviews.firstObject respondsToSelector:@selector(didHide)]) {
            [(UIView<RCAlertContentView> *)self.subviews.firstObject didHide];
        }
    });
}

- (void)destruct {
    self.hidden = YES;
    self.background.hidden = YES;
    [self.background removeFromSuperview];
    [self removeFromSuperview];
}

- (void)animateWithActions:(void (^)(void))actions {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:7];
    if (actions) {
        actions();
    }
    [UIView commitAnimations];
}

- (BOOL)isiPhoneX {
    return [UIApplication sharedApplication].statusBarFrame.size.height >= 44;
}

- (UIEdgeInsets)safeInsets {
    BOOL isLandscape =  viewWidth() > viewHeight();
    UIEdgeInsets safeAeraInsets = UIEdgeInsetsZero;
    if ([self isiPhoneX] && isLandscape) {
        safeAeraInsets = UIEdgeInsetsMake(0, 44, 21, 34);
    }else if ([self isiPhoneX] && !isLandscape) {
        safeAeraInsets = UIEdgeInsetsMake(44, 0, 34, 0);
    }
    return safeAeraInsets;
}


@end


@implementation UIView (RCAlert)

const void *kAlertContainerKey = "kAlertContainerKey";

- (void)present {
    [self presentWithInset:0 cornerRadius:10];
}

- (void)present2 {
    [self presentWithInset:0 cornerRadius:20];
}

- (void)presentWithInset:(CGFloat)inset cornerRadius:(CGFloat)cornerRadius {
    if (self.superview) {
        return;
    }
    if ([self respondsToSelector:@selector(willShow)]) {
        [(UIView<RCAlertContentView> *)self willShow];
    }
    RCAlertContainer *alert = [[RCAlertContainer alloc] initWithContentView:self inset:inset cornerRadius:cornerRadius];
    objc_setAssociatedObject(self, kAlertContainerKey, alert, OBJC_ASSOCIATION_ASSIGN);
    [alert show];
}

- (void)dismiss {
    
    RCAlertContainer *alert = objc_getAssociatedObject(self, kAlertContainerKey);
    [alert hide];
}


@end
