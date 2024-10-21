//
//  PDRefreshHeader.m
//  PocketDoctor
//
//  Created by 隋冬阳 on 2023/6/30.
//

#import "PDRefreshHeader.h"

@implementation PDRefreshHeader

+ (instancetype)headerWithRefreshingBlock:(MJRefreshComponentAction)refreshingBlock {
    
    PDRefreshHeader *header = [super headerWithRefreshingBlock:refreshingBlock];
    
    [header setTitle:@"" forState:MJRefreshStateIdle];
    [header setTitle:@"" forState:MJRefreshStatePulling];
    [header setTitle:@"" forState:MJRefreshStateRefreshing];
    header.lastUpdatedTimeText = ^NSString * _Nonnull(NSDate * _Nullable lastUpdatedTime) {
        return @"";
    };
    return header;
}

@end


@interface MJRefreshNormalHeader(hook)

@end

@implementation MJRefreshNormalHeader(hook)

+ (void)load {
    Method origin = class_getInstanceMethod(self, @selector(placeSubviews));
    Method custom = class_getInstanceMethod(self, @selector(placeSubviews2));
    if (origin != NULL && custom != NULL) {
        method_exchangeImplementations(origin, custom);
    }
}

- (void)placeSubviews2 {
    [self placeSubviews2];
    if ([self isKindOfClass:[PDRefreshHeader class]]) {
        self.arrowView.centerX = self.width * 0.5;
        self.loadingView.centerX = self.width * 0.5;        
    }
}

@end


@implementation PDRefreshFooter

+ (instancetype)footerWithRefreshingBlock:(MJRefreshComponentAction)refreshingBlock
{
    PDRefreshFooter *footer = [super footerWithRefreshingBlock:refreshingBlock];
    [footer setTitle:@"" forState:MJRefreshStateNoMoreData];
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    return footer;
}

@end
