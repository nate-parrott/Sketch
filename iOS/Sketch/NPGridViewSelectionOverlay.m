//
//  UIGridViewSelectionOverlay.m
//  UIGridView
//
//  Created by Nate Parrott on 1/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NPGridViewSelectionOverlay.h"


@implementation NPGridViewSelectionOverlay
@synthesize cell;

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(ctx, [[UIColor redColor] colorWithAlphaComponent:0.5].CGColor);
	CGContextFillRect(ctx, rect);
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[cell touchesBegan:touches withEvent:event];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[cell touchesMoved:touches withEvent:event];
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[cell touchesCancelled:touches withEvent:event];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[cell touchesEnded:touches withEvent:event];
}

- (void)dealloc {
    [super dealloc];
}


@end
