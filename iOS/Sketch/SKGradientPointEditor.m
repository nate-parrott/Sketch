//
//  SKGradientView.m
//  Sketch
//
//  Created by Nate Parrott on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKGradientPointEditor.h"
#import "CGPointExtras.h"
#import "SKGradientEditor.h"

@implementation SKGradientPointEditor
@synthesize gradient=_gradient;

-(void)setGradient:(SKGradient *)gradient {
    _gradient = gradient;
    [self setNeedsDisplay];
}
-(void)drawRect:(CGRect)rect {
    [_gradient drawInRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGFloat radius = 10;
    CGContextFillEllipseInRect(ctx, CGRectMake(self.gradient.startPoint.x*self.bounds.size.width-radius, self.gradient.startPoint.y*self.bounds.size.height-radius, radius*2, radius*2));
    CGContextFillEllipseInRect(ctx, CGRectMake(self.gradient.endPoint.x*self.bounds.size.width-radius, self.gradient.endPoint.y*self.bounds.size.height-radius, radius*2, radius*2));
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGContextSetLineWidth(ctx, 4);
    CGContextMoveToPoint(ctx, self.gradient.startPoint.x*self.bounds.size.width, self.gradient.startPoint.y*self.bounds.size.height);
    CGContextAddLineToPoint(ctx, self.gradient.endPoint.x*self.bounds.size.width, self.gradient.endPoint.y*self.bounds.size.height);
    CGContextStrokePath(ctx);
}
#pragma mark Touch handling
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    touchPoint.x /= self.bounds.size.width;
    touchPoint.y /= self.bounds.size.height;
    if (CGPointDistance(touchPoint, self.gradient.startPoint) < CGPointDistance(touchPoint, self.gradient.endPoint)) {
        _selectedStartPoint = YES;
    } else {
        _selectedStartPoint = NO;
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    touchPoint.x = CGSnap(touchPoint.x, self.bounds.size.width);
    touchPoint.y = CGSnap(touchPoint.y, self.bounds.size.height);
    touchPoint.x /= self.bounds.size.width;
    touchPoint.y /= self.bounds.size.height;
    if (_selectedStartPoint) {
        self.gradient.startPoint = touchPoint;
    } else {
        self.gradient.endPoint = touchPoint;
    }
    [_gradientEditor updatedGradient];
}
@end
