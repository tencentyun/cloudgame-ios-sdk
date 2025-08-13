//
//  TCGDemoGameListView.m
//  TCGDemo
//
//  Created by LyleYu on 2020/12/29.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TCGDemoGameListView.h"

@interface GameViewCell : UICollectionViewCell

+ (NSString *)reuseID;

@property (nonatomic, strong) UILabel *gameName;

@end

@implementation GameViewCell

+ (NSString *)reuseID {
    return @"TCGGameCollectionId";
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *lab = [[UILabel alloc] initWithFrame:self.bounds];
        lab.font = [UIFont systemFontOfSize:20];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.textColor = [UIColor blackColor];

        self.gameName = lab;
        [self addSubview:self.gameName];
    }

    return self;
}

@end

@interface TCGDemoGameListView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionViewLayout *mainLayout;
@property (nonatomic, strong) UICollectionView *mainView;
@property (nonatomic, strong) NSMutableArray<NSDictionary<NSString *, NSString *> *> *dataList;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UILabel *tipsView;
@end

@implementation TCGDemoGameListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.dataList = [NSMutableArray new];
        [self initLayout];
        [self initDataArray];
        [self initSubviews];
        [self.mainView reloadData];
    }
    return self;
}

- (void)initLayout {
    // UICollectionViewFlowLayout 可静态统一设置 cell 的布局信息，如横竖间隔、大小、头/尾部大小等
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 20;
    layout.minimumInteritemSpacing = 10;
    layout.headerReferenceSize = CGSizeMake(self.frame.size.width, 60);
    layout.sectionInset = UIEdgeInsetsMake(10, 5, 0, 5);

    self.mainLayout = layout;
}

- (void)initSubviews {
    self.backgroundColor = [UIColor whiteColor];
    UICollectionView *mainView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.mainLayout];
    mainView.backgroundColor = [UIColor whiteColor];
    // 3.注册collectionViewCell
    // 注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
    [mainView registerClass:[GameViewCell class] forCellWithReuseIdentifier:[GameViewCell reuseID]];

    // 注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
    //    [mainView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
    //    withReuseIdentifier:@"reusableView"];

    // 4.设置代理
    mainView.delegate = self;
    mainView.dataSource = self;

    self.mainView = mainView;
    [self addSubview:self.mainView];

    self.loadingView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.loadingView.center = self.center;
    self.loadingView.userInteractionEnabled = NO;
    self.loadingView.hidden = YES;
    self.loadingView.color = [UIColor blueColor];
    [self addSubview:self.loadingView];

    self.tipsView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    self.tipsView.center = CGPointMake(self.center.x, self.loadingView.frame.origin.y + self.loadingView.frame.size.height);
    self.tipsView.font = [UIFont systemFontOfSize:10];
    self.tipsView.textColor = [UIColor colorWithWhite:0.1 alpha:0.8];
    self.tipsView.textAlignment = NSTextAlignmentCenter;
    self.tipsView.hidden = YES;
    [self addSubview:self.tipsView];
}

- (void)initDataArray {
    //    [self.dataList addObject:@{@"name":@"刺客信条", @"gameid":@"game-0eowddk3", @"appid":@"1300679218"}];
    [self.dataList addObject:@{ @"name": @"火影4", @"gameid": @"game-zkp54i1l", @"appid": @"1300679218" }];
    //    [self.dataList addObject:@{@"name":@"古墓丽影", @"gameid":@"game-91fimckj", @"appid":@"1300679218"}];
    [self.dataList addObject:@{ @"name": @"英雄联盟", @"gameid": @"game-zmuayrmi", @"appid": @"1300679218" }];
    [self.dataList addObject:@{ @"name": @"测试日志上传", @"gameid": @"game-kvcwhp2s", @"appid": @"1300679218", @"setno": @"10000" }];
    [self.dataList addObject:@{ @"name": @"测试自动登录", @"gameid": @"game-gf1zbtcz", @"appid": @"1300679218", @"setno": @"12345" }];
    //    [self.dataList addObject:@{@"name":@"极品飞车17", @"gameid":@"game-bxia857l", @"appid":@"1300679218"}];
}

- (void)setTips:(NSString *)tips {
    self.tipsView.text = tips;
}

#pragma mark--- collectionViewDelegate ---
// 返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

// 每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GameViewCell *cell = (GameViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[GameViewCell reuseID] forIndexPath:indexPath];

    NSDictionary *data = self.dataList[indexPath.row];
    cell.gameName.text = [data objectForKey:@"name"];

    cell.backgroundColor = [UIColor clearColor];

    return cell;
}

// 设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(150, 40);
}

- (void)reset {
    [self.loadingView stopAnimating];
    self.loadingView.hidden = YES;
    self.tipsView.hidden = YES;
    self.mainView.hidden = NO;
}

#pragma mark--- UICollectionViewDelegate ---
// UICollectionView被选中的时候调用
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%ld", indexPath.row);
    NSDictionary *data = self.dataList[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(onGameItemClick:)]) {
        self.loadingView.hidden = NO;
        self.tipsView.hidden = NO;
        [self.loadingView startAnimating];
        self.mainView.hidden = YES;
        [self.delegate onGameItemClick:data];
    }
}

@end
