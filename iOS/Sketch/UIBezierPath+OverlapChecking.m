//
//  UIBezierPath+OverlapChecking.m
//  Sketch
//
//  Created by Nate Parrott on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIBezierPath+OverlapChecking.h"

@implementation UIBezierPath (OverlapChecking)

-(BOOL)overlapsPath:(UIBezierPath*)otherPath withTolerance:(CGFloat)distanceMargin {
    CGRect boundingRect = [self bounds];
    CGRect otherBoundingRect = [otherPath bounds];
    CGPoint origin = CGPointMake(MAX(boundingRect.origin.x, otherBoundingRect.origin.x), MAX(boundingRect.origin.y, otherBoundingRect.origin.y));
    CGPoint comparedAreaLowerRightCorner = CGPointMake(MIN(boundingRect.origin.x+boundingRect.size.width, otherBoundingRect.origin.x+otherBoundingRect.size.width), MIN(boundingRect.origin.y+boundingRect.size.height, otherBoundingRect.origin.y+otherBoundingRect.size.height));
    CGSize comparedAreaSize = CGSizeMake(comparedAreaLowerRightCorner.x-origin.x, comparedAreaLowerRightCorner.y-origin.y);
    
    if (comparedAreaSize.width <= 0 || comparedAreaSize.height <= 0) {
        return NO;
    }
    
    CGSize canvasSize = CGSizeMake(roundf(comparedAreaSize.width), roundf(comparedAreaSize.height));
    
    unsigned char* data = malloc(canvasSize.width*canvasSize.height);
    memset(data, UINT_MAX, canvasSize.width*canvasSize.height);
    CGColorSpaceRef grayscale = CGColorSpaceCreateDeviceGray();
    CGContextRef ctx = CGBitmapContextCreate(data, canvasSize.width, canvasSize.height, 8, canvasSize.width, grayscale, kCGImageAlphaNone);
    CGColorSpaceRelease(grayscale);
    UIGraphicsPushContext(ctx);
    
    CGContextSetLineWidth(ctx, distanceMargin/2);
    CGContextSetAllowsAntialiasing(ctx, NO);
    
    CGContextConcatCTM(ctx, CGAffineTransformMakeTranslation(-origin.x, -origin.y));
    [self strokeWithBlendMode:kCGBlendModeNormal alpha:0.5];
    [otherPath strokeWithBlendMode:kCGBlendModeNormal alpha:0.5];
    UIGraphicsPopContext();
    
    BOOL overlapping = NO;
    unsigned char minimumValue = 120; // a little less than 128
    for (int i=0; i<canvasSize.width*canvasSize.height && !overlapping; i++) {
        if (data[i] < minimumValue) {
            overlapping = YES;
        }
    }
    free(data);
    return overlapping;
}

@end
