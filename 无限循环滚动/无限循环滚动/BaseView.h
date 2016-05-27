//
//  BaseView.h
//  无限循环滚动
//
//  Created by shan on 16/5/25.
//  Copyright © 2016年 shan. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Config : NSObject
@property (nonatomic,assign) NSInteger style;
//@property (nonatomic,assign) NSInteger dataCount;
@property (nonatomic,assign) CGFloat cellWidth;
@property (nonatomic,assign) CGFloat cellHeight;
@property (nonatomic,assign) CGFloat cellSpace;
@property (nonatomic,assign) CGFloat cellScale;
@property (nonatomic,assign) CGFloat angle;

@property (nonatomic,assign) CGFloat marginTop;
@property (nonatomic,assign) CGFloat marginBottom;
@property (nonatomic,assign) CGFloat marginLeft;
@property (nonatomic,assign) CGFloat marginRight;
@property (nonatomic,assign) CGFloat paddingTop;
@property (nonatomic,assign) CGFloat paddingBottom;
@end

@protocol CFCoverFlowViewDelegate <NSObject>
@optional
- (void)coverFlowViewDidScrollPageItemToIndex:(NSInteger)index;
- (void)coverFlowViewDidSelectPageItemAtIndex:(NSInteger)index;
@end


@interface BaseView : UIView<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic,strong) Config  *config;
@property (nonatomic, weak) id <CFCoverFlowViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame  config:(Config *)config;

@end


@interface CircleLayout : UICollectionViewLayout
@property (nonatomic,strong) Config  *config;
@end




