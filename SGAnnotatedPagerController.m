//
//  SGViewController.m
//  ViewPager
//
//  Created by Simon Grätzer on 30.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SGAnnotatedPagerController.h"

#define TITLE_CONTROL_HEIGHT 25.0

@interface SGAnnotatedPagerController ()

@end

@implementation SGAnnotatedPagerController
@synthesize scrollView, titleScrollView;
@dynamic pageIndex;

- (void)loadView {
    [super loadView];

    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, TITLE_CONTROL_HEIGHT);
    titleScrollView = [[UIScrollView alloc] initWithFrame:frame];
    titleScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    titleScrollView.backgroundColor = [UIColor lightGrayColor];
    [titleScrollView setCanCancelContentTouches:NO];
    titleScrollView.showsHorizontalScrollIndicator = NO;
    titleScrollView.clipsToBounds = YES;
    titleScrollView.scrollEnabled = YES;
    titleScrollView.userInteractionEnabled = NO;
    
    frame = CGRectMake(0, TITLE_CONTROL_HEIGHT, self.view.bounds.size.width,
                                    self.view.bounds.size.height - TITLE_CONTROL_HEIGHT);
    scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.delegate = self;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [scrollView setBackgroundColor:[UIColor whiteColor]];
    [scrollView setCanCancelContentTouches:NO];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.clipsToBounds = YES;
    scrollView.scrollEnabled = YES;
    scrollView.pagingEnabled = YES;
    
    [self.view addSubview:scrollView];
    [self.view addSubview:titleScrollView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadPages];
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

#pragma mark Properties
- (void)setPageIndex:(NSUInteger)index {
    _pageIndex = index;
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
    return _pageIndex;
}

#pragma mark -
#pragma mark UIScrollViewDelegate stuff
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    if (pageControlIsChangingPage) {
        return;
    }
    
    CGFloat newXOff = (_scrollView.contentOffset.x/_scrollView.contentSize.width)*titleScrollView.contentSize.width;
    titleScrollView.contentOffset = CGPointMake(newXOff, 0);
    
	/*
	 *	We switch page at 50% across
	 */
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pageIndex = page;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView 
{
    pageControlIsChangingPage = NO;
}

- (void)reloadPages {
    for (UIView *view in titleScrollView.subviews) {
        [view removeFromSuperview];
    }
    for (UIView *view in scrollView.subviews) {
        [view removeFromSuperview];
    }
    
	CGFloat cx = 0;
    CGFloat dx = 0;
    CGFloat titleItemWidth = titleScrollView.bounds.size.width;
    
    NSUInteger count = self.childViewControllers.count;
	for (NSUInteger i = 0; i < count; i++) {
        UIViewController *vC = [self.childViewControllers objectAtIndex:i];
        
        CGRect frame = CGRectMake(dx, 0, titleItemWidth, titleScrollView.bounds.size.height);
        UIView *view = [[UIView alloc]initWithFrame:frame];
        view.backgroundColor = [UIColor clearColor];
        UIFont *font = [UIFont boldSystemFontOfSize:15.0];
        CGSize size = [vC.title sizeWithFont:font];
        frame = CGRectMake(0.5*(frame.size.width - size.width), 0.5*(frame.size.height - size.height), size.width, size.height);
        UILabel *l = [[UILabel alloc] initWithFrame:frame];
        l.backgroundColor = [UIColor clearColor];
        l.font = font;
        l.text = vC.title;
        [view addSubview:l];
        [titleScrollView addSubview:view];
        dx += titleItemWidth;
        
        view = vC.view;
		CGRect rect = view.frame;
		rect.origin.x = cx;
		rect.origin.y = 0;
		view.frame = rect;
		[scrollView addSubview:view];
		cx += scrollView.frame.size.width;
	}
	[titleScrollView setContentSize:CGSizeMake(dx, titleScrollView.bounds.size.height)];
	[scrollView setContentSize:CGSizeMake(cx, scrollView.bounds.size.height)];
}

@end
