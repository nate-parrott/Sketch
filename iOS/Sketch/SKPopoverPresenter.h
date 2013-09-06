//
//  SKPopoverPresenter.h
//  Sketch
//
//  Created by Nate Parrott on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKPopoverPresenter;
typedef void (^SKPopoverPresenterDismissCallback)(SKPopoverPresenter* presenter);

@interface SKPopoverPresenter : NSObject <UIPopoverControllerDelegate> {
    
}

+(SKPopoverPresenter*)presentViewController:(UIViewController*)viewController fromViewController:(UIViewController*)parentViewController fromRect:(CGRect)rect inView:(UIView*)view;
+(SKPopoverPresenter*)presentViewController:(UIViewController*)viewController fromViewController:(UIViewController*)parentViewController fromBarButtonItem:(UIBarButtonItem*)item;

-(void)dismiss;
@property(strong)UIViewController *viewController, *parentViewController;
@property(strong)UIPopoverController* popover;
@property(strong)SKPopoverPresenterDismissCallback dismissCallback;

+(SKPopoverPresenter*)popoverPresenterForViewController:(UIViewController*)viewController;

@end
