//
//  CPBrightnessSaturationView.m
//  NPColorPicker3
//
//  Created by Nate Parrott on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPBrightnessSaturationView.h"
#import "CPColorPicker.h"
#import "RGB-HSV.h"
#import "CGPointExtras.h"

@implementation CPBrightnessSaturationView

@synthesize brightness=_brightness, saturation=_saturation, hue=_hue;

-(void)awakeFromNib {
    [super awakeFromNib];
    /*_crosshairs = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 31, 32)];
    _crosshairs.image = [UIImage imageNamed:@"crosshairs"];
    [self addSubview:_crosshairs];*/
}
-(void)setHue:(CGFloat)hue {
    _hue = hue;
    [self setNeedsDisplay];
}
-(void)setSaturation:(CGFloat)saturation {
    _saturation = saturation;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}
-(void)setBrightness:(CGFloat)brightness {
    _brightness = brightness;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}
-(void)layoutSubviews {
    [super layoutSubviews];
}
-(void)drawRect:(CGRect)rect {    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat width = CGBitmapContextGetWidth(ctx);
    CGFloat height = CGBitmapContextGetHeight(ctx);
    int bytesPerRow = CGBitmapContextGetBytesPerRow(ctx);
    CGFloat scale = width/self.bounds.size.width;
    if (scale!=self.contentScaleFactor)
        NSLog(@"Bitmap context reports width of %fpx, view is %fpt wide, but contentScaleFactor is %f", width, self.bounds.size.width, self.contentScaleFactor);
    unsigned char* data = CGBitmapContextGetData(ctx);
    for (int x=0; x<width; x++) {
        for (int y=0; y<height; y++) {
            CGPoint p = CGPointMake(x/scale, y/scale);
            unsigned char* pixel = data + (int)(y*bytesPerRow + x*4);
            CGFloat angle = atan2(p.y-self.bounds.size.height/2, p.x-self.bounds.size.width/2);
            CGFloat distance = sqrtf(powf(p.x-self.bounds.size.width/2, 2) + powf(p.y-self.bounds.size.height/2, 2));
            
            CGFloat brightness = distance / (self.bounds.size.width/2);
            CGFloat saturation = (angle+M_PI) / (M_PI*2);
            
            CGFloat r, g, b;
            // void HSVtoRGB(float *r, float *g, float *b, float h, float s, float v)
            HSVtoRGB(&r, &g, &b, _hue*360, saturation, brightness);
            pixel[2] = r*255;
            pixel[1] = g*255;
            pixel[0] = b*255;
            pixel[3] = 255;
        }
    }
}
#pragma mark Touch handling

/*
 CGFloat CGSnap(CGFloat x, CGFloat range);
 
 CGFloat CGPointAngleBetween(CGPoint p1, CGPoint p2);
 CGPoint CGPointShift(CGPoint p, CGFloat direction, CGFloat distance);
 CGPoint CGPointMidpoint(CGPoint p1, CGPoint p2);
 
 CGFloat CGTransformByAddingPadding(CGFloat p, CGFloat padding, CGFloat range);
 CGFloat CGTransformByRemovingPadding(CGFloat p, CGFloat padding, CGFloat range);
 */

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    [self touchesMoved:touches withEvent:event];
}
-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    CGPoint p = [[touches anyObject] locationInView:self];
    CGFloat brightness = sqrtf(powf(p.x-self.bounds.size.width/2, 2) + powf(p.y-self.bounds.size.height/2, 2)) / (self.bounds.size.width/2);
    CGFloat saturation = (atan2(p.y-self.bounds.size.height/2, p.x-self.bounds.size.width/2)+M_PI) / (M_PI*2);
    brightness = CGTransformByRemovingPadding(brightness, 0.1, 1);
    saturation = CGTransformByRemovingPadding(saturation, 0.1, 1);
    //-(void)updateBrightness:(CGFloat)brightness andSaturation:(CGFloat)saturation;
    [_colorPicker updateBrightness:brightness andSaturation:saturation];
    [self setNeedsLayout];
}

@end
