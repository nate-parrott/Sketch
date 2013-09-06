//
//  SKImageFill.h
//  Sketch
//
//  Created by Nate Parrott on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKFill.h"

typedef enum {
    SKImageFillScale = 0,
    SKImageFillAspectScale = 1,
    SKImageFillTile = 2
} SKImageFillMode;

@interface SKImageFill : SKFill

@property(strong)UIImage* image;
@property SKImageFillMode fillMode;

@end
