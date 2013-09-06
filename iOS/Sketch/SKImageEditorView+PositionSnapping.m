//
//  SKImageEditorView+PositionSnapping.m
//  Sketch
//
//  Created by Nate Parrott on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKImageEditorView+PositionSnapping.h"
#import "SKPathElement.h"

@implementation SKImageEditorView (PositionSnapping)

-(CGRect)stickySnapFrameRect:(CGRect)rect withTolerance:(CGFloat)tolerance {
    CGPoint originalUpperLeft = rect.origin;
    CGPoint originalLowerRight = CGPointMake(rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
    
    CGPoint newUpperLeft = originalUpperLeft;
    CGPoint newLowerRight = originalLowerRight;
    
    // snap to a square aspect ratio:
    CGSize size = CGSizeMake(newLowerRight.x-newUpperLeft.x, newLowerRight.y-newUpperLeft.y);
    CGFloat averageSideLength = (size.width+size.height)/2;
    CGPoint adjustCoords = CGPointMake(averageSideLength-size.width, averageSideLength-size.height);
    CGPoint snappedLowerRight = CGPointMake(newLowerRight.x+adjustCoords.x, newLowerRight.y+adjustCoords.y);
    if (CGPointDistance(originalLowerRight, snappedLowerRight) <= tolerance) {
        newLowerRight = snappedLowerRight;
    }
    
    // snap centers:
    CGPoint center = CGPointMake((newUpperLeft.x+newLowerRight.x)/2, (newUpperLeft.y+newLowerRight.y)/2);
    CGPoint newCenter = [self snapCenters:center withTolerance:tolerance original:CGPointMake((originalUpperLeft.x+originalLowerRight.x)/2, (originalUpperLeft.y+originalLowerRight.y)/2)];
    newLowerRight.x += newCenter.x-center.x;
    newLowerRight.y += newCenter.y-center.y;
    newUpperLeft.x += newCenter.x-center.x;
    newUpperLeft.y += newCenter.y-center.y;
    
    // snap corners:
    newUpperLeft = [self snapPoint:newUpperLeft withTolerance:tolerance fromOriginalPoint:originalUpperLeft];
    newLowerRight = [self snapPoint:newLowerRight withTolerance:tolerance fromOriginalPoint:originalLowerRight];
    
    CGRect snappedRect = CGRectMake(newUpperLeft.x, newUpperLeft.y, newLowerRight.x-newUpperLeft.x, newLowerRight.y-newUpperLeft.y);
    //NSLog(@"Snapped rect %@ to %@", NSStringFromCGRect(rect), NSStringFromCGRect(snappedRect));
    return snappedRect;
}

#define SNAPX(x) if (CGPointDistance(CGPointMake(x,point.y), original) <= tolerance) {\
point = CGPointMake(x, point.y);\
}
#define SNAPY(y) if (CGPointDistance(CGPointMake(point.x,y), original) <= tolerance) {\
point = CGPointMake(point.x, y);\
}
-(CGPoint)snapCenters:(CGPoint)point withTolerance:(CGFloat)tolerance original:(CGPoint)original {
    for (SKElement* element in self.image.elements) {
        if ([self.selectedElements containsObject:element]) {continue;}
        CGPoint center = CGPointMake(element.frame.origin.x+element.frame.size.width/2, element.frame.origin.y+element.frame.size.height/2);
        SNAPX(center.x);
        SNAPY(center.y);
    }
    return point;
}
-(CGPoint)snapPoint:(CGPoint)point withTolerance:(CGFloat)tolerance fromOriginalPoint:(CGPoint)original {
    for (SKElement* element in self.image.elements) {
        if ([self.selectedElements containsObject:element]) {continue;}
            SNAPX(element.frame.origin.x);
            SNAPX(element.frame.origin.x+element.frame.size.width);
            SNAPY(element.frame.origin.y);
            SNAPY(element.frame.origin.y+element.frame.size.height);
    }
SNAPX(0);
SNAPY(0);
SNAPX(self.imageView.frame.size.width);
SNAPY(self.imageView.frame.size.height);
    return point;
}


/*
#define SNAPVAL(v) if (fabsf(v-value) < fabsf(closest-value)) closest = v;
-(CGFloat)snapEdgeValue:(CGFloat)value x:(BOOL)xCoord {
    CGFloat closest = value;
    for (SKElement* element in self.image.elements) {
        if ([self.selectedElements containsObject:element]) continue;
        CGFloat v1 = xCoord? element.frame.origin.x : element.frame.origin.y;
        CGFloat v2 = xCoord? element.frame.origin.x+element.frame.size.width : element.frame.origin.y+element.frame.size.height;
        SNAPVAL(v1);
        SNAPVAL(v2);
    }
    return closest;
}
-(CGFloat)snapCenterValue:(CGFloat)value x:(BOOL)xCoord {
    CGFloat closest = value;
    for (SKElement* element in self.image.elements) {
        if ([self.selectedElements containsObject:element]) continue;
        CGFloat v1 = xCoord? element.frame.origin.x + element.frame.size.width/2 : element.frame.origin.y + element.frame.size.height/2;
        SNAPVAL(v1);
    }
    return closest;
}
-(CGRect)snapRect:(CGRect)frame withTolerance:(CGFloat)tolerance {
    CGRect newRect = frame;
    CGFloat newLeftEdge = [self snapEdgeValue:frame.origin.x x:YES];
    CGFloat newRightEdge = [self snapEdgeValue:frame.origin.y x:<#(BOOL)#>]
}
*/

@end
