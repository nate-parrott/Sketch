//
//  SKColorView.m
//  Sketch
//
//  Created by Nate Parrott on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKColorView.h"
#import "SKFill.h"

@implementation SKColorView
@synthesize color=_color;

-(void)willMoveToWindow:(UIWindow *)newWindow {
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
}
-(void)setColor:(id)color {
    _color = color;
    [self setNeedsDisplay];
}
-(void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, CGRectInset(self.bounds, 2, 2));
    CGContextClip(ctx);
    
    UIImage* checker = [UIImage imageNamed:@"checker"];
    [checker drawAsPatternInRect:self.bounds];
    
    if ([self.color isKindOfClass:[UIColor class]]) {
        CGContextSetFillColorWithColor(ctx, [self.color CGColor]);
        CGContextFillRect(ctx, rect);
    } else if ([self.color isKindOfClass:[SKFill class]]) {
        [self.color drawInRect:rect];
    }
    
    CGFloat shadowThickness = 3;
    CGContextSetShadow(ctx, CGSizeMake(0, shadowThickness), shadowThickness);
    CGContextSetLineWidth(ctx, shadowThickness*2);
    CGContextStrokeEllipseInRect(ctx, CGRectInset(self.bounds, 2-shadowThickness, 2-shadowThickness));
}
#pragma mark Clicking
@synthesize clickTarget, clickSelector;
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self pointInside:[[touches anyObject] locationInView:self] withEvent:nil]) {
        [self.clickTarget performSelector:self.clickSelector withObject:self];
    }
}
@end
