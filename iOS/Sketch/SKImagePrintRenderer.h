//
//  SKImagePrintRenderer.h
//  Sketch
//
//  Created by Nate Parrott on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKImage.h"

@interface SKImagePrintRenderer : UIPrintPageRenderer

@property(strong)SKImage* image;

@end
