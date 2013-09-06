//
//  SKResizer.m
//  Sketch
//
//  Created by Nate Parrott on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKResizer.h"

const CGFloat SKResizerTargetSize = 40;

@implementation SKResizer
@synthesize delegate=_delegate;
@synthesize size=_size;

-(id)init {
    self = [super init];
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    return self;
}
-(void)setSize:(CGSize)size {
    _size = size;
    self.frame = CGRectMake(size.width-SKResizerTargetSize, size.height-SKResizerTargetSize, SKResizerTargetSize, SKResizerTargetSize);
}
-(void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0.2 alpha:0.8].CGColor);
    int numLines = 4;
    for (int line=0; line<numLines; line++) {
        CGContextMoveToPoint(ctx, SKResizerTargetSize*(0.5+line*0.5/numLines), SKResizerTargetSize);
        CGContextAddLineToPoint(ctx, SKResizerTargetSize, SKResizerTargetSize*(0.5+line*0.5/numLines));
        CGContextStrokePath(ctx);
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint curPoint = [[touches anyObject] locationInView:self.superview];
    CGPoint prevPoint = [[touches anyObject] previousLocationInView:self.superview];
    CGPoint translation = CGPointMake(curPoint.x-prevPoint.x, curPoint.y-prevPoint.y);
    _size.width += translation.x;
    _size.height += translation.y;
    self.size = _size; // trigger reposition
    [self.delegate didResize:self];
}

@end
