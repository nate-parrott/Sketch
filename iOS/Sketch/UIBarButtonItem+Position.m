//
//  UIBarButtonItem+Position.m
//  Sketch
//
//  Created by Nate Parrott on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIBarButtonItem+Position.h"

@implementation UIBarButtonItem (Position)

-(CGPoint)positionInView:(UIView*)view {
    // save the current content
    id content = nil;
    if (self.title) content = self.title;
    else if (self.customView) content = self.customView;
    else if (self.image) content = self.image;
    CGFloat width = self.width;
    
    
    UIView* testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 1)];
    self.customView = testView;
    CGPoint point = [view convertPoint:testView.center fromView:testView.superview];
    
    if ([content isKindOfClass:[NSString class]]) self.title = content;
    else if ([content isKindOfClass:[UIView class]]) self.customView = content;
    else if ([content isKindOfClass:[UIImage class]]) self.image = content;
    
    return point;
}

@end
