//
//  SKImageEditorView+PositionSnapping.h
//  Sketch
//
//  Created by Nate Parrott on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKImageEditorView.h"

@interface SKImageEditorView (PositionSnapping)

// sticky snap adjusts all edges simultaneously; that is, it may make adjustments to both the left and right edges at the same time, actually alterning the dimensions of the image
-(CGRect)stickySnapFrameRect:(CGRect)rect withTolerance:(CGFloat)tolerance;
-(CGPoint)snapPoint:(CGPoint)point withTolerance:(CGFloat)tolerance fromOriginalPoint:(CGPoint)original;

/*-(CGFloat)snapEdgeValue:(CGFloat)value x:(BOOL)xCoord;
-(CGFloat)snapCenterValue:(CGFloat)value x:(BOOL)xCoord;
-(CGRect)snapRect:(CGRect)frame withTolerance:(CGFloat)tolerance;*/

@end
