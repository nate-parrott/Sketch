//
//  SKGradient.h
//  Sketch
//
//  Created by Nate Parrott on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKFill.h"

typedef enum {
    SKGradientTypeLinear = 0,
    SKGradientTypeRadial = 1
} SKGradientType;

@interface SKGradient : SKFill <NSCoding>

@property(strong)NSArray* colors;
@property(strong)NSArray* positions;
@property SKGradientType type;
@property CGPoint startPoint, endPoint;

@end
