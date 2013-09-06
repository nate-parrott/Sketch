//
//  SKSpecialNavigationController.h
//  Sketch
//
//  Created by Nate Parrott on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKSpecialNavigationController : UIViewController {
    NSMutableArray* _viewControllers;
    NSMutableArray* _animations;
    UIViewController* _currentlyVisible;
}

-(id)initWithRootViewController:(UIViewController*)root;
-(NSArray*)viewControllers;
-(void)pushViewController:(UIViewController*)viewController animatedByZoomingView:(UIView*)zoomView intoRect:(CGRect)animatedViewTarget;
-(void)popViewController;
-(UIView*)thumbnailViewForViewController:(UIViewController*)vc;

+(SKSpecialNavigationController*)navControllerForViewController:(UIViewController*)vc;

@end
