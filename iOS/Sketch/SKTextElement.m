//
//  SKTextElement.m
//  Sketch
//
//  Created by Nate Parrott on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKTextElement.h"
#import "SKGradient.h"
#import "UIFont+Sizing.h"

@implementation SKTextElement

-(void)showText {
    NSString* text = [self propertyForKey:@"text"];
    NSString* fontName = @"Helvetica";
    if ([self propertyForKey:@"fontName"]) fontName = [self propertyForKey:@"fontName"];
    CGFloat fontSize = [[UIFont fontWithName:fontName size:10] maximumPointSizeThatFitsText:text inSize:self.innerSize];
    UIFont* font = [UIFont fontWithName:fontName size:fontSize];
    CGSize size = [text sizeWithFont:font constrainedToSize:self.innerSize lineBreakMode:UILineBreakModeWordWrap];
    CGRect rect = CGRectMake((self.innerSize.width-size.width)/2, (self.innerSize.height-size.height)/2, size.width, size.height);
    
    UITextAlignment alignment;
    NSString* alignmentString = [self propertyForKey:@"textAlignment"];
    if ([alignmentString isEqualToString:@"left"])
        alignment = UITextAlignmentLeft;
    else if ([alignmentString isEqualToString:@"center"])
        alignment = UITextAlignmentCenter;
    else if ([alignmentString isEqualToString:@"right"])
        alignment = UITextAlignmentRight;
    
    [text drawInRect:rect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:alignment];
}
-(void)draw {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGTextDrawingMode drawingMode = kCGTextInvisible;
    BOOL fill = [[self propertyForKey:@"fillShape"] boolValue];
    BOOL stroke = [[self propertyForKey:@"strokeShape"] boolValue];
    if (fill && stroke) {
        drawingMode = kCGTextFillStroke;
    } else if (fill) {
        drawingMode = kCGTextFill;
    } else if (stroke) {
        drawingMode = kCGTextStroke;
    }
    CGContextSetTextDrawingMode(ctx, drawingMode);
    CGContextSetLineWidth(ctx, [[self propertyForKey:@"strokeWidth"] floatValue]);
    UIColor* fillColor = [self propertyForKey:@"fillColor"];
    if (fillColor) CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
    UIColor* strokeColor = [self propertyForKey:@"strokeColor"];
    if (strokeColor) CGContextSetStrokeColorWithColor(ctx, strokeColor.CGColor);
    [self showText];
}

@end
