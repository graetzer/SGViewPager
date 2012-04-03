//
//  SGViewPagerController.m
//  ViewPager
//
//  Created by Simon Grätzer on 30.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SGViewPagerController.h"

#define PAGE_CONTROL_HEIGHT 20.0

@interface SGViewPagerController ()

@end

@implementation SGViewPagerController
@synthesize scrollView, pageControl;
@dynamic pageIndex;

- (void)loadView {
    [super loadView];
    
    CGRect controlFrame = CGRectMake(0, self.view.bounds.size.height - PAGE_CONTROL_HEIGHT,
                                     self.view.bounds.size.width, PAGE_CONTROL_HEIGHT);
    pageControl = [[UIPageControl alloc] initWithFrame:controlFrame];
    pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    self.pageControl.backgroundColor = [UIColor blackColor];
    [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    
    CGRect scrollFrame = CGRectMake(0, 0, self.view.bounds.size.width,
                                    self.view.bounds.size.height-PAGE_CONTROL_HEIGHT);
    scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
    scrollView.delegate = self;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [scrollView setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    [scrollView setCanCancelContentTouches:NO];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    scrollView.clipsToBounds = YES;
    scrollView.scrollEnabled = YES;
    scrollView.pagingEnabled = YES;
    
    [self.view addSubview:scrollView];
    [self.view addSubview:pageControl];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadPages];
	// Do any additional setup after loading the view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [self reloadPages];
}

- (void)addPage:(UIViewController *)controller; {
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:controller];
}

- (void)reloadPages {
    for (UIView *view in scrollView.subviews) {
        [view removeFromSuperview];
    }
    
	CGFloat cx = 0;
    NSUInteger count = self.childViewControllers.count;
	for (NSUInteger i = 0; i < count; i++) {
        UIView *view = [[self.childViewControllers objectAtIndex:i] view];
		CGRect rect = view.frame;
        
		rect.origin.x = cx;
		rect.origin.y = 0;
		view.frame = rect;
        
		[scrollView addSubview:view];
        
		cx += scrollView.frame.size.width;
	}
	
	self.pageControl.numberOfPages = count;
	[scrollView setContentSize:CGSizeMake(cx, [scrollView bounds].size.height)];
}

#pragma mark Properties
- (void)setPageIndex:(NSUInteger)index {
    pageControl.currentPage = index;
    /*
	 *	Change the scroll view
	 */
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * index;
    frame.origin.y = 0;
	
    [scrollView scrollRectToVisible:frame animated:NO];
    
	/*
	 *	When the animated scrolling finishings, scrollViewDidEndDecelerating will turn this off
	 */
    pageControlIsChangingPage = YES;
}

- (NSUInteger)pageIndex {
    return self.pageControl.currentPage;
}

#pragma mark -
#pragma mark UIScrollViewDelegate stuff
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    if (pageControlIsChangingPage) {
        return;
    }
    
	/*
	 *	We switch page at 50% across
	 */
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView 
{
    pageControlIsChangingPage = NO;
}

#pragma mark -
#pragma mark PageControl stuff
- (IBAction)changePage:(id)sender 
{
	/*
	 *	Change the scroll view
	 */
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * pageControl.currentPage;
    frame.origin.y = 0;
    
    [scrollView scrollRectToVisible:frame animated:YES];
    
	/*
	 *	When the animated scrolling finishings, scrollViewDidEndDecelerating will turn this off
	 */
    pageControlIsChangingPage = YES;
}

@end
