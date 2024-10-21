//
//  UIColor+Extension.m
//  PocketDoctor
//
//  Created by 隋冬阳 on 2023/4/27.
//

#import "UIColor+Extension.h"

@implementation UIColor (Extension)

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    return [[self class] colorWithHexString:hexString alpha:1.0f];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha {
    
    //删除字符串中的空格
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

/** private method */
+ (NSString *)hexStringTransformFromThreeCharacters:(NSString *)hexString {
    
    if(hexString.length == 4) {
        hexString = [NSString stringWithFormat:@"#%@%@%@%@%@%@",
                     [hexString substringWithRange:NSMakeRange(1, 1)],[hexString substringWithRange:NSMakeRange(1, 1)],
                     [hexString substringWithRange:NSMakeRange(2, 1)],[hexString substringWithRange:NSMakeRange(2, 1)],
                     [hexString substringWithRange:NSMakeRange(3, 1)],[hexString substringWithRange:NSMakeRange(3, 1)]];
    }
    return hexString;
}
/** private method */
+ (unsigned)hexValueToUnsigned:(NSString *)hexValue {
    
    unsigned value = 0;
    NSScanner * hexValueScanner = [NSScanner scannerWithString:hexValue];
    [hexValueScanner scanHexInt:&value];
    return value;
}


+ (NSString *)randomHexColorWithMaxBrightness:(CGFloat)maxBrightness {
//    return [NSString stringWithFormat:@"#%@", [[NSString alloc] initWithFormat:@"%1x", arc4random_uniform(16777216)]];
    UIColor *randomColor = nil;
    CGFloat brightness = 0.0;

    do {
        CGFloat red = (CGFloat)arc4random_uniform(256) / 255.0;
        CGFloat green = (CGFloat)arc4random_uniform(256) / 255.0;
        CGFloat blue = (CGFloat)arc4random_uniform(256) / 255.0;

        randomColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];

        // Calculate brightness using HSP formula (perceived brightness)
        brightness = sqrt(0.299 * red * red + 0.587 * green * green + 0.114 * blue * blue);
    } while (brightness > maxBrightness);

    CGFloat red, green, blue, alpha;
    [randomColor getRed:&red green:&green blue:&blue alpha:&alpha];

    NSString *hexColorString = [NSString stringWithFormat:@"#%02X%02X%02X",
                                (int)(red * 255.0),
                                (int)(green * 255.0),
                                (int)(blue * 255.0)];

    return hexColorString;
}

// 将16进制颜色字符串转换为对应的 RGB 值
+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // 跳过 # 字符
    [scanner scanHexInt:&rgbValue];

    CGFloat red = ((rgbValue & 0xFF0000) >> 16) / 255.0;
    CGFloat green = ((rgbValue & 0x00FF00) >> 8) / 255.0;
    CGFloat blue = (rgbValue & 0x0000FF) / 255.0;

    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

// 计算颜色的互补色
+ (UIColor *)complementaryColorForColor:(UIColor *)color {
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];

    CGFloat complementaryRed = 1.0 - red;
    CGFloat complementaryGreen = 1.0 - green;
    CGFloat complementaryBlue = 1.0 - blue;

    return [UIColor colorWithRed:complementaryRed green:complementaryGreen blue:complementaryBlue alpha:1.0];
}

// 获取互补色的16进制颜色字符串表示
+ (NSString *)hexStringForColor:(UIColor *)color {
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];

    NSString *hexString = [NSString stringWithFormat:@"#%02X%02X%02X",
                           (int)(red * 255),
                           (int)(green * 255),
                           (int)(blue * 255)];

    return hexString;
}

+ (NSString *)interpolateColorFromColor:(NSString *)from toColor:(NSString *)to withFraction:(CGFloat)fraction {
    CGFloat red1, green1, blue1, alpha1;
    
    UIColor *fromColor = [UIColor colorFromHexString:from];
    UIColor *toColor = [UIColor colorFromHexString:to];
    
    [fromColor getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];

    CGFloat red2, green2, blue2, alpha2;
    [toColor getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];

    CGFloat interpolatedRed = (1 - fraction) * red1 + fraction * red2;
    CGFloat interpolatedGreen = (1 - fraction) * green1 + fraction * green2;
    CGFloat interpolatedBlue = (1 - fraction) * blue1 + fraction * blue2;
    CGFloat interpolatedAlpha = (1 - fraction) * alpha1 + fraction * alpha2;

    UIColor *color = [UIColor colorWithRed:interpolatedRed green:interpolatedGreen blue:interpolatedBlue alpha:interpolatedAlpha];
    return [self hexStringForColor:color];
}


@end
