//
//  PrefixHeader.h
//  Test
//
//  Created by 隋冬阳 on 2023/8/25.
//

#ifndef PrefixHeader_h
#define PrefixHeader_h

#define PDWeak(type)  __weak typeof(type) weak##type = type;
#define PDStrong(type)  __strong typeof(type) type = weak##type;

#define kIs_iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kIs_iPhoneX (kScreenWidth >= 375.0f && kScreenHeight >= 812.0f && kIs_iphone)

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kStatusBarHeight (CGFloat)(kIs_iPhoneX ? 44.0 : 20.0)
#define kNavBarHeight (44)
#define kNavBarAndStatusBarHeight (CGFloat)(kIs_iPhoneX ? 88.0 : 64.0)
#define kTabBarHeight (CGFloat)(kIs_iPhoneX ? 49.0 + 34.0 : 49.0)
#define kTopBarSafeHeight (CGFloat)(kIs_iPhoneX ? 44.0 : 0)
#define kBottomSafeHeight (CGFloat)(kIs_iPhoneX ? 34.0 : 0)
#define kTopBarDifHeight (CGFloat)(kIs_iPhoneX ? 24.0 : 0)
#define kNavAndTabHeight (kNavBarAndStatusBarHeight + kTabBarHeight)

#endif /* PrefixHeader_h */
