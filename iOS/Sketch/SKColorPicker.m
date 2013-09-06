//
//  SKColorPicker.m
//  Sketch
//
//  Created by Nate Parrott on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKColorPicker.h"
#import "SKColorView.h"
#import "SKHueSatPicker.h"
#import "SKColorPickerSlider.h"

@interface SKColorPicker ()

@end

@implementation SKColorPicker
@synthesize callback=_callback;

-(id)init {
    self = [super initWithNibName:@"SKColorPicker" bundle:nil];
    self.title = @"Color";
    return self;
}
-(void)viewDidLoad {
    self.view.backgroundColor = BACKGROUND_COLOR;
    _brightnessPicker.callbackSelector = @selector(brightnessDidUpdate);
    _alphaPicker.callbackSelector = @selector(alphaDidUpdate);
    [self colorDidUpdate];
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}
#pragma mark Color setting

-(void)colorDidUpdate {
    _hueSatPicker.hue = _hue;
    
    _hueSatPicker.sat = _sat;
    
    _brightnessPicker.value = _brightness;
    _brightnessPicker.highColor = [UIColor colorWithHue:_hue saturation:_sat brightness:1 alpha:1];
    _brightnessPicker.lowColor = [UIColor colorWithHue:_hue saturation:_sat brightness:0 alpha:1];
    
    _alphaPicker.value = _alpha;
    _alphaPicker.highColor = [UIColor colorWithHue:_hue saturation:_sat brightness:_brightness alpha:1];
    _alphaPicker.lowColor = [UIColor colorWithHue:_hue saturation:_sat brightness:_brightness alpha:0];
    
    _hueSatBrightnessOverlay.alpha = 1-_brightness;
    
    _colorView.color = [self color];
    if (self.callback) {
        self.callback([self color]);
    }
}
-(void)setColor:(UIColor *)color {
    if (![color getHue:&_hue saturation:&_sat brightness:&_brightness alpha:&_alpha]) {
        [color getWhite:&_brightness alpha:&_alpha];
        _hue = 0;
        _sat = 0;
    }
    
    [self colorDidUpdate];
}
-(UIColor*)color {
    return [UIColor colorWithHue:_hue saturation:_sat brightness:_brightness alpha:_alpha];
}
-(void)setHue:(CGFloat)hue {
    _hue = hue;
    if (_brightness==0) {
        _brightness = 1;
    }
    if (_alpha==0) {
        _alpha = 1;
    }
    [self colorDidUpdate];
}
-(void)setSat:(CGFloat)sat {
    _sat = sat;
    if (_brightness==0) {
        _brightness = 1;
    }
    if (_alpha==0) {
        _alpha = 1;
    }
    [self colorDidUpdate];
}
-(void)setBrightness:(CGFloat)brightness {
    _brightness = brightness;
    if (_alpha==0) {
        _alpha = 1;
    }
    [self colorDidUpdate];
}
-(void)setAlpha:(CGFloat)alpha {
    _alpha = alpha;
    [self colorDidUpdate];
}
-(void)brightnessDidUpdate {
    [self setBrightness:_brightnessPicker.value];
}
-(void)alphaDidUpdate {
    [self setAlpha:_alphaPicker.value];
}

@end
