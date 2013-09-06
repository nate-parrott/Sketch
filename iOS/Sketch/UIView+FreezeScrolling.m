//
//  UIView+FreezeScrolling.m
//  Sketch
//
//  Created by Nate Parrott on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIView+FreezeScrolling.h"

@implementation UIView (FreezeScrolling)

-(UIScrollView*)closestParentScrollView {
    UIView* sp = self.superview;
    while (sp && ![sp isKindOfClass:[UIScrollView class]]) {
        sp = sp.superview;
    }
    return (UIScrollView*)sp;
}
-(void)freezeParentScrollViews {
    [[self closestParentScrollView] setScrollEnabled:NO];
}
-(void)unfreezeParentScrollViews {
    [[self closestParentScrollView] setScrollEnabled:YES];
}

@end
