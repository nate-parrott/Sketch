//
//  SKGradientColorStop.m
//  Sketch
//
//  Created by Nate Parrott on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKGradientColorStop.h"
#import "SKGradientColorStopEditor.h"
#import "SKColorPicker.h"
#import "SKGradientEditor.h"
#import "CGPointExtras.h"
#import "SKColorStopDetail.h"
#import "SKMinimalPopoverBackgroundView.h"

@implementation SKGradientColorStop
@synthesize color=_color, position=_position, editor=_editor;

-(void)willMoveToWindow:(UIWindow *)newWindow {
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
}
-(void)setColor:(UIColor *)color {
    _color = color;
    [self setNeedsDisplay];
}
-(void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetShadowWithColor(ctx, CGSizeZero, 3, [UIColor grayColor].CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.5 alpha:0.5].CGColor);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0.5 alpha:1].CGColor);
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGContextMoveToPoint(ctx, 0.2*width, 0.2*height);
    CGContextAddLineToPoint(ctx, 0.8*width, 0.2*height);
    CGContextAddLineToPoint(ctx, 0.8*width, 0.6*height);
    CGContextAddLineToPoint(ctx, 0.5*width, 0.8*height);
    CGContextAddLineToPoint(ctx, 0.2*width, 0.6*height);
    CGContextAddLineToPoint(ctx, 0.2*width, 0.2*height);
    CGContextDrawPath(ctx, kCGPathFillStroke);
}
/*-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect targetRect = self.bounds;
    if (self.position==0) { // if we're at the absolute right or left, shift the touch target over so that it isn't too thin
        targetRect.origin.x += targetRect.size.width/2;
    } else if (self.position==1) {
        targetRect.origin.x -= targetRect.size.width/2;
    }
    return CGRectContainsPoint(targetRect, point);
}*/
#pragma mark Touch handling
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _moved = NO;
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    _moved = YES;
    CGFloat x = [[touches anyObject] locationInView:self.superview].x;
    x = CGSnap(x, self.superview.bounds.size.width);
    self.position = x/self.superview.bounds.size.width;
    [self.editor updatedColorStops];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_moved) {
        [self editColorStop];
    }
}
-(void)editColorStop {
    SKColorStopDetail* colorStopDetail = [SKColorStopDetail new];
    colorStopDetail.colorStop = self;
    colorStopDetail.colorStopEditor = self.editor;
    
    _editorPopover = [[UIPopoverController alloc] initWithContentViewController:colorStopDetail];
    //_editorPopover.popoverBackgroundViewClass = [SKMinimalPopoverBackgroundView class];
    colorStopDetail.parentPopover = _editorPopover;
    _editorPopover.delegate = self;
    [_editorPopover presentPopoverFromRect:self.bounds inView:self permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    _editorPopover = nil;
}

@end
