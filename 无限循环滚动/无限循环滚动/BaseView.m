//
//  BaseView.m
//  无限循环滚动
//
//  Created by shan on 16/5/25.
//  Copyright © 2016年 shan. All rights reserved.
//

#import "BaseView.h"
#import "ShowImageCell.h"

#define KCellIdentifier @"identifier"
#define KWidth self.frame.size.width // collectionView 的宽度 和self的宽度相等

@implementation Config : NSObject
@end

/**
 * 循环滚动实现思想   假如有 0、1、2、3、4 条数据，把后两条数据和前两条数据 复制两份 ，
 * 即实际的数据是：3、4、0、1、2、3、4、0、1
 */
@interface BaseView(){
    CGFloat startOffsetX; //
    NSArray *originDataArray;
    BOOL  isAutoAnimation;
    CGFloat animationDuration;
    NSInteger currentPage;
}
@end

@implementation BaseView

- (id)init
{
    self = [super init];
    if (self) {
        return self;
    }
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame  config:(Config *)config
{
    self = [super initWithFrame:frame];
    if (self) {
        isAutoAnimation = YES;
        animationDuration = 3;
        
        self.config = config;
        CircleLayout *layout =  [[CircleLayout alloc] init];
        layout.config = config;
        
        if((self.config.cellSpace + self.config.cellWidth) * 3 < self.frame.size.width){
            self.config.cellWidth = self.frame.size.width/3 - self.config.cellSpace +1;
        }
        
        startOffsetX = ((self.config.cellSpace + self.config.cellWidth)*2 + self.config.cellWidth/2) - KWidth/2;
        float height = self.config.cellHeight + self.config.paddingTop + self.config.paddingBottom;
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 50.0f, KWidth, height)
                                                 collectionViewLayout:layout];
        [self.collectionView registerClass:[ShowImageCell class] forCellWithReuseIdentifier:KCellIdentifier];
        self.collectionView.backgroundColor = [UIColor whiteColor];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self.collectionView setContentOffset:CGPointMake(startOffsetX, 0.0)];
        [self addSubview:self.collectionView];
        return self;
    }
    return nil;
}

- (void)setDataArray:(NSArray *)dataArray{
    originDataArray = dataArray;
    if (dataArray.count > 1) {
        NSMutableArray *marray = [NSMutableArray arrayWithArray:dataArray];
        //把后两条数据插到头两个
        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
        [marray insertObjects:[dataArray subarrayWithRange:NSMakeRange(dataArray.count - 2, 2)] atIndexes:set];
        
        //把开始的两条数据插到最后两个
        NSIndexSet *set1 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(marray.count, 2)];
        [marray insertObjects:[dataArray subarrayWithRange:NSMakeRange(0, 2)] atIndexes:set1];
        _dataArray = marray;
    }
    else{
        _dataArray = dataArray;
    }
    [self.collectionView reloadData];
    [self startAutoAnimating];
}

#pragma mark - UICollectionViewDelegate
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ShowImageCell *cell = (ShowImageCell *)[cView dequeueReusableCellWithReuseIdentifier:KCellIdentifier
                                                                            forIndexPath:indexPath];
    if (!cell) {
        NSLog(@"不可能！！！");
        return nil;
    }
    NSString *imageName = self.dataArray[indexPath.item];
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.titleLabel.text = imageName;
    cell.tag = [originDataArray indexOfObject:imageName];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (self.delegate && [self.delegate respondsToSelector:@selector(coverFlowViewDidSelectPageItemAtIndex:)]) {
        [self.delegate  coverFlowViewDidSelectPageItemAtIndex:cell.tag];
    }
}

- (void)startAutoAnimating {
    if (isAutoAnimation) {
        [self performSelector:@selector(coverFlowViewAnimation) withObject:nil afterDelay:animationDuration];
    }
    
}

- (void)stopAutoAnimating {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(coverFlowViewAnimation) object:nil];
}

- (void)coverFlowViewAnimation{
    [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x + (self.config.cellWidth + self.config.cellSpace)  , 0) animated:YES];
    currentPage++;
    [self startAutoAnimating];
}


#pragma mark - UIScrollVIewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self stopAutoAnimating];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x<self.config.cellWidth/2) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x + (self.config.cellWidth + self.config.cellSpace) * ( self.dataArray.count - 4), 0)];
        currentPage = originDataArray.count - 1;
    }
    else if (scrollView.contentOffset.x >((self.config.cellWidth + self.config.cellSpace) * (self.dataArray.count - 1) + self.config.cellWidth /2 - KWidth)) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x - (self.config.cellWidth + self.config.cellSpace) * (self.dataArray.count - 4) , 0)];
        currentPage = 0;
    }
     [self.delegate coverFlowViewDidScrollPageItemToIndex:currentPage];
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (fabs(velocity.x) < 0.0001){// 手指按着屏幕慢慢滑动 没有加速度 结束后不会调用scrollViewDidEndDecelerating
        CGFloat x = scrollView.contentOffset.x - startOffsetX;
        NSInteger temp = lrintf(x) % lrintf(self.config.cellWidth  + self.config.cellSpace);
        NSInteger num = lrintf(x) / (self.config.cellWidth  + self.config.cellSpace);
        if (temp > (self.config.cellWidth  + self.config.cellSpace)/2) {
            num++;
        }
        NSLog(@"num:%ld",num%(self.dataArray.count - 4));
        [scrollView setContentOffset:CGPointMake(startOffsetX + num *(self.config.cellWidth  + self.config.cellSpace), 0) animated:YES];
        currentPage = num%(self.dataArray.count - 4);
        [self.delegate coverFlowViewDidScrollPageItemToIndex:currentPage];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat x = scrollView.contentOffset.x - startOffsetX;
    NSInteger temp = lrintf(x) % lrintf(self.config.cellWidth  + self.config.cellSpace);
    NSInteger num = lrintf(x) / (self.config.cellWidth  + self.config.cellSpace);
    if (temp > (self.config.cellWidth  + self.config.cellSpace)/2) {
        num++;
    }
    [scrollView setContentOffset:CGPointMake(startOffsetX + num *(self.config.cellWidth  + self.config.cellSpace), 0) animated:YES];
    currentPage = num%(self.dataArray.count - 4);
    [self.delegate coverFlowViewDidScrollPageItemToIndex:currentPage];
    [self startAutoAnimating];
}
@end


@implementation CircleLayout

-(CGSize)collectionViewContentSize
{
    float width = (self.config.cellWidth  + self.config.cellSpace) *[self.collectionView numberOfItemsInSection:0];
    float height= self.collectionView.frame.size.height;
    CGSize  size = CGSizeMake(width, height);
    return size;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}
#pragma mark - UICollectionViewLayout
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = CGRectMake((self.config.cellWidth+self.config.cellSpace) * indexPath.item, self.config.paddingTop, self.config.cellWidth, self.config.cellHeight);
    return attributes;
}
-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* attributes = [NSMutableArray array];
    for (NSInteger i=0 ; i < [self.collectionView numberOfItemsInSection:0 ]; i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
         [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    for (UICollectionViewLayoutAttributes* layoutAttributes in attributes) {
        if (CGRectIntersectsRect(layoutAttributes.frame, rect)) {
            CGFloat distance =CGRectGetMidX(visibleRect) - layoutAttributes.center.x;
            
            CATransform3D rotationTransform = CATransform3DIdentity;
            
            if (self.config.style == 1){
             //CGFloat scale = 1 - fabs(distance) /(self.config.cellSpace + self.config.cellWidth )/10;
             CGFloat   scale = self.config.cellScale + (1- self.config.cellScale) * (1 - fabs(distance) /(self.config.cellSpace + self.config.cellWidth ));
            rotationTransform = CATransform3DMakeScale(scale, scale, 1.0);
            }
            else if (self.config.style == 2){
                rotationTransform.m34 = -1.0f/200.0f;
                CGFloat angle = distance/(self.config.cellSpace + self.config.cellWidth );
                NSLog(@"angle:%f",angle);
                //rotationTransform = CATransform3DTranslate(rotationTransform,0.0f, 0.0f, (2 - (fabs(distance) /(self.config.cellSpace + self.config.cellWidth ))) * 20);
                rotationTransform = CATransform3DRotate(rotationTransform, angle * self.config.angle, 0.0f, 1.0f, 0.0f);
            }
             layoutAttributes.transform3D = rotationTransform ;
        }
    }
    
    return attributes;
}


@end