//
//  SKHueSatPicker.h
//  Sketch
//
//  Created by Nate Parrott on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SKColorPicker;
@interface SKHueSatPicker : UIView {
    BOOL _setupYet;
    IBOutlet SKColorPicker* _picker;
    UIImageView* _imageView;
    UIImageView* _targetView;
}

@property(nonatomic) CGFloat hue, sat;

@end
