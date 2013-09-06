//
//  CPColorPicker.h
//  NPColorPicker3
//
//  Created by Nate Parrott on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKColorView.h"

#define CPColorPickerHueWheelWidth 45
#define CPHueWheelInset 10

typedef void (^CPColorPickerCallback)(UIColor*);

@class CPHueWheel, CPBrightnessSaturationView, CPAlphaSlider;
@interface CPColorPicker : UIViewController {
    IBOutlet SKColorView* _colorView;
    CGFloat _hue, _sat, _brightness, _alpha;
    
    IBOutlet UIScrollView* _savedColorScrollView;
    NSMutableArray* _savedColors;
    NSMutableArray* _savedColorViews;
}

@property(assign)IBOutlet CPHueWheel* hueWheel;
@property(assign)IBOutlet CPBrightnessSaturationView* brightnessSaturationView;
@property(assign)IBOutlet CPAlphaSlider* alphaSlider;

@property(strong,nonatomic)UIColor* color;
-(void)updateHue:(CGFloat)hue;
-(void)updateBrightness:(CGFloat)brightness andSaturation:(CGFloat)saturation;
-(void)updateAlpha:(CGFloat)alpha;

@property(strong)CPColorPickerCallback callback;

@end
