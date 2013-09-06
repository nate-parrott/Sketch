//
//  UIFont+Sizing.h
//  Sketch
//
//  Created by Nate Parrott on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Sizing)

-(CGFloat)maximumPointSizeThatFitsText:(NSString*)text inSize:(CGSize)size;

@end
