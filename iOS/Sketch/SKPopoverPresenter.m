//
//  SKPopoverPresenter.m
//  Sketch
//
//  Created by Nate Parrott on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKPopoverPresenter.h"

const NSMutableSet* _SKPopoverPresenters = nil;

@implementation SKPopoverPresenter

-(id)init {
    self = [super init];
    if (!_SKPopoverPresenters)
        _SKPopoverPresenters = [NSMutableSet new];
    [_SKPopoverPresenters addObject:self];
    return self;
}
+(SKPopoverPresenter*)presentViewController:(UIViewController*)viewController fromViewController:(UIViewController*)parentViewController fromRect:(CGRect)rect inView:(UIView*)view {
    SKPopoverPresenter* presenter = [SKPopoverPresenter new];
    presenter.viewController = viewController;
    presenter.parentViewController = parentViewController;
    if ([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        presenter.popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
        presenter.popover.delegate = presenter;
        [presenter.popover presentPopoverFromRect:rect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [parentViewController presentModalViewController:viewController animated:YES];
    }
    return presenter;
}
+(SKPopoverPresenter*)presentViewController:(UIViewController*)viewController fromViewController:(UIViewController*)parentViewController fromBarButtonItem:(UIBarButtonItem*)item {
    SKPopoverPresenter* presenter = [SKPopoverPresenter new];
    presenter.viewController = viewController;
    presenter.parentViewController = parentViewController;
    if ([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        presenter.popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
        presenter.popover.delegate = presenter;
        [presenter.popover presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [parentViewController presentModalViewController:viewController animated:YES];
    }
    return presenter;
}

@synthesize viewController=_viewController, parentViewController=_parentViewController;
@synthesize popover=_popover;
-(void)dismiss {
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
    } else {
        [self.parentViewController dismissModalViewControllerAnimated:YES];
    }
    [self didDismiss];
}
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [self didDismiss];
}
-(void)didDismiss {
    if (self.dismissCallback)
        self.dismissCallback(self);
    self.popover = nil;
    self.dismissCallback = nil;
    [_SKPopoverPresenters removeObject:self];
}
@synthesize dismissCallback=_dismissCallback;

+(SKPopoverPresenter*)popoverPresenterForViewController:(UIViewController*)viewController {
    while (viewController && ![viewController isKindOfClass:[SKPopoverPresenter class]]) {
        viewController = viewController.parentViewController;
    }
    return (SKPopoverPresenter*)viewController;
}

@end
