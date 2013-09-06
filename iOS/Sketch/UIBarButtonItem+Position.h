//
//  UIBarButtonItem+Position.h
//  Sketch
//
//  Created by Nate Parrott on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Position)

// caution! doesn't work with system items
-(CGPoint)positionInView:(UIView*)view;

@end
