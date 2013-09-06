//
//  SKAppDelegate.m
//  Sketch
//
//  Created by Nate Parrott on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKAppDelegate.h"
#import "SKDocumentList.h"

#import "CPColorPicker.h"
#import "SKImageExtractViewController.h"
#import "SKImageFill.h"
#import "CGPointExtras.h"

const NSString* SKAppDelegateShouldSaveData = @"kSKAppDelegateShouldSaveData";
const NSString* SKAppDelegateDidGainFocus = @"kSKAppDelegateDidGainFocus";

@implementation SKAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //NSLog(@"Documents dir: %@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]);
    
    //[UIImagePNGRepresentation([SKImageExtractView annotateEdges:[UIImage imageNamed:@"minibama.jpeg"]])  writeToFile:@"/Users/nateparrott/Desktop/traced.png" atomically:YES];
    
    /*UIImage* image = [UIImage imageNamed:@"minibama.jpeg"];
    CGPoint start = CGPointMake(150, 79);
    CGPoint end = CGPointMake(126, 129);
    CGFloat radius = 10;
    NSArray* path = [SKImageExtractView pathFromPoint:start to:end inImage:image radius:radius];
    for (NSValue* v in path) {
        NSLog(@"%@", NSStringFromCGPoint(v.CGPointValue));
    }
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 1);
    CGContextSetStrokeColorWithColor(ctx, [[UIColor redColor] colorWithAlphaComponent:0.9].CGColor);
    CGContextMoveToPoint(ctx, start.x, start.y);
    for (NSValue* p in path) {
        CGContextAddLineToPoint(ctx, p.CGPointValue.x, p.CGPointValue.y);
    }
    CGContextStrokePath(ctx);
    
    CGContextSetFillColorWithColor(ctx, [UIColor greenColor].CGColor);
    CGContextAddEllipseInRect(ctx, CGRectMake(start.x-2, start.y-2, 4, 4));
    CGContextAddEllipseInRect(ctx, CGRectMake(end.x-2, end.y-2, 4, 4));
    CGContextFillPath(ctx);
    
    CGPoint finishLineStart = CGPointShift(end, CGPointAngleBetween(start, end)+M_PI/2, radius);
    CGPoint finishLineEnd = CGPointShift(end, CGPointAngleBetween(start, end)-M_PI/2, radius);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blueColor].CGColor);
    CGContextMoveToPoint(ctx, finishLineStart.x, finishLineStart.y);
    CGContextAddLineToPoint(ctx, finishLineEnd.x, finishLineEnd.y);
    CGContextStrokePath(ctx);
    
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [UIImagePNGRepresentation(result) writeToFile:@"/Users/nateparrott/Desktop/res.png" atomically:YES];
    */
    
    [self applyAppearancePreferences];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    /*SKImageExtractViewController* extractView = [SKImageExtractViewController new];
    SKImageFill* fill = [SKImageFill new];
    fill.image = [UIImage imageNamed:@"minibama.jpeg"];
    extractView.imageFill = fill;
    self.window.rootViewController = extractView;*/
    
    
    SKDocumentList* documentList = [SKDocumentList new];
    // 'documentNavController' is in the hierarchy only so we have a navigation bar
    // we really use 'navController' to manage the transition to the document editor VC
    UINavigationController* documentNavController = [[UINavigationController alloc] initWithRootViewController:documentList];
    SKSpecialNavigationController* navController = [[SKSpecialNavigationController alloc] initWithRootViewController:documentNavController];
    self.window.rootViewController = navController;
    
    
    // for capturing default images:
     if (0) {
     documentList.navigationItem.leftBarButtonItem = nil;
     documentList.navigationItem.title = @"";
     documentList.navigationItem.rightBarButtonItem = nil;
     }
    
    
     
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)applyAppearancePreferences {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"woodenToolbar"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.670 green:0.588 blue:0.466 alpha:1.000]];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:0.613 green:0.106 blue:0.000 alpha:1.000], UITextAttributeTextColor, [UIColor colorWithWhite:0.8 alpha:1], UITextAttributeTextShadowColor, nil]];
    
    [[UINavigationBar appearanceWhenContainedIn:[UIPopoverController class], nil] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearanceWhenContainedIn:[UIPopoverController class], nil] setTintColor:nil];
    [[UINavigationBar appearanceWhenContainedIn:[UIPopoverController class], nil] setTitleTextAttributes:nil];
    
    /*[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"titleBar"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TITLE_COLOR, UITextAttributeTextColor, [UIColor whiteColor], UITextAttributeTextShadowColor, nil]];
    [[UINavigationBar appearance] setTintColor:OFF_LIGHT];
    
    [[UINavigationBar appearanceWhenContainedIn:[UIPopoverController class], nil] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearanceWhenContainedIn:[UIPopoverController class], nil] setTitleTextAttributes:nil];
    [[UINavigationBar appearanceWhenContainedIn:[UIPopoverController class], nil] setTintColor:nil];
    
    [[UIButton appearanceWhenContainedIn:[UIToolbar class], nil] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIImage* buttonBackground = [[UIImage imageNamed:@"button"] resizableImageWithCapInsets:UIEdgeInsetsMake(11, 11, 11, 11)];
    UIImage* pressedButtonBackground = [[UIImage imageNamed:@"buttonDown"] resizableImageWithCapInsets:UIEdgeInsetsMake(11, 11, 11, 11)];
    [[SKStyledButton appearance] setBackgroundImage:buttonBackground forState:UIControlStateNormal];
    [[SKStyledButton appearance] setBackgroundImage:pressedButtonBackground forState:UIControlStateHighlighted];
    [[SKStyledButton appearance] setTitleColor:OFF_LIGHT forState:UIControlStateNormal];
    [[SKStyledButton appearance] setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    UIImage* toolbarButtonBackground = [[UIImage imageNamed:@"toolbarButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundImage:toolbarButtonBackground forState:UIControlStateNormal];
    UIImage* toolbarButtonDownBackground = [[UIImage imageNamed:@"toolbarButtonDown"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundImage:toolbarButtonDownBackground forState:UIControlStateHighlighted];
    [[UIButton appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [[UIButton appearanceWhenContainedIn:[UIPopoverController class], [UINavigationBar class], nil] setBackgroundImage:nil forState:UIControlStateNormal];
    [[UIButton appearanceWhenContainedIn:[UIPopoverController class], [UINavigationBar class], nil] setBackgroundImage:nil forState:UIControlStateHighlighted];
    [[UIButton appearanceWhenContainedIn:[UIPopoverController class], [UINavigationBar class], nil] setTitleColor:nil forState:UIControlStateNormal];*/
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self saveData];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SKAppDelegateDidGainFocus object:self];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveData];
}
-(void)saveData {
    [[NSNotificationCenter defaultCenter] postNotificationName:SKAppDelegateShouldSaveData object:self];
}

@end
