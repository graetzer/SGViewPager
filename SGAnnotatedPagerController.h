//
//  SGViewController.h
//  ViewPager
//
//  Created by Simon Grätzer on 30.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SGViewPagerController.h"

@interface SGAnnotatedPagerController : UIViewController <UIScrollViewDelegate> {
    BOOL pageControlIsChangingPage;
    NSUInteger _pageIndex;
}

@property (readonly, nonatomic) UIScrollView *titleScrollView;
@property (readonly, nonatomic) UIScrollView *scrollView;
@property (assign, nonatomic) NSUInteger pageIndex;

- (void)reloadPages;
- (void)addPage:(UIViewController *)controller;

@end
