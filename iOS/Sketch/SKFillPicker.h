//
//  SKFillPicker.h
//  Sketch
//
//  Created by Nate Parrott on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPColorPicker.h"
#import "SKFill.h"
#import "SKGradientEditor.h"
#import "SKImagePicker.h"
#import "SKNullViewController.h"

typedef void (^SKFillPickerCallback)(id);

@interface SKFillPicker : UITabBarController {
    CPColorPicker* _colorPicker;
    SKGradientEditor* _gradientPicker;
    SKImagePicker* _imagePicker;
    SKNullViewController* _noFill;
}

@property(strong)SKFillPickerCallback callback;

-(id)initWithFill:(SKFill*)fill;
@property(strong,nonatomic)SKFill* fill;

@end
