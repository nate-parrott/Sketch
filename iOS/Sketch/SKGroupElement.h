//
//  SKGroupElement.h
//  Sketch
//
//  Created by Nate Parrott on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKElement.h"
#import "SKImage.h"

@interface SKGroupElement : SKElement

@property(strong)SKImage* childImage;
+(SKGroupElement*)groupElements:(NSArray*)elements fromImage:(SKImage*)rootImage; // automatically generates a group and adds it to rootImage
+(SKGroupElement*)groupElements:(NSArray*)elements fromImage:(SKImage*)rootImage asDetatchedCopy:(BOOL)copy;
-(NSArray*)ungroupAndRemove; // adds children to parent image and deletes the group

@end
