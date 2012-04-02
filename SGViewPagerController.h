//
//  SGViewPagerController.h
//  ViewPager
//
//  Created by Simon Grätzer on 30.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SGViewPagerController : UIViewController <UIScrollViewDelegate> {
    BOOL pageControlIsChangingPage;
}

@property (readonly, nonatomic) UIPageControl *pageControl;
@property (readonly, nonatomic) UIScrollView *scrollView;
@property (assign, nonatomic) NSUInteger pageIndex;

- (void)reloadPages;
- (void)addPage:(UIViewController *)controller;

@end
