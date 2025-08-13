//
//  TCGDemoGameListView.h
//  TCGDemo
//
//  Created by LyleYu on 2020/12/29.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TCGDemoGameListViewDelegate <NSObject>

- (void)onGameItemClick:(NSDictionary *)gameInfo;

@end

@interface TCGDemoGameListView : UIView

@property(nonatomic, weak) id<TCGDemoGameListViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)setTips:(NSString *)tips;
- (void)reset;

@end
