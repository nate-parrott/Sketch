//
//  UIFont+Sizing.m
//  Sketch
//
//  Created by Nate Parrott on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIFont+Sizing.h"

@implementation UIFont (Sizing)

-(CGFloat)maximumPointSizeThatFitsText:(NSString*)text inSize:(CGSize)size {
    //NSLog(@"========");
    NSArray* words = [text componentsSeparatedByString:@" "];
    CGFloat granularity = 2;
    CGFloat low = 1;
    CGFloat high = 1000;
    while (1) {
        CGFloat mid = floorf((high+low)/2/granularity)*granularity;
        if (low == mid) {
            /*NSLog(@"High: %f; low: %f; mid: %f", high, low, mid);
            NSLog(@"fontSize: %f; frame: %@ fits in %@", low, NSStringFromCGSize([text sizeWithFont:[self fontWithSize:mid] constrainedToSize:CGSizeMake(size.width, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap]), NSStringFromCGSize(size));*/
            return low;
        }
        BOOL fits = YES;
        CGFloat height = [text sizeWithFont:[self fontWithSize:mid] constrainedToSize:CGSizeMake(size.width, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap].height;
        if (height > size.height) {
            fits = NO;
        } else {
            for (NSString* word in words) {
                CGSize wordSize = [word sizeWithFont:[self fontWithSize:mid]];
                if (wordSize.width > size.width) {
                    fits = NO;
                    break;
                }
            }
        }
        //NSLog(@"%f", height);
        if (fits) {
            //NSLog(@"fits");
            // font is too small/just right
            low = mid;
        } else {
            //NSLog(@"no fit");
            // font is too big
            high = mid;
        }
    }
}

@end
