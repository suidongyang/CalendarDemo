//
//  ViewController.h
//  Test
//
//  Created by 隋冬阳 on 2023/8/24.
//

#import <UIKit/UIKit.h>

@class AudioTool, Theme;

@interface ViewController : UIViewController

@property (nonatomic, strong, readonly) AudioTool *audioTool;

- (void)updateTheme:(Theme *)theme;
- (void)updateInstrument:(NSInteger)index;
- (void)updateSchedule;

@end

