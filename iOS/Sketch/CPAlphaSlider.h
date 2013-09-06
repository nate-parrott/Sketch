//
//  CPAlphaSlider.h
//  Sketch
//
//  Created by Nate Parrott on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPColorPicker;
@interface CPAlphaSlider : UIView {
    IBOutlet CPColorPicker* _colorPicker;
    UIImageView* _target;
}

@property(strong,nonatomic)UIColor* color;
@property(nonatomic)CGFloat alpha;

@end
