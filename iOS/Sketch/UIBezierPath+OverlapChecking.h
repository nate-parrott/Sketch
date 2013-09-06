//
//  UIBezierPath+OverlapChecking.h
//  Sketch
//
//  Created by Nate Parrott on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (OverlapChecking)

-(BOOL)overlapsPath:(UIBezierPath*)otherPath withTolerance:(CGFloat)distanceMargin;

@end
