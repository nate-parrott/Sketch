//
//  SKPointView.m
//  Sketch
//
//  Created by Nate Parrott on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKPointView.h"

const CGFloat SKPointViewRadius = 3;

@implementation SKPointView
@synthesize delegate=_delegate;
@synthesize point=_point;

-(void)setPoint:(SKPoint *)point {
    _point = point;
    self.frame = CGRectMake(point.point.x-SKPointViewRadius, point.point.y-SKPointViewRadius, SKPointViewRadius*2, SKPointViewRadius*2);
}
-(void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor blueColor].CGColor);
    CGContextFillEllipseInRect(ctx, self.bounds);
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _prevTouchPoint = [[touches anyObject] locationInView:self.superview];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self.superview];
    CGPoint newCenterPoint = CGPointMake(self.point.point.x+touchPoint.x-_prevTouchPoint.x, self.point.point.y+touchPoint.y-_prevTouchPoint.y);
    self.point.point = newCenterPoint;
    self.point = self.point; // trigger reposition
    [self.delegate pointDidMove:self];
    _prevTouchPoint = touchPoint;
}

@end
