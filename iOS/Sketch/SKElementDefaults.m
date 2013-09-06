//
//  SKElementDefaults.m
//  Sketch
//
//  Created by Nate Parrott on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKElementDefaults.h"
#import "SKColorFill.h"

@implementation SKElementDefaults

+(id)defaultValueForProperty:(NSString*)property withElementClass:(Class)elementClass {
#define DEFAULT(prop, val) if ([property isEqualToString:prop]) {\
    return val;\
    }
    
    DEFAULT(@"text", @"Text");
    DEFAULT(@"fillColor", [UIColor blackColor]);
    
    DEFAULT(@"strokeShape", [NSNumber numberWithBool:YES]);
    DEFAULT(@"strokeColor", [UIColor blackColor]);
    DEFAULT(@"strokeWidth", [NSNumber numberWithDouble:5]);
    
    DEFAULT(@"fill", [[SKColorFill alloc] initWithColor:[UIColor colorWithWhite:0.8 alpha:1]]);
    
    DEFAULT(@"textAlignment", @"center");
    
    DEFAULT(@"showShadow", [NSNumber numberWithBool:NO]);
    DEFAULT(@"shadowRadius", [NSNumber numberWithFloat:5]);
    DEFAULT(@"shadowOffset", [NSValue valueWithCGPoint:CGPointMake(3, 3)]);
    DEFAULT(@"shadowColor", [UIColor colorWithWhite:0 alpha:0.6]);
    
    return nil;
}
/*
 [textEl.properties setObject:@"Hello, world" forKey:@"text"];
 [textEl.properties setObject:[NSNumber numberWithBool:YES] forKey:@"fillShape"];
 [textEl.properties setObject:[UIColor blackColor] forKey:@"fillColor"];
 
 [el.properties setObject:[NSNumber numberWithBool:YES] forKey:@"strokeShape"];
 [el.properties setObject:[UIColor blackColor] forKey:@"strokeColor"];
 [el.properties setObject:[NSNumber numberWithDouble:5] forKey:@"strokeWidth"];
 [el.properties setObject:[NSNumber numberWithBool:YES] forKey:@"fillShape"];
 [el.properties setObject:[[SKColorFill alloc] initWithColor:[UIColor colorWithWhite:0.8 alpha:1]] forKey:@"fill"];
 */

@end
