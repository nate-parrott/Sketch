//
//  CPHueWheel.h
//  NPColorPicker3
//
//  Created by Nate Parrott on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPColorPicker;

@interface CPHueWheel : UIView {
    IBOutlet CPColorPicker* _colorPicker;
    UIImageView* _huePointer;
}

@property(nonatomic) CGFloat hue;

@end
