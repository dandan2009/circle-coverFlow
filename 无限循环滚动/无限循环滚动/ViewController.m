//
//  ViewController.m
//  无限循环滚动
//
//  Created by shan on 16/5/25.
//  Copyright © 2016年 shan. All rights reserved.
//

#import "ViewController.h"
#import "BaseView.h"

@interface ViewController ()<CFCoverFlowViewDelegate>
@property (nonatomic, strong) UIPageControl *pageControl;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(40, 400, 200, 50)];
    self.pageControl.backgroundColor = [UIColor redColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor greenColor];
    self.pageControl.numberOfPages = 7;
    [self.view addSubview:self.pageControl];
    
    
    NSLog(@"===%@",NSStringFromCGRect(self.view.frame));
   
  
    Config *config = [[Config alloc] init];
    config.cellSpace = 10;
    config.cellWidth = 90;
    config.cellHeight = 150;
    config.style = 1;
    config.cellScale = 0.8;
    config.angle = 0.8;
    config.paddingTop = 20;
    config.paddingBottom = 20;
    
    
    BaseView *view  = [[BaseView alloc] initWithFrame:CGRectMake(20, 40, self.view.frame.size.width - 40,250)  config:config];
    
    view.delegate =self;
    [self.view addSubview:view];
    
    
     NSArray *iamgeArray = @[@"0.jpg",@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"5.jpg",@"6.jpg"];
    view.dataArray = iamgeArray;
}
- (void)coverFlowViewDidScrollPageItemToIndex:(NSInteger)index
{
    self.pageControl.currentPage = index;
}

- (void)coverFlowViewDidSelectPageItemAtIndex:(NSInteger)index
{
    NSLog(@"选中了第%ld条数据",index);
}


@end
