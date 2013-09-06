//
//  SKSpecialNavigationController.m
//  Sketch
//
//  Created by Nate Parrott on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKSpecialNavigationController.h"

@interface SKSpecialNavAnimation : NSObject

@property(strong)UIView* animationView;
@property CGRect startFrame;
@property CGRect endFrame;

@end

@implementation SKSpecialNavAnimation
@synthesize animationView, startFrame, endFrame;

@end

@interface SKSpecialNavigationController ()

@end

@implementation SKSpecialNavigationController

#pragma mark API
-(id)initWithRootViewController:(UIViewController*)root {
    self = [super init];
    [self addChildViewController:root];
    _viewControllers = [NSMutableArray arrayWithObject:root];
    _animations = [NSMutableArray new];
    _currentlyVisible = root;
    return self;
}
-(NSArray*)viewControllers {
    return _viewControllers;
}
-(void)pushViewController:(UIViewController*)viewController animatedByZoomingView:(UIView*)zoomView intoRect:(CGRect)animatedViewTarget {
    
    SKSpecialNavAnimation* animationData = [SKSpecialNavAnimation new];
    animationData.startFrame = [self.view convertRect:zoomView.bounds fromView:zoomView];
    animationData.endFrame = animatedViewTarget;
    animationData.animationView = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:zoomView]]; // hacky way to copy a UIView
    
    [_animations addObject:animationData];
    
    [self addChildViewController:viewController];
    [_viewControllers addObject:viewController];
    
    [self.view addSubview:viewController.view];
    [self.view addSubview:animationData.animationView];
    
    [self layoutAnimationViewsAtStart:animationData withEndViewController:viewController];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutAnimationViewsAtEnd:animationData withEndViewController:viewController];
    } completion:^(BOOL finished) {
        [_currentlyVisible.view removeFromSuperview];
        _currentlyVisible = viewController;
        [animationData.animationView removeFromSuperview];
    }];
    
}
-(void)popViewController {
    if (_viewControllers.count==1) {
        NSLog(@"Can't pop root view controller");
        return;
    }
    
    UIViewController* outgoing = _currentlyVisible;
    SKSpecialNavAnimation* animationData = [_animations lastObject];
    [self.view addSubview:animationData.animationView];
    
    UIViewController* incoming = [_viewControllers objectAtIndex:_viewControllers.count-2];
    [self.view insertSubview:incoming.view atIndex:0];
    incoming.view.frame = self.view.bounds;
    incoming.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self layoutAnimationViewsAtEnd:animationData withEndViewController:outgoing];
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutAnimationViewsAtStart:animationData withEndViewController:outgoing];
    } completion:^(BOOL finished) {
        [outgoing.view removeFromSuperview];
        [outgoing removeFromParentViewController];
        [_animations removeLastObject];
        [_viewControllers removeLastObject];
        _currentlyVisible = incoming;
        [animationData.animationView removeFromSuperview];
    }];
}
+(SKSpecialNavigationController*)navControllerForViewController:(UIViewController*)vc {
    vc = [vc parentViewController];
    while (vc && ![[vc class] isSubclassOfClass:[SKSpecialNavigationController class]]) {
        vc = [vc parentViewController];
    }
    return (SKSpecialNavigationController*)vc;
}
#pragma mark Animation helpers
-(void)layoutAnimationViewsAtStart:(SKSpecialNavAnimation*)animationData withEndViewController:(UIViewController*)viewController {
    viewController.view.frame = self.view.bounds;
    viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    viewController.view.alpha = 0;
    
    CGPoint scale = CGPointMake(animationData.startFrame.size.width/animationData.endFrame.size.width, animationData.startFrame.size.height/animationData.endFrame.size.height);
    viewController.view.transform = CGAffineTransformMakeScale(scale.x, scale.y);
    CGPoint offsetFromAnimationViewFinalCenter = CGPointMake(self.view.bounds.size.width/2 - (animationData.endFrame.origin.x+animationData.endFrame.size.width/2), self.view.bounds.size.height/2 - (animationData.endFrame.origin.y+animationData.endFrame.size.height/2));
    viewController.view.center = CGPointMake(animationData.startFrame.origin.x+animationData.startFrame.size.width/2+offsetFromAnimationViewFinalCenter.x*scale.x, animationData.startFrame.origin.y+animationData.startFrame.size.height/2+offsetFromAnimationViewFinalCenter.y*scale.y);
    
    animationData.animationView.frame = animationData.startFrame;
    animationData.animationView.alpha = 1;
}
-(void)layoutAnimationViewsAtEnd:(SKSpecialNavAnimation*)animationData withEndViewController:(UIViewController*)viewController {
    viewController.view.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    viewController.view.transform = CGAffineTransformIdentity;
    viewController.view.alpha = 1;
    
    animationData.animationView.frame = animationData.endFrame;
    animationData.animationView.alpha = 0;
}
#pragma mark View loading
-(void)loadView {
    self.view = [UIView new];
    [self.view addSubview:_currentlyVisible.view];
    _currentlyVisible.view.frame = self.view.bounds;
    _currentlyVisible.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
}
-(void)updateCurrentlyVisibleViewController {
    if (_currentlyVisible && [_currentlyVisible isViewLoaded]) {
        [_currentlyVisible.view removeFromSuperview];
    }
    _currentlyVisible = [_viewControllers lastObject];
    [self.view addSubview:_currentlyVisible.view];
    _currentlyVisible.view.frame = self.view.bounds;
    _currentlyVisible.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
}
-(void)didReceiveMemoryWarning {
    if (self.view.superview==nil) {
        [[_currentlyVisible view] removeFromSuperview];
        [self viewWillUnload];
        self.view = nil;
        [self viewDidUnload];
    }
    for (UIViewController* VC in _viewControllers) {
        [VC didReceiveMemoryWarning];
    }
}
#define FORWARD_MSG(selector) -(void)selector:(BOOL)animated {\
    [_currentlyVisible selector:animated];\
}
FORWARD_MSG(viewWillAppear);
FORWARD_MSG(viewDidAppear);
FORWARD_MSG(viewWillDisappear);
FORWARD_MSG(viewDidDisappear);

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    for (UIViewController* vc in _viewControllers) {
        if (![vc shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
            return NO;
        }
    }
    return YES;
}
-(UIView*)thumbnailViewForViewController:(UIViewController*)vc {
    return [[_animations objectAtIndex:[_viewControllers indexOfObject:vc]-1] animationView];
}

@end
