//
//  SKImageView.m
//  Sketch
//
//  Created by Nate Parrott on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKImageView.h"

@implementation SKImageView
@synthesize image=_image;
@synthesize scale=_scale;

/*-(void)setScale:(CGFloat)scale {
    _scale = scale;
    self.contentScaleFactor = scale;
    [self setNeedsDisplay];
}*/

/*+(Class)layerClass {
    return [CATiledLayer class];
}
-(void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    CATiledLayer* layer = (CATiledLayer*)self.layer;
    layer.tileSize = CGSizeMake(512, 512);
}*/
-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView* child in self.subviews.reverseObjectEnumerator) {
        if ([child pointInside:[child convertPoint:point fromView:self] withEvent:event]) {
            return child;
        }
    }
    // okay, if the point doesn't lie inside any element's paths, let's see if it lies inside any bounding rects
    for (UIView* child in self.subviews.reverseObjectEnumerator) {
        if (CGRectContainsPoint(child.frame, point)) {
            return child;
        }
    }
    return nil;
}

@end
