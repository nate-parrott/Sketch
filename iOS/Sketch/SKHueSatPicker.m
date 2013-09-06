//
//  SKHueSatPicker.m
//  Sketch
//
//  Created by Nate Parrott on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKHueSatPicker.h"
#import "SKColorPicker.h"
#import "CGPointExtras.h"

@implementation SKHueSatPicker
@synthesize hue=_hue, sat=_sat;

-(void)willMoveToWindow:(UIWindow *)newWindow {
    if (!_setupYet) {
        _setupYet = YES;
        
        _imageView = [UIImageView new];
        [_imageView setImage:[UIImage imageNamed:@"colorMap.png"]];
        [self addSubview:_imageView];
        
        _targetView = [UIImageView new];
        _targetView.image = [UIImage imageNamed:@"circle.png"];
        _targetView.frame = CGRectMake(0, 0, 29, 29);
        [self addSubview:_targetView];
    }
}
-(void)setHue:(CGFloat)hue {
    _hue = hue;
    [self setNeedsLayout];
}
-(void)setSat:(CGFloat)sat {
    _sat = sat;
    [self setNeedsLayout];
}
-(void)layoutSubviews {
    _imageView.frame = self.bounds;
    _targetView.center = CGPointMake(CGTransformByAddingPadding(_hue*self.bounds.size.width, 29.0/2, self.bounds.size.width), CGTransformByAddingPadding((1-_sat)*self.bounds.size.height, 29.0/2, self.bounds.size.height));
}
#pragma mark Touch handling
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesMoved:touches withEvent:event];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint pos = [[touches anyObject] locationInView:self];
    pos.x = CGTransformByRemovingPadding(pos.x, 29.0/2, self.bounds.size.width);
    pos.y = CGTransformByRemovingPadding(pos.y, 29.0/2, self.bounds.size.height);
    pos.x = CGSnap(pos.x, self.bounds.size.width);
    pos.y = CGSnap(pos.y, self.bounds.size.height);
    [_picker setHue:pos.x/self.bounds.size.width];
    [_picker setSat:1-pos.y/self.bounds.size.height];
}

@end
