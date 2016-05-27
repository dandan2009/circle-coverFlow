//
//  ShowImageCell.m
//  UICollectionViewDemo
//
//  Created by shan on 16/5/25.
//  Copyright © 2016年 shan. All rights reserved.
//

#import "ShowImageCell.h"

@implementation ShowImageCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.frame = self.contentView.bounds;
    _titleLabel.frame = CGRectMake(0.0f,0.0f , self.contentView.bounds.size.width, 44.0f);
}
@end
