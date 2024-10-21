//
//  ViewController.m
//  Test
//
//  Created by 隋冬阳 on 2023/8/24.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import <LTMorphingLabel/LTMorphingLabel-Swift.h>
#import "UIColor+Extension.h"
#import "UIView+Extension.h"
#import "Test-Swift.h"

#define kColumnCount 7 
#define kRowCount 15
#define kItemWidth (kScreenWidth / kColumnCount)
#define kItemHeight (kScreenHeight / kRowCount)
#define kScaleFactor 0.7

@interface ViewController ()

@property (nonatomic, strong) UIView *gridView;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *touchIndics;

@property (nonatomic, strong) NSMutableArray *pointQueue;
@property (nonatomic, assign) CGFloat xRadius;
@property (nonatomic, assign) CGFloat yRadius;

@property (nonatomic, strong) Theme *theme;

@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, assign) CGPoint dateTagRange;

@property (nonatomic, assign) BOOL didShowIndicator;
@property (nonatomic, strong) CalendarButton *selectedButton;

@property (nonatomic, strong) dispatch_queue_t infoQueue;
@property (nonatomic, strong) dispatch_block_t infoTask;
@property (nonatomic, assign) BOOL didStopPrint;

@property (nonatomic, strong) AudioTool *audioTool;
@property (nonatomic, assign) NSInteger touchIndex;

@property (nonatomic, strong) SettingsController *settings;

@end


@implementation ViewController


#pragma mark - Conveniences

void animate(void(^action)(void)) {
    [UIView animateWithActions:^{
        if (action) action();
    } completion:nil];
}

void delay(CGFloat seconds, void(^action)(void)) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (action) action();
    });
}

void async_main(void(^action)(void)) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (action) action();
    });
}

void scale(CalendarButton *button, CGFloat factor) {
    if (factor != 0) {
        button.layer.affineTransform = CGAffineTransformMakeScale(factor, factor);
        if (button.borderWidth == 0) {
            animate(^{ button.layer.borderWidth = 1; });
        }
    }else {
        button.layer.affineTransform = CGAffineTransformIdentity;
        if (button.borderWidth == 0) {
            delay(0.2, ^{
                animate(^{ button.layer.borderWidth = 0; });
            });
        }
    }
}

static ViewController *_self;

CalendarButton *square(int index) {
    if (index >= _self.gridView.subviews.count) {
        return nil;
    }
    CalendarButton *button = [_self.gridView viewWithTag:index];
    if ([button isKindOfClass:CalendarButton.class]) {
        return button;
    }
    return _self.gridView.subviews.firstObject;
}


#pragma mark - UI

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _self = self;
    self.touchIndics = [NSMutableArray array];
    self.pointQueue = [NSMutableArray array];
    
    self.calendar = [NSCalendar currentCalendar];
    self.currentDate = [NSDate date];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    
    self.infoQueue = dispatch_queue_create("sdy.print.queue", NULL);
    
    self.settings = [[SettingsController alloc] init];
    self.theme = self.settings.themes[self.settings.themeIndex];
    self.audioTool = [[AudioTool alloc] initWithInstrumentIndex:self.settings.instrumentIndex];
    
    [self createGridView];
    
    [self updateCurrentMonth];
    for (CalendarButton *button in self.gridView.subviews) {
        button.morphingEnabled = YES;
    }
    delay(0.1, ^{
        [self showIndicator];
    });
    
//    [Networking getWeather:@"110000" success:^(NSString *weatherInfo) {
//
//        NSString *text = [NSString stringWithFormat:@"70;delay=0.5;image=cloud.sun.fill;text=%@", weatherInfo];
//        [self displayInfo:text];
//
//    } fail:^(NSString * err) { }];
}

- (void)createGridView {
    
    self.gridView = [[UIView alloc] init];
    
    [self.view addSubview:self.gridView];
    [self.gridView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    for (int i = 0; i < kRowCount * kColumnCount; i++) {
        
        CGFloat x = i % kColumnCount * kItemWidth;
        CGFloat y = i / kColumnCount * kItemHeight;
        
        CalendarButton *button = [[CalendarButton alloc] init];
        button.tag = i;
        button.frame = CGRectMake(x, y, kItemWidth, kItemHeight);
        [self updateColorForButton:button];
        
        if (i >= 9 && i <= 11) {
            button.style = ButtonStyleMonth;
        }else if (i > 13 && i < 21) {
            button.style = ButtonStyleWeekday;
        }else if (i >= 21 && i <= 62) {
            button.style = ButtonStyleDate;
        }else {
            button.style = ButtonStyleText;
            if (i == 7) {
                button.image = @"quote.opening";
            }else if (i == 8) {
                button.image = @"arrow.turn.up.left";
                button.tintColor = [UIColor colorWithWhite:1 alpha:0.9];
            }else if (i == 12) {
                button.image = @"arrow.turn.up.right";
                button.tintColor = [UIColor colorWithWhite:1 alpha:0.9];
            }else if (i == 13) {
                button.image = @"hexagon.fill";
            }else if (i >= 98) {
                /*
                 button.image = @"water.waves";
                 if (i == 99 || i == 101 || i == 103) {
                     button.image = @"fish.fill";
                 }
                 button.tintColor = [UIColor colorWithWhite:1 alpha:0.2];*/
            }
        }
        // touchDown
        [button addTarget:self action:@selector(touchDownAction:) forControlEvents:UIControlEventTouchDown];
        // touchCancel
        [button addTarget:self action:@selector(touchCancelAction:) forControlEvents:UIControlEventTouchCancel];
        // touchUpInside
        [button addTarget:self action:@selector(touchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
        // longPress
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        [button addGestureRecognizer:gesture];
        
        [self.gridView addSubview:button];
    }
    
    for (int i = 9; i <= 11; i++) {
        UIButton *button = square(i);
        [self.gridView bringSubviewToFront: button];
    }
    
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self.gridView addGestureRecognizer:gesture];
}


#pragma mark - 更新

- (void)showIndicator {
    self.didShowIndicator = !self.didShowIndicator;
    for (int i = 21; i <= 62; i++) {
        [square(i) showIndicator:self.didShowIndicator];
    }
}

- (void)showTodayInfo { }

- (void)showInfoWithDate:(NSDate *)date {
    
    NSArray *events = @[@"白班", @"夜班", @"休息", @"休息"];
    NSArray *symbols = @[@"sun.max.fill", @"moon.fill", @"cup.and.saucer.fill", @"handbag.fill"];
    NSInteger index = [self eventIndexForDate:date];
    
    NSString *text = [NSString stringWithFormat:@"63;delay=0.5;image=%@;sound=%ld;text=%@", symbols[index], index, events[index]];
    
    [self clearInfo];
    [self displayInfo:text];
}

- (NSInteger)eventIndexForDate:(NSDate *)date {
    NSDate *baseDate = self.settings.firstDayOfSchedule;
    NSInteger delta = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:baseDate toDate:date options:0].day;
    NSInteger index = delta >= 0 ? delta % 4 : ((delta % 4 + 4) % 4);
    return index;
}

- (void)clearInfo {
    self.didStopPrint = YES;
    for (int i = 63; i <= 97; i++) {
        CalendarButton *button = square(i);
        button.morphingEnabled = NO;
        button.image = nil;
        button.text = nil;
        delay(0.25, ^{
            button.morphingEnabled = YES;
        });
    }
}

- (void)displayInfo:(NSString *)info {
    
    if (self.infoTask) {
        // 结束尚未执行的任务，尽量不阻塞队列
        dispatch_block_cancel(self.infoTask);
    }
    dispatch_block_t task = ^{
        self.didStopPrint = NO; // 需要放在block里，确保标志位能在上一个任务中发挥作用
        NSArray *kvs = [info componentsSeparatedByString:@";"];
        
        __block int index = [kvs.firstObject intValue];
        __block int startIndex = index;
        __block int soundIndex = -1;
        for (int i = 1; i < kvs.count; i++) {
            if (self.didStopPrint) break;
            
            NSArray<NSString *> *kv = [kvs[i] componentsSeparatedByString:@"="];
            NSString *key = kv.firstObject;
            NSString *obj = kv.lastObject;
            
            if ([key isEqualToString:@"image"]) {
                async_main(^{
                    if (self.didStopPrint) return;
                    CalendarButton *button = square(index);
                    button.image = obj;
                    button.tintColor = [UIColor colorWithWhite:1 alpha:0.9];
                    index++;
                });
            }else if ([key isEqualToString:@"delay"]) {
                CGFloat delaySeconds = [obj floatValue];
                usleep(delaySeconds * 1000 * 1000);
                if (self.didStopPrint) break;
            }else if ([key isEqualToString:@"text"]) {
                if (obj.length > 0) {
                    NSMutableArray<NSString *> *words = [NSMutableArray array];
                    for (int i = 0; i < obj.length; i++) {
                        [words addObject:[obj substringWithRange:NSMakeRange(i, 1)]];
                    }
                    for (NSString *word in words) {
                        if ([@[@"，", @"。", @"！", @"？", @"~"] containsObject:word]) {
                            async_main(^{
                                square(index).text = word;
                                index++;
                            });
                        }else {
                            async_main(^{
                                square(index).text = word;
                                // 播放随机音符
                                if (soundIndex == -1) {
                                    [self.audioTool play:[self randomSound]];
                                }
                                index++;
                            });
                        }
                        usleep(0.2 * 1000 * 1000);
                        if (self.didStopPrint) break;
                    }
                }
            }else if ([key isEqualToString:@"nextline"]) {
                startIndex += 7;
                index = startIndex;
            }else if ([key isEqualToString:@"sound"]) {
                soundIndex = [obj intValue];
                [self.audioTool playScheduleEventSound:soundIndex];
            }
        }
    };
    
    self.infoTask = dispatch_block_create(0, task);
    dispatch_async(self.infoQueue, self.infoTask);
}


#pragma mark - 点击事件

- (void)touchDownAction:(CalendarButton *)sender {
    
    animate(^{ scale(sender, kScaleFactor); });
    NSLog(@"index: %ld", sender.tag);
    if (sender.tag != 7 && sender.tag != 8 && sender.tag != 12 && sender.tag != 13) {
        [self.audioTool play:sender.tag + 11];
    }else {
        [self impactFeedback:UIImpactFeedbackStyleLight];
    }
    self.touchIndex = sender.tag;
}

- (void)touchCancelAction:(UIButton *)sender {
    animate(^{ scale((CalendarButton *)sender, 0); });
}

- (void)touchUpInsideAction:(CalendarButton *)sender {
    self.touchIndex = -1;
    
    if (sender.tag >= self.dateTagRange.x && sender.tag <= self.dateTagRange.y) {
        
        if ([self date:sender.date equalTo:[NSDate date]]) {
            if (self.selectedButton && ![self.selectedButton isEqual:sender]) {
                animate(^{ self.selectedButton.borderWidth = 0; });
            }
            animate(^{ sender.layer.borderColor = [UIColor whiteColor].CGColor; });
            self.selectedButton = sender;
            //[self showTodayInfo];
            [self showInfoWithDate:sender.date];
        }else {
            if (self.selectedButton) {
                if (![self date:self.selectedButton.date equalTo:[NSDate date]]) {
                    animate(^{ self.selectedButton.borderWidth = 0; });
                }else {
                    animate(^{ self.selectedButton.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.3].CGColor; });
                }
            }
            animate(^{ sender.borderWidth = 1; });
            self.selectedButton = sender;
            [self showInfoWithDate:sender.date];
        }
        animate(^{ scale(sender, 0); });
        
        return;
        
    }else if (sender.style == ButtonStyleAction) {
        
        animate(^{ scale(sender, 0); });
        if (sender.tag == 7) {
            [self showIndicator];
        }else if (sender.tag == 8) {
            [self previousMonth];
        }else if (sender.tag == 12) {
            [self nextMonth];
        }else if (sender.tag == 13) {
            [self presentSettings];
        }
        return;
    }
    animate(^{
        scale(sender, 0);
    });
}


#pragma mark - 手势事件

- (void)longPressAction:(UILongPressGestureRecognizer *)gesture {
    
    if (gesture.state != UIGestureRecognizerStateBegan) {
        return;
    }
    [self impactFeedback:UIImpactFeedbackStyleMedium];
    
    animate(^{ scale((CalendarButton *)gesture.view, 0); });
    
    int index = (int)gesture.view.tag;
    CGPoint touchPoint = CGPointMake(index % kColumnCount, index / kColumnCount);
    [self.pointQueue addObject:@(index)];
    
    [self animateWithPoint:touchPoint scaleFactor:kScaleFactor];
}

- (void)animateWithPoint:(CGPoint)point scaleFactor:(CGFloat)scaleFactor {
        
    NSMutableArray *nextLevelPoints = [NSMutableArray array];
    
    while (self.pointQueue.count != 0) {
        // 出队
        int index = [self.pointQueue.firstObject intValue];
        [self.pointQueue removeObjectAtIndex:0];
        
        int x = index % kColumnCount;
        int y = index / kColumnCount;
        
        for (int xdis = -1; xdis <= 1; xdis++) {
            for (int ydis = -1; ydis <= 1; ydis++) {
                int nearbyX = x + xdis;
                int nearbyY = y + ydis;
                if (nearbyX < 0 || nearbyX >= kColumnCount || nearbyY < 0 || nearbyY >= kRowCount) {
                    continue;
                }
                NSInteger nearbyIndex = nearbyY * kColumnCount + nearbyX;
                if (nearbyIndex == index || nearbyIndex < 0 || nearbyIndex >= self.gridView.subviews.count) {
                    continue;
                }
                // 合法的点来到这里
                if (abs(nearbyX - (int)point.x) > self.xRadius ||
                    abs(nearbyY - (int)point.y) > self.yRadius) {
                    if (![nextLevelPoints containsObject:@(nearbyIndex)]) {
                        [nextLevelPoints addObject:@(nearbyIndex)];
                    }
                }
            }
        }
        // 动画
        CalendarButton *theSquare = square(index);
        animate(^{
            scale(theSquare, scaleFactor);
            [self updateColorForButton:theSquare];
        });
        delay(0.2, ^{
            animate(^{ scale(theSquare, 0); });
        });
    }
    
    if (nextLevelPoints.count > 0) {
        // 子节点入队
        [self.pointQueue addObjectsFromArray:nextLevelPoints];
        self.xRadius += 1;
        self.yRadius += 1;
        // 处理下一层节点
        delay(0.1, ^{
            [self animateWithPoint:point scaleFactor:scaleFactor + 0.01];
            //[self.audioTool play:[self randomSound]];
        });
    }else {
        self.xRadius = 0; self.yRadius = 0;
    }
}

- (void)panGestureAction:(UIPanGestureRecognizer *)gesture {
    
    CGPoint location = [gesture locationInView:gesture.view];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            
            int x = (int)(location.x / kItemWidth);
            int y = (int)(location.y / kItemHeight);
            NSInteger index = y * kColumnCount + x;
            
            if (index != self.touchIndex) {
                [self.audioTool play:index + 11];
                self.touchIndex = index;
            }
            
            if (self.touchIndics.count == 0 ||
                index != [self.touchIndics.lastObject integerValue]) {
                
                if (self.touchIndics.count != 0) {
                    NSInteger lastIndex = [self.touchIndics.lastObject integerValue];
                    CalendarButton *theSquare = square((int)lastIndex);
                    animate(^{
                        scale(theSquare, 0);
                    });
                }
                [self.touchIndics addObject:@(index)];
                CalendarButton *theSquare = square((int)index);
                animate(^{
                    scale(theSquare, kScaleFactor);
                });
            }
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            int lastIndex = [self.touchIndics.lastObject intValue];
            CalendarButton *theSquare = square(lastIndex);
            animate(^{
                scale(theSquare, 0);
            });
            [self.touchIndics removeAllObjects];
            break;
        }
        default:
            break;
    }
}


#pragma mark - 日期相关

- (void)updateCurrentMonth {
        
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self.currentDate];
    components.day = 1;
    
    NSDate *firstDayOfMonth = [self.calendar dateFromComponents:components];
    
    NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekday | NSCalendarUnitDay fromDate:firstDayOfMonth];
    
    NSRange daysRange = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self.currentDate];
    
    NSInteger weekday = dateComponents.weekday;
    
    NSInteger firstButtonOffset = weekday == 1 ? 6 : (weekday - 2);
    
    [self clearInfo];
    
    // 隐藏当前月日期范围外的按钮的内容
    CGPoint newRange = CGPointMake(1 + 20 + firstButtonOffset, daysRange.length + 20 + firstButtonOffset);
    if (!CGPointEqualToPoint(self.dateTagRange, CGPointZero)) {
        if (self.dateTagRange.x < newRange.x) {
            for (int i = self.dateTagRange.x; i < newRange.x; i++) {
                [square(i) clear];
            }
        }
        if (self.dateTagRange.y > newRange.y) {
            for (int i = newRange.y + 1; i <= self.dateTagRange.y; i++) {
                [square(i) clear];
            }
        }
    }
    self.dateTagRange = newRange;
    
    // 更新日期和小图标
    NSDate *today = [NSDate date];
    for (NSInteger day = 1; day <= daysRange.length; day++) {
        
        dateComponents.day = day;
        NSDate *date = [self.calendar dateFromComponents:dateComponents];
        
        NSInteger index = [self eventIndexForDate:date];
        
        CalendarButton *button = square((int)(day + 20 + firstButtonOffset));
        button.text = @(day).stringValue;
        button.indicatorIndex = index;
        button.date = date;
        
        // 今天
        if ([self date:date equalTo:today]) {
            self.selectedButton = button;
            animate(^{
                button.borderWidth = 2;
                button.layer.borderColor = [UIColor whiteColor].CGColor;
            });
            //[self showTodayInfo];
            [self showInfoWithDate:date];
        }else {
            if (button.layer.borderWidth != 0) {
                animate(^{ button.borderWidth = 0; });
            }
        }
    }
    
    // 更新月份
    self.dateFormatter.dateFormat = @"yyyy.MM";
    NSString *dateString = [self.dateFormatter stringFromDate:self.currentDate];
    NSArray<NSString *> *comps = [dateString componentsSeparatedByString:@"."];
    NSString *yearPrefix = [comps[0] substringToIndex:2];
    NSString *yearSuffix = [comps[0] substringFromIndex:2];
    
    NSArray *strings = @[yearPrefix, yearSuffix, comps[1]];
    for (int i = 9; i <= 11; i++) {
        square(i).text = strings[i - 9];
    }
}

- (void)previousMonth {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = -1;
    self.currentDate = [self.calendar dateByAddingComponents:components toDate:self.currentDate options:0];
    [self updateCurrentMonth];
}

- (void)nextMonth {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = 1;
    self.currentDate = [self.calendar dateByAddingComponents:components toDate:self.currentDate options:0];
    [self updateCurrentMonth];
}

- (BOOL)date:(NSDate *)date equalTo:(NSDate *)date2 {
    self.dateFormatter.dateFormat = @"yyyyMMdd";
    return [[self.dateFormatter stringFromDate:date] isEqualToString:[self.dateFormatter stringFromDate:date2]];
}


#pragma mark - 设置的回调

- (void)updateTheme:(Theme *)theme {

    self.theme = theme;
    [self impactFeedback:UIImpactFeedbackStyleMedium];

    int index = 49 + arc4random_uniform(7);
    CGPoint touchPoint = CGPointMake(index % kColumnCount, index / kColumnCount);
    [self.pointQueue addObject:@(index)];

    [self animateWithPoint:touchPoint scaleFactor:kScaleFactor];
}

- (void)updateInstrument:(NSInteger)index {
    [self.audioTool loadInstrument:index];
}

- (void)updateSchedule {
    [self updateCurrentMonth];
}


#pragma mark - Others

- (void)presentSettings {
    self.settings = [[SettingsController alloc] init];
    self.settings.calendar = self;
    [self presentViewController:self.settings animated:YES completion:nil];
}

- (void)updateColorForButton:(CalendarButton *)button {
    
    CGFloat factor = (int)(button.tag / kColumnCount) / (float)kRowCount;
    
    NSString *color = [UIColor interpolateColorFromColor:self.theme.color toColor:self.theme.color2 withFraction:factor];
    
    CGFloat alpha = 1.0;
    do {
        alpha = arc4random_uniform(1000) / 1000.0;
    } while (alpha < 0.9);

    [button applyColor:color alpha:alpha];
}

- (void)impactFeedback:(UIImpactFeedbackStyle)style {
    UIImpactFeedbackGenerator *g = [[UIImpactFeedbackGenerator alloc] initWithStyle:style];
    [g impactOccurred];
}

- (NSInteger)randomSound {
    NSInteger index = 0;
    do {
        index = arc4random_uniform(100);
    }while (index < 74 || index > 101); // (index < 63 || index > 97);
    return index;
}

- (NSString *)randomColor {
    NSString *hex = [UIColor randomHexColorWithMaxBrightness:0.7];
    NSLog(@"randomColor: %@", hex);
    return hex;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures {
    return UIRectEdgeLeft | UIRectEdgeRight;
}


@end
