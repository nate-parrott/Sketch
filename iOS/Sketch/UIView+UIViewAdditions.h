//
//  UIView+UIViewAdditions.h
//  Sketch
//
//  Created by Nate Parrott on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (UIViewAdditions)

-(void)replaceWith:(UIView*)other;
-(void)updateShadowWithColor:(UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius;

@end
