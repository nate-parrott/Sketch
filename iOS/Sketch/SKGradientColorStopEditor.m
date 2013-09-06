//
//  SKGradientColorStopEditor.m
//  Sketch
//
//  Created by Nate Parrott on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKGradientColorStopEditor.h"
#import "SKGradientEditor.h"
#import "SKGradientColorStop.h"

@implementation SKGradientColorStopEditor

@synthesize gradient=_gradient;
-(void)setGradient:(SKGradient *)gradient {
    _gradient = gradient;
    // generate color stops:
    for (UIView* subview in self.subviews) {
        [subview removeFromSuperview];
    }
    for (int i=0; i<gradient.colors.count; i++) {
        SKGradientColorStop* colorStop = [SKGradientColorStop new];
        colorStop.color = [gradient.colors objectAtIndex:i];
        colorStop.position = [[gradient.positions objectAtIndex:i] floatValue];
        colorStop.editor = self;
        [self addSubview:colorStop];
    }
}
-(void)updatedColorStops {
    NSMutableArray* colorStops = [self.subviews mutableCopy];
    [colorStops sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([(SKGradientColorStop*)obj1 position] < [(SKGradientColorStop*)obj2 position]) {
            return NSOrderedAscending;
        } else if ([(SKGradientColorStop*)obj1 position] == [(SKGradientColorStop*)obj2 position]) {
            return NSOrderedSame;
        } else {
            return NSOrderedDescending;
        }
    }];
    NSMutableArray* colors = [NSMutableArray new];
    NSMutableArray* positions = [NSMutableArray new];
    for (SKGradientColorStop* colorStop in colorStops) {
        [colors addObject:colorStop.color];
        [positions addObject:[NSNumber numberWithFloat:colorStop.position]];
    }
    self.gradient.colors = colors;
    self.gradient.positions = positions;
    
    [_gradientEditor updatedGradient];
    
    [self setNeedsLayout];
}
-(void)layoutSubviews {
    for (SKGradientColorStop* colorStop in self.subviews) {
        colorStop.frame = CGRectMake(0, 0, self.bounds.size.height*0.6, self.bounds.size.height);
        colorStop.center = CGPointMake(self.bounds.size.width*colorStop.position, self.bounds.size.height/2);
    }
}
-(void)drawRect:(CGRect)rect {
    [[UIImage imageNamed:@"checker"] drawAsPatternInRect:rect];
    SKGradient* gradientCopy = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.gradient]];
    gradientCopy.startPoint = CGPointZero;
    gradientCopy.endPoint = CGPointMake(1, 0);
    gradientCopy.type = SKGradientTypeLinear;
    [gradientCopy drawInRect:rect];
}
-(SKGradientEditor*)gradientEditor {
    return _gradientEditor;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGFloat pos = [[touches anyObject] locationInView:self].x/self.bounds.size.width;
    SKGradientColorStop* newColorStop = [SKGradientColorStop new];
    newColorStop.position = pos;
    newColorStop.color = [UIColor redColor];
    newColorStop.editor = self;
    [self addSubview:newColorStop];
    [self updatedColorStops];
    [newColorStop editColorStop];
}
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ([super pointInside:point withEvent:event]) {
        return YES;
    }
    for (UIView* colorStop in self.subviews) {
        if ([colorStop pointInside:[colorStop convertPoint:point fromView:self] withEvent:event]) {
            return YES;
        }
    }
    return NO;
}

@end
