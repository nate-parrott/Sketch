//
//  CGPointExtras.h
//  Sketch
//
//  Created by Nate Parrott on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Sketch_CGPointExtras_h
#define Sketch_CGPointExtras_h

#ifdef __cplusplus
extern "C" {
#endif

extern const CGPoint CGPointNull;
BOOL CGPointIsNull(CGPoint p);

CGFloat CGPointDistance(CGPoint p1, CGPoint p2);

extern const CGFloat CGPointStandardSnappingThreshold;
//CGPoint CGPointSnapToPossiblePoints(CGPoint point, CGPoint* possiblePoints, int numPossiblePoints, CGFloat threshold);
CGFloat CGSnapWithThreshold(CGFloat x, CGFloat range, CGFloat threshold);
CGFloat CGSnap(CGFloat x, CGFloat range);

CGFloat CGPointAngleBetween(CGPoint p1, CGPoint p2);
CGPoint CGPointShift(CGPoint p, CGFloat direction, CGFloat distance);
CGPoint CGPointMidpoint(CGPoint p1, CGPoint p2);

CGFloat CGTransformByAddingPadding(CGFloat p, CGFloat padding, CGFloat range);
CGFloat CGTransformByRemovingPadding(CGFloat p, CGFloat padding, CGFloat range);

#ifdef __cplusplus
}
#endif
    
#endif
