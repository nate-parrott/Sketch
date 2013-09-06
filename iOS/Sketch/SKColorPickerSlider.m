//
//  SKColorPickerSlider.m
//  Sketch
//
//  Created by Nate Parrott on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKColorPickerSlider.h"
#import "SKColorPicker.h"
#import "CGPointExtras.h"

@implementation SKColorPickerSlider
@synthesize value=_value;

-(void)willMoveToWindow:(UIWindow *)newWindow {
    if (!_setupYet) {
        _setupYet = YES;
        
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        _target = [UIImageView new];
        _target.image = [UIImage imageNamed:@"circle.png"];
        _target.frame = CGRectMake(0, 0, 29, 29);
        [self addSubview:_target];
    }
}
-(void)setValue:(float)value {
    _value = value;
    [self setNeedsLayout];
}
-(void)layoutSubviews {
    _target.center = CGPointMake(CGTransformByAddingPadding(_value*self.bounds.size.width, 29.0/2, self.bounds.size.width), self.bounds.size.height/2);
}
@synthesize lowColor=_lowColor, highColor=_highColor;
-(void)setLowColor:(UIColor *)lowColor {
    _lowColor = lowColor;
    [self setNeedsDisplay];
}
-(void)setHighColor:(UIColor *)highColor {
    _highColor = highColor;
    [self setNeedsDisplay];
}
-(void)drawRect:(CGRect)rect {
    [[UIImage imageNamed:@"checker.png"] drawAsPatternInRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    NSArray* colors = [NSArray arrayWithObjects:(id)self.lowColor.CGColor, (id)self.highColor.CGColor, nil];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    const CGFloat locations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
    CGContextDrawLinearGradient(ctx, gradient, CGPointZero, CGPointMake(self.bounds.size.width, 0), NULL);
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}
#pragma mark Touch handling
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesMoved:touches withEvent:event];
}
@synthesize callbackSelector=_callbackSelector;
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGFloat pos = CGTransformByRemovingPadding([[touches anyObject] locationInView:self].x, 29.0/2, self.bounds.size.width);
    self.value = CGSnap(pos, self.bounds.size.width)/self.bounds.size.width;
    
    [_picker performSelector:self.callbackSelector];
}

@end
