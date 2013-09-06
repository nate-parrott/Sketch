//
//  CPHueWheel.m
//  NPColorPicker3
//
//  Created by Nate Parrott on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CPHueWheel.h"
#import "CPColorPicker.h"
#import "RGB-HSV.h"

@implementation CPHueWheel

@synthesize hue=_hue;

-(void)awakeFromNib {
    [super awakeFromNib];
    _huePointer = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,28,45)];
    [self addSubview:_huePointer];
    _huePointer.image = [UIImage imageNamed:@"huePointer"];
}
-(void)setHue:(CGFloat)hue {
    _hue = hue;
    [self setNeedsDisplay];
    [self setNeedsLayout];
}
-(void)layoutSubviews {
    [super layoutSubviews];
    CGFloat radius = self.bounds.size.width/2-CPHueWheelInset-CPColorPickerHueWheelWidth/2 - 1;
    CGFloat angle = (_hue-0.5)*M_PI*2;
    _huePointer.center = CGPointMake(self.bounds.size.width/2+cosf(angle)*radius, self.bounds.size.height/2+sinf(angle)*radius);
    _huePointer.transform = CGAffineTransformMakeRotation(angle-M_PI/2);
}
-(void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetShadowWithColor(ctx, CGSizeZero, CPHueWheelInset/2, [UIColor blackColor].CGColor);
    CGFloat ellipseInset = CPHueWheelInset + CPColorPickerHueWheelWidth/2;
    CGContextAddEllipseInRect(ctx, CGRectInset(self.bounds, ellipseInset, ellipseInset));
    CGContextSetLineWidth(ctx, CPColorPickerHueWheelWidth);
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextStrokePath(ctx);
    
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
            CGFloat hue = (angle+M_PI) / (M_PI*2);
            // void HSVtoRGB(float *r, float *g, float *b, float h, float s, float v)
            CGFloat r, g, b;
            HSVtoRGB(&r, &g, &b, hue*360, 1, 1);
            // r = hue; g = hue; b = hue;
            
            CGFloat dist = sqrtf(powf(p.x-self.bounds.size.width/2, 2) + powf(p.y-self.bounds.size.height/2, 2));
            CGFloat minRadius = self.bounds.size.width/2-CPColorPickerHueWheelWidth-CPHueWheelInset;
            CGFloat maxRadius = self.bounds.size.width/2-CPHueWheelInset;
            CGFloat innerClip = MIN(1, MAX(0, maxRadius-dist));
            CGFloat outerClip = MIN(1, MAX(0, dist-minRadius));
            CGFloat alpha = innerClip*outerClip;
            
            CGFloat oldAlpha = pixel[3] / 255.0;
            
            pixel[2] = r*255*alpha + pixel[2]*(1-alpha);
            pixel[1] = g*255*alpha + pixel[1]*(1-alpha);
            pixel[0] = b*255*alpha + pixel[0]*(1-alpha);
            pixel[3] = 255*(alpha + oldAlpha*(1-alpha));
        }
    }
}
#pragma mark Touch handling
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    CGFloat dist = sqrtf(powf(point.x-self.bounds.size.width/2, 2) + powf(point.y-self.bounds.size.height/2, 2));
    CGFloat minRadius = self.bounds.size.width/2-CPColorPickerHueWheelWidth-CPHueWheelInset;
    CGFloat maxRadius = self.bounds.size.width/2-CPHueWheelInset;
    return dist < maxRadius && dist > minRadius;
}
-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    [self touchesMoved:touches withEvent:event];
}
-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    CGPoint p = [[touches anyObject] locationInView:self];
    _hue = (atan2(p.y-self.bounds.size.height/2, p.x-self.bounds.size.width/2) + M_PI) / (2*M_PI);
    [self setNeedsLayout];
    [_colorPicker updateHue:_hue];
}

@end
