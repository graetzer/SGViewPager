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

#import "SGExampleController.h"

@interface SGExampleController ()

@end

@implementation SGExampleController

- (void)loadView {
    [super loadView];
    
    self.view.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
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
    l.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
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
