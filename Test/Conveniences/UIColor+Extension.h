//
//  UIColor+Extension.h
//  PocketDoctor
//
//  Created by 隋冬阳 on 2023/4/27.
//

#import <UIKit/UIKit.h>

@interface UIColor (Extension)

+ (UIColor *)colorWithHexString:(NSString *)hexString;

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;

+ (NSString *)randomHexColorWithMaxBrightness:(CGFloat)maxBrightness;

// 将16进制颜色字符串转换为对应的 RGB 值
+ (UIColor *)colorFromHexString:(NSString *)hexString;

// 计算颜色的互补色
+ (UIColor *)complementaryColorForColor:(UIColor *)color;

// 获取互补色的16进制颜色字符串表示
+ (NSString *)hexStringForColor:(UIColor *)color;

// 计算渐变色
+ (NSString *)interpolateColorFromColor:(NSString *)fromColor
                                toColor:(NSString *)toColor
                           withFraction:(CGFloat)fraction;


@end
