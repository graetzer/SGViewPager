//
//  SGViewController.m
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

#import "SGAnnotatedPagerController.h"

#define TITLE_CONTROL_HEIGHT 25.0

@interface SGAnnotatedPagerController ()

@end

@implementation SGAnnotatedPagerController
@synthesize scrollView, titleScrollView;
@dynamic pageIndex;

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
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
    [scrollView setBackgroundColor:[UIColor clearColor]];
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
    [controller didMoveToParentViewController:self];
}

- (void)removePage:(NSUInteger)index; {
    UIViewController *c = [self.childViewControllers objectAtIndex:index];
    [c willMoveToParentViewController:self];
    if (index == self.pageIndex) {
        if (index == 0)
            self.pageIndex = index+1;
        else
            self.pageIndex = index-1;
    }
    [c removeFromParentViewController];
    [self reloadPages];
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
	
    if (frame.origin.x < scrollView.contentSize.width) {
        [scrollView scrollRectToVisible:frame animated:NO];
        /*
         *	When the animated scrolling finishings, scrollViewDidEndDecelerating will turn this off
         */
        pageControlIsChangingPage = YES;
    }
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
    
    CGFloat newXOff = (_scrollView.contentOffset.x/_scrollView.contentSize.width)
                        *0.5*titleScrollView.bounds.size.width*self.childViewControllers.count;
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
    CGFloat titleItemWidth = titleScrollView.bounds.size.width/2;
    CGFloat dx = titleItemWidth/2;
    
    NSUInteger count = self.childViewControllers.count;
	for (NSUInteger i = 0; i < count; i++) {
        UIViewController *vC = [self.childViewControllers objectAtIndex:i];
        
        CGRect frame = CGRectMake(dx, 0, titleItemWidth, titleScrollView.bounds.size.height);
        UIView *view = [[UIView alloc]initWithFrame:frame];
        view.backgroundColor = [UIColor lightGrayColor];
        UIFont *font = [UIFont boldSystemFontOfSize:15.0];
        CGSize size = [vC.title sizeWithFont:font];
        frame = CGRectMake(0.5*(frame.size.width - size.width),
                           0.5*(frame.size.height - size.height), size.width, size.height);
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
	[titleScrollView setContentSize:CGSizeMake(dx+titleItemWidth/2, titleScrollView.bounds.size.height)];
	[scrollView setContentSize:CGSizeMake(cx, scrollView.bounds.size.height)];
}

@end
