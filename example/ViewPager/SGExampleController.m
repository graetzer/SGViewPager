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
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *text = [NSString stringWithFormat:@"Content of\n Controller %@", super.title];
    
    UIFont *font = [UIFont boldSystemFontOfSize:25.0];
    CGSize size = [@"Content of Controller" sizeWithFont:font];
    CGRect frame = CGRectMake(0.5*(self.view.bounds.size.width - size.width), 
                              0.5*(self.view.bounds.size.height - 3*size.height), size.width, 3*size.height);
    UILabel *l = [[UILabel alloc] initWithFrame:frame];
    l.lineBreakMode = UILineBreakModeWordWrap;
    l.numberOfLines = 3;
    l.font = font;
    l.text = text;
    [self.view addSubview:l];
}

- (NSString *)title {
    return [NSString stringWithFormat:@"Title %@", super.title];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
