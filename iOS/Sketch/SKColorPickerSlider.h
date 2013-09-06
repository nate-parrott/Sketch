//
//  SKColorPickerSlider.h
//  Sketch
//
//  Created by Nate Parrott on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SKColorPicker;
@interface SKColorPickerSlider : UIView {
    BOOL _setupYet;
    IBOutlet SKColorPicker* _picker;
    UIImageView* _target;
}

@property(strong,nonatomic)UIColor *lowColor, *highColor;
@property(nonatomic)float value;
@property SEL callbackSelector;

@end
