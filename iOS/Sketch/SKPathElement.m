//
//  SKPathElement.m
//  Sketch
//
//  Created by Nate Parrott on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKPathElement.h"
#import "SKGradient.h"
#import "SKImageFill.h"

@implementation SKLine
@synthesize from, to, control1, control2, endStroke;
-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    self.from = [aDecoder decodeCGPointForKey:@"From"];
    self.to = [aDecoder decodeCGPointForKey:@"To"];
    self.control1 = [aDecoder decodeCGPointForKey:@"Control1"];
    self.control2 = [aDecoder decodeCGPointForKey:@"Control2"];
    self.endStroke = [aDecoder decodeBoolForKey:@"EndStroke"];
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeCGPoint:self.from forKey:@"From"];
    [aCoder encodeCGPoint:self.to forKey:@"To"];
    [aCoder encodeCGPoint:self.control1 forKey:@"Control1"];
    [aCoder encodeCGPoint:self.control2 forKey:@"Control2"];
    [aCoder encodeBool:self.endStroke forKey:@"EndStroke"];
}
-(id)init {
    self = [super init];
    self.from = self.to = self.control1 = self.control2 = CGPointNull;
    return self;
}
-(CGPoint)middlePoint {
    return CGPointMake((self.from.x+self.to.x)/2, (self.from.y+self.to.y)/2);
}

@end

@implementation SKPathElement
@synthesize strokes=_strokes;
#pragma mark Data
-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if ([aDecoder containsValueForKey:@"Strokes"]) {
        self.strokes = [aDecoder decodeObjectForKey:@"Strokes"];
    } else {
        self.strokes = [NSMutableArray arrayWithObject:[aDecoder decodeObjectForKey:@"Lines"]];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.strokes forKey:@"Strokes"];
}
-(id)init {
    self = [super init];
    self.strokes = [NSMutableArray new];
    return self;
}
-(void)getMinX:(CGFloat*)minX minY:(CGFloat*)minY maxX:(CGFloat*)maxX maxY:(CGFloat*)maxY {
    *minX = MAXFLOAT;
    *minY = MAXFLOAT;
    *maxX = 0;
    *maxY = 0;
    for (NSArray* lines in self.strokes) {
        for (SKLine* line in lines) {
#define POINT(p) *minX = MIN(*minX, p.x);\
*minY = MIN(*minY, p.y);\
*maxX = MAX(*maxX, p.x);\
*maxY = MAX(*maxY, p.y)
            if (!CGPointIsNull(line.from)) {
                POINT(line.from);
            }
            if (!CGPointIsNull(line.control1)) {
                POINT(line.control1);
            }
            if (!CGPointIsNull(line.control2)) {
                POINT(line.control2);
            }
            if (!CGPointIsNull(line.to)) {
                POINT(line.to);
            }
        }
    }
}
#pragma mark Drawing
-(UIBezierPath*)pathForLines:(NSArray*)lines {
    CGFloat minX = MAXFLOAT;
    CGFloat minY = MAXFLOAT;
    CGFloat maxX = 0;
    CGFloat maxY = 0;
    [self getMinX:&minX minY:&minY maxX:&maxX maxY:&maxY];
    
    //minX = minY = 0;
    //maxX = maxY = 1;
#define SCALED_POINT(p) CGPointMake((p.x-minX)*self.innerSize.width/(maxX-minX), (p.y-minY)*self.innerSize.height/(maxY-minY))
    
    UIBezierPath* path = [UIBezierPath new];
    if (lines.count>0) {
        [path moveToPoint:SCALED_POINT([[lines objectAtIndex:0] from])];
        CGPoint lastPoint = [[lines objectAtIndex:0] from];
        
        for (SKLine* line in lines) {
            if (!CGPointIsNull(line.control1) || !CGPointIsNull(line.control2)) { // bezier curve
                CGPoint middlePoint = CGPointMake((lastPoint.x+line.to.x)/2, (lastPoint.y+line.to.y)/2);
                CGPoint control1 = CGPointIsNull(line.control1)? middlePoint : line.control1;
                CGPoint control2 = CGPointIsNull(line.control2)? middlePoint : line.control2;
                [path addCurveToPoint:SCALED_POINT(line.to) controlPoint1:SCALED_POINT(control1) controlPoint2:SCALED_POINT(control2)];
            } else { // straight line
                [path addLineToPoint:SCALED_POINT(line.to)];
            }
            lastPoint = line.to;
        }
    }
    /*if ([[self.properties objectForKey:@"fillShape"] boolValue]) {
        [path closePath];
    }*/
    
    return path;
}
-(void)draw {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    for (NSArray* lines in self.strokes) {
        UIBezierPath* path = [self pathForLines:lines];
        
        if ([[self propertyForKey:@"fillShape"] boolValue]) {
            SKFill* fill = [self propertyForKey:@"fill"];
            CGContextSaveGState(ctx);
            [path addClip];
            [fill drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            CGContextRestoreGState(ctx);
        }
        if ([[self propertyForKey:@"strokeShape"] boolValue]) {
            [path setLineWidth:[[self propertyForKey:@"strokeWidth"] floatValue]];
            CGContextSetStrokeColorWithColor(ctx, [[self propertyForKey:@"strokeColor"] CGColor]);
            [path stroke];
        }
    }
}
-(BOOL)hitTest:(CGPoint)point {
    BOOL allPathsEmpty = YES;
    for (NSArray* lines in self.strokes) {
        UIBezierPath* path = [self pathForLines:lines];
        if ([path containsPoint:CGPointMake(point.x-self.frame.origin.x+self.padding.left, point.y-self.frame.origin.y+self.padding.top)]) {
            return YES;
        }
        if (![path isEmpty]) {
            allPathsEmpty = NO;
        }
    }
    if ([super hitTest:point] && allPathsEmpty) {
        return YES;
    }
    return NO;
}
#pragma mark Special Initialization
+(SKPathElement*)elementForImage:(UIImage*)image {
    SKPathElement* pathEl = [[SKPathElement alloc] init];
    pathEl.frame = CGRectMake(0, 0, 100, 100);
    
    NSMutableArray* lines = [NSMutableArray new];
    SKLine* line = [SKLine new];
    line.from = CGPointMake(0, 0);
    line.to = CGPointMake(0, 1);
    [lines addObject:line];
    line = [SKLine new];
    line.to = CGPointMake(1, 1);
    [lines addObject:line];
    line = [SKLine new];
    line.to = CGPointMake(1, 0);
    [lines addObject:line];
    line = [SKLine new];
    line.to = CGPointMake(0, 0);
    [lines addObject:line];
    pathEl.strokes = [NSArray arrayWithObject:lines];;
    
    [pathEl setProperty:[NSNumber numberWithBool:YES] forKey:@"fillShape"];
    [pathEl setProperty:[NSNumber numberWithBool:NO] forKey:@"strokeShape"];
    SKImageFill* fill = [SKImageFill new];
    fill.image = image;
    [pathEl setProperty:fill forKey:@"fill"];
    return pathEl;
}
@end
