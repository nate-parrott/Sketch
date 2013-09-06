//
//  UIView+UIViewAdditions.m
//  Sketch
//
//  Created by Nate Parrott on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIView+UIViewAdditions.h"

@implementation UIView (UIViewAdditions)

-(void)replaceWith:(UIView*)other {
    other.frame = self.frame;
    other.autoresizingMask = self.autoresizingMask;
    [self.superview addSubview:other];
    [self removeFromSuperview];
}

-(void)updateShadowWithColor:(UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius {
    self.layer.shadowOpacity = 1;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
    self.layer.shadowColor = [color CGColor];
    
    if (self.layer.cornerRadius) {
        self.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius] CGPath];
    } else {
        self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.bounds] CGPath];
    }
}

@end
