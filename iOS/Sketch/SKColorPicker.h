//
//  SKColorPicker.h
//  Sketch
//
//  Created by Nate Parrott on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SKColorPicker;
typedef void (^SKColorPickerCallback)(UIColor*);

@class SKHueSatPicker, SKColorPickerSlider, SKColorView;
@interface SKColorPicker : UIViewController {
    IBOutlet SKColorView* _colorView;
    IBOutlet SKHueSatPicker* _hueSatPicker;
    IBOutlet SKColorPickerSlider *_brightnessPicker, *_alphaPicker;
    IBOutlet UIView* _hueSatBrightnessOverlay;
    CGFloat _hue, _sat, _brightness, _alpha;
}

@property(strong,nonatomic)UIColor* color;
//-(void)colorComponentDidUpdate;

@property(strong)SKColorPickerCallback callback;

-(void)setHue:(CGFloat)hue;
-(void)setSat:(CGFloat)sat;
-(void)setBrightness:(CGFloat)brightness;
-(void)setAlpha:(CGFloat)alpha;

-(void)brightnessDidUpdate;
-(void)alphaDidUpdate;

@end
