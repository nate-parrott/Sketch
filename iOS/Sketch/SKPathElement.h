//
//  SKPathElement.h
//  Sketch
//
//  Created by Nate Parrott on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKElement.h"
#import "CGPointExtras.h"


@interface SKLine : NSObject <NSCoding>

@property CGPoint from, to, control1, control2;
@property BOOL endStroke;

@end



@interface SKPathElement : SKElement

//@property(strong)UIBezierPath* path;
@property(strong)NSMutableArray* strokes;

-(NSArray*)paths;

+(SKPathElement*)elementForImage:(UIImage*)image;

@end
