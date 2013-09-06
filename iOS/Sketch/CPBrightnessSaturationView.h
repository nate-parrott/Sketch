//
//  CPBrightnessSaturationView.h
//  NPColorPicker3
//
//  Created by Nate Parrott on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPColorPicker;

@interface CPBrightnessSaturationView : UIView {
    IBOutlet CPColorPicker* _colorPicker;
    UIImageView* _crosshairs;
}

@property(nonatomic)CGFloat brightness, saturation, hue;

@end
