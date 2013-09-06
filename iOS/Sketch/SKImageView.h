//
//  SKImageView.h
//  Sketch
//
//  Created by Nate Parrott on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKImage.h"

@interface SKImageView : UIView

@property(strong)SKImage* image;
@property(nonatomic)CGFloat scale;

@end
