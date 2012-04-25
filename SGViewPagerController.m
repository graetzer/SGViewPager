//
//  SGViewPagerController.m
//  ViewPager
//
//  Copyright (c) 2012 Simon Grätzer
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    CGRect frame = CGRectMake(0, self.view.bounds.size.height - PAGE_CONTROL_HEIGHT,
                                     self.view.bounds.size.width, PAGE_CONTROL_HEIGHT);
    pageControl = [[UIPageControl alloc] initWithFrame:frame];
    pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    self.pageControl.backgroundColor = [UIColor blackColor];
    [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    
    frame = CGRectMake(0, 0, self.view.bounds.size.width,
                                    self.view.bounds.size.height-PAGE_CONTROL_HEIGHT);
    scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.delegate = self;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    scrollView.autoresizesSubviews = YES;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.canCancelContentTouches = NO;
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    _lockPageChange = YES; //The scrollview tends to scroll to a different page when the screen rotates
    [self reloadPages];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    _lockPageChange = NO;
    [self setPageIndex:self.pageIndex animated:NO];
}

#pragma mark Add and remove
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    int oldCount = self.childViewControllers.count;
    if (oldCount > 0) {
        self.pageIndex = 0;
        for (UIViewController *vC in self.childViewControllers) {
            [vC willMoveToParentViewController:nil];
            [vC removeFromParentViewController];
        }
    }
    
    for (UIViewController *vC in viewControllers) {
        [self addChildViewController:vC];
        [vC didMoveToParentViewController:self];
    }
    if (oldCount > 0)
        [self reloadPages];
    //TODO animations
}


#pragma mark Properties
- (void)setPageIndex:(NSUInteger)pageIndex {
    [self setPageIndex:pageIndex animated:NO];
}

- (void)setPageIndex:(NSUInteger)index animated:(BOOL)animated; {

    pageControl.currentPage = index;
    /*
	 *	Change the scroll view
	 */
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * index;
    frame.origin.y = 0;
	
    if (frame.origin.x < scrollView.contentSize.width) {
        [scrollView scrollRectToVisible:frame animated:animated];
        /*
         *	When the animated scrolling finishings, scrollViewDidEndDecelerating will turn this off
         */
        _lockPageChange = YES;
    }
}

- (NSUInteger)pageIndex {
    return self.pageControl.currentPage;
}

#pragma mark -
#pragma mark UIScrollViewDelegate stuff
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    if (_lockPageChange)
        return;
	/*
	 *	We switch page at 50% across
	 */
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView 
{
    _lockPageChange = NO;
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
    _lockPageChange = YES;
}

@end
