//
//  SGViewController.m
//  ViewPager
//
//  Created by Simon Grätzer on 30.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SGExampleController.h"

@interface SGExampleController ()

@end

@implementation SGExampleController

- (void)loadView {
    [super loadView];
    UIFont *font = [UIFont systemFontOfSize:40.0];
    CGSize size = [self.title sizeWithFont:font];
    CGRect frame = CGRectMake(0.5*(self.view.bounds.size.width - size.width), 
                              size.height, size.width, size.height);
    UILabel *l = [[UILabel alloc] initWithFrame:frame];
    l.font = font;
    l.text = self.title;
    [self.view addSubview:l];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
