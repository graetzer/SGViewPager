//
//  SGAppDelegate.m
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

#import "SGAppDelegate.h"

#import "SGExampleController.h"
#import "SGViewPagerController.h"
#import "SGAnnotatedPagerController.h"

@implementation SGAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // The xib files are used to create views with a height adjusted to an UITabBarController
    SGViewPagerController *pager = [[SGViewPagerController alloc] initWithNibName:@"SGViewPagerController" bundle:nil];
    pager.title = @"UIPageControl";
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:5];
    for (int i = 0; i < 5; i++) {
        SGExampleController *ec = [[SGExampleController alloc] init];
        ec.title = [NSString stringWithFormat:@"Nr. %d", i+1];
        [array addObject:ec];
    }
    [pager setViewControllers:array animated:NO];
    
    SGAnnotatedPagerController *annotatedPager = [[SGAnnotatedPagerController alloc] initWithNibName:@"SGAnnotatedPagerController" bundle:nil];
    annotatedPager.title = @"TitleControl";
    
    [array removeAllObjects];
    for (int i = 0; i < 5; i++) {
        SGExampleController *ec = [[SGExampleController alloc] init];
        ec.title = [NSString stringWithFormat:@"Nr. %d", i+1];
        [array addObject:ec];
    }
    [annotatedPager setViewControllers:array animated:NO];
    
    UITabBarController *tabC = [[UITabBarController alloc] init];
    [tabC setViewControllers:[NSArray arrayWithObjects:pager, annotatedPager, nil] animated:NO];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = tabC;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
