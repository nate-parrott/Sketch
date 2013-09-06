//
//  CPAlphaSlider.m
//  Sketch
//
//  Created by Nate Parrott on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPAlphaSlider.h"
#import "CGPointExtras.h"
#import "CPColorPicker.h"

@implementation CPAlphaSlider

-(void)awakeFromNib {
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    
    _target = [UIImageView new];
    _target.image = [UIImage imageNamed:@"circle.png"];
    _target.frame = CGRectMake(0, 0, 29, 29);
    [self addSubview:_target];
}

@synthesize color=_color;
-(void)setColor:(UIColor *)color {
    _color = color;
    [self setNeedsDisplay];
}
@synthesize alpha=_alpha;
-(void)setAlpha:(CGFloat)alpha {
    _alpha = alpha;
    [self setNeedsLayout];
}
-(void)drawRect:(CGRect)rect {
    [[UIImage imageNamed:@"checker.png"] drawAsPatternInRect:rect];
    
    UIColor* lowColor = [self.color colorWithAlphaComponent:0];
    UIColor* highColor = self.color;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    NSArray* colors = [NSArray arrayWithObjects:(id)lowColor.CGColor, (id)highColor.CGColor, nil];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    const CGFloat locations[] = {0, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
    CGContextDrawLinearGradient(ctx, gradient, CGPointZero, CGPointMake(self.bounds.size.width, 0), NULL);
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}
-(void)layoutSubviews {
    _target.center = CGPointMake(CGTransformByAddingPadding(_alpha*self.bounds.size.width, 29.0/2, self.bounds.size.width), self.bounds.size.height/2);
}
#pragma mark Touch handling
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesMoved:touches withEvent:event];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGFloat pos = CGTransformByRemovingPadding([[touches anyObject] locationInView:self].x, 29.0/2, self.bounds.size.width);
    _alpha = CGSnap(pos, self.bounds.size.width)/self.bounds.size.width;
    [self setNeedsLayout];
    [_colorPicker updateAlpha:_alpha];
}


@end
