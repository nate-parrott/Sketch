//
//  UIImage+Data.h
//  iOSplusOpenCV
//
//  Created by Nate Parrott on 9/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#include "IGImageData.h"

@interface UIImage (Data)

-(IGImageData*)toImageData;
-(IGImageData*)imageDataForSubImage:(CGRect)rect;
+(UIImage*)imageFromImageData:(IGImageData*)data;

@end
