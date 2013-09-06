//
//  UIView+FreezeScrolling.h
//  Sketch
//
//  Created by Nate Parrott on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FreezeScrolling)

-(void)freezeParentScrollViews;
-(void)unfreezeParentScrollViews;

@end
