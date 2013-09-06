//
//  SKPenOverlayView.m
//  Sketch
//
//  Created by Nate Parrott on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKPenOverlayView.h"
#import "CGPointExtras.h"
#import "SKPathElement.h"
#import "UIBezierPath+OverlapChecking.h"

@implementation SKPenOverlayView

-(id)init {
    self = [super init];
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"penGrid"]];
    _strokes = [NSMutableArray new];
    _undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_undoButton setImage:[UIImage imageNamed:@"undo"] forState:UIControlStateNormal];
    [self addSubview:_undoButton];
    [_undoButton addTarget:self action:@selector(undo:) forControlEvents:UIControlEventTouchUpInside];
    self.smoothing = 0.1;
    return self;
}
-(void)undo:(id)sender {
    if (_strokes.count) {
        [_strokes removeLastObject];
        [self setNeedsDisplay];
    }
}
-(void)layoutSubviews {
    _undoButton.frame = CGRectMake(10, self.bounds.size.height-50-10, 50, 50);
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    _currentStrokePoints = [NSMutableArray new];
    [_strokes addObject:_currentStrokePoints];
    [_currentStrokePoints addObject:[NSValue valueWithCGPoint:touchPoint]];
    _lastTouchPoint = touchPoint;
    _pointInsertionTicker = [NSTimer scheduledTimerWithTimeInterval:self.smoothing target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [self setNeedsDisplay];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    _lastTouchPoint = [[touches anyObject] locationInView:self];
}
-(void)tick {
    CGPoint lastPoint = [[_currentStrokePoints lastObject] CGPointValue];
    
    BOOL shouldAddPoint = NO;
    if (!CGPointEqualToPoint(lastPoint, _lastTouchPoint)) {
        shouldAddPoint = YES;
    } else {
        // if smoothing is on,
        // and if this matches the previous point, but not the point before that, add this point to the list again, to create a sharp joint
        if (self.smoothing && _currentStrokePoints.count >= 4) {
            CGPoint pointBeforeLast = [[_currentStrokePoints objectAtIndex:_currentStrokePoints.count-4] CGPointValue];
            if (!CGPointEqualToPoint(pointBeforeLast, _lastTouchPoint)) {
                shouldAddPoint = YES;
            }
        }
    }
    if (shouldAddPoint) {
        CGPoint prev = [[_currentStrokePoints lastObject] CGPointValue];
        [_currentStrokePoints addObject:[NSValue valueWithCGPoint:CGPointNull]];
        [_currentStrokePoints addObject:[NSValue valueWithCGPoint:CGPointNull]];
        [_currentStrokePoints addObject:[NSValue valueWithCGPoint:_lastTouchPoint]];
        [self curveAroundPointAtIndex:_currentStrokePoints.count-4];
        
        CGPoint min = CGPointMake(MIN(prev.x, _lastTouchPoint.x), MIN(prev.y, _lastTouchPoint.y));
        CGPoint max = CGPointMake(MAX(prev.x, _lastTouchPoint.x), MAX(prev.y, _lastTouchPoint.y));
        CGRect r = CGRectMake(min.x, min.y, max.x-min.x, max.y-min.y);
        //[self setNeedsDisplayInRect:CGRectInset(r, -10, -10)];
        [self setNeedsDisplay];
    }
}
-(void)curveAroundPointAtIndex:(int)index {
    CGPoint p = [[_currentStrokePoints objectAtIndex:index] CGPointValue];
    
    int nextPointIdx = index+3;
    int prevPointIdx = index-3;
    if (prevPointIdx >= 0 && nextPointIdx < _currentStrokePoints.count) {
        CGPoint p1 = [[_currentStrokePoints objectAtIndex:prevPointIdx] CGPointValue];
        CGPoint p2 = [[_currentStrokePoints objectAtIndex:nextPointIdx] CGPointValue];
        
        CGPoint a1 = CGPointMidpoint(p, p1);
        CGPoint a2 = CGPointMidpoint(p, p2);
        
        CGFloat d = CGPointDistance(a1, a2);
        CGFloat d1 = d*CGPointDistance(p, p1) / (CGPointDistance(p, p1) + CGPointDistance(p, p2));
        CGFloat d2 = d*CGPointDistance(p, p2) / (CGPointDistance(p, p1) + CGPointDistance(p, p2));
        
        CGPoint c = CGPointMidpoint(a1, a2);
        CGFloat controlAngle = CGPointAngleBetween(c, a1);
        
        CGPoint c1 = CGPointShift(p, controlAngle, d1);
        CGPoint c2 = CGPointShift(p, controlAngle, -d2);
        
        [_currentStrokePoints replaceObjectAtIndex:index-1 withObject:[NSValue valueWithCGPoint:c1]];
        [_currentStrokePoints replaceObjectAtIndex:index+1 withObject:[NSValue valueWithCGPoint:c2]];
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesMoved:touches withEvent:event];
    [_pointInsertionTicker invalidate];
    if ([[_strokes lastObject] count] < 2) {
        [_strokes removeLastObject];
    }
    [self setNeedsDisplay];
}
-(UIBezierPath*)bezierPathForStroke:(NSArray*)points {
    UIBezierPath* path = [UIBezierPath new];
    if (points.count) {
        CGPoint start = [[points objectAtIndex:0] CGPointValue];
        CGPoint prev = start;
        [path moveToPoint:start];
        for (int i=1; i+2<points.count; i+=3) {
            CGPoint c1 = [[points objectAtIndex:i] CGPointValue];
            CGPoint c2 = [[points objectAtIndex:i+1] CGPointValue];
            CGPoint to = [[points objectAtIndex:i+2] CGPointValue];
            CGPoint midpoint = CGPointMidpoint(prev, to);
            if (CGPointIsNull(c1)) {
                c1 = midpoint;
            }
            if (CGPointIsNull(c2)) {
                c2 = midpoint;
            }
            [path addCurveToPoint:to controlPoint1:c1 controlPoint2:c2];
            prev = to;
        }
    }
    return path;
}
-(void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 2);
    for (NSArray* stroke in _strokes) {
        UIBezierPath* path = [self bezierPathForStroke:stroke];
        [path stroke];
    }
}
-(SKPathElement*)pathElementFromStrokes:(NSArray*)strokes {
    CGFloat minX = MAXFLOAT;
    CGFloat minY = MAXFLOAT;
    CGFloat maxX = 0;
    CGFloat maxY = 0;
    for (NSArray* stroke in strokes) {
        for (NSValue* point in stroke) {
            CGPoint p = [point CGPointValue];
            if (!CGPointIsNull(p)) {
                minX = MIN(minX, p.x);
                minY = MIN(minY, p.y);
                maxX = MAX(maxX, p.x);
                maxY = MAX(maxY, p.y);
            }
        }
    }
    
#define SCALED_POINT(p) (CGPointIsNull(p)? CGPointNull : CGPointMake((p.x-minX)/(maxX-minX), (p.y-minY)/(maxY-minY)))
    
    SKPathElement* shape = [SKPathElement new];
    
    //[shape.properties setObject:[NSNumber numberWithBool:YES] forKey:@"strokeShape"];
    //[shape.properties setObject:[UIColor blackColor] forKey:@"strokeColor"];
    //[shape.properties setObject:[NSNumber numberWithDouble:5] forKey:@"strokeWidth"];
    shape.strokes = [NSMutableArray new];
    for (NSArray* strokePoints in strokes) {
        NSMutableArray* lines = [NSMutableArray new];
        if (strokePoints.count) {
            CGPoint prevPoint = [[strokePoints objectAtIndex:0] CGPointValue];
            for (int i=1; i+2<strokePoints.count; i+=3) {
                CGPoint to = [[strokePoints objectAtIndex:i+2] CGPointValue];
                CGPoint c1 = [[strokePoints objectAtIndex:i] CGPointValue];
                CGPoint c2 = [[strokePoints objectAtIndex:i+1] CGPointValue];
                SKLine* line = [SKLine new];
                if (i==1) line.from = SCALED_POINT(prevPoint);
                line.control1 = SCALED_POINT(c1);
                line.control2 = SCALED_POINT(c2);
                line.to = SCALED_POINT(to);
                [lines addObject:line];
                prevPoint = to;
            }
        }
        [shape.strokes addObject:lines];
        /*for (SKLine* line in lines) {
            NSLog(@"From: %@; to: %@; c1: %@; c2: %@", NSStringFromCGPoint(line.from), NSStringFromCGPoint(line.to), NSStringFromCGPoint(line.c1), NSStringFromCGPoint(line.c2));
        }*/
    }
    
    CGRect frame = CGRectMake(minX, minY, maxX-minX, maxY-minY);
    shape.frame = frame;
    
    return shape;
}
#pragma mark API
-(void)addStrokesFromSet:(NSSet*)strokeSet thatOverlap:(NSArray*)toOverlap toSet:(NSMutableSet*)overlapped {
    for (NSArray* stroke in strokeSet) {
        if (![overlapped containsObject:stroke] && [[self bezierPathForStroke:stroke] overlapsPath:[self bezierPathForStroke:toOverlap] withTolerance:10]) {
            [overlapped addObject:stroke];
            [self addStrokesFromSet:strokeSet thatOverlap:stroke toSet:overlapped];
        }
    }
}
-(NSArray*)shapes {
    NSMutableSet* remainingStrokes = [NSMutableSet setWithArray:_strokes];
    NSMutableArray* shapes = [NSMutableArray new];
    while (remainingStrokes.count) {
        NSArray* initialStroke = [remainingStrokes anyObject];
        [remainingStrokes removeObject:initialStroke];
        NSMutableSet* strokesOverlappingStroke = [NSMutableSet setWithObject:initialStroke];
        [self addStrokesFromSet:remainingStrokes thatOverlap:initialStroke toSet:strokesOverlappingStroke];
        for (NSArray* stroke in strokesOverlappingStroke) {
            [remainingStrokes removeObject:stroke];
        }
        SKPathElement* shape = [self pathElementFromStrokes:[strokesOverlappingStroke allObjects]];
        [shapes addObject:shape];
    }
    [shapes sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CGSize size1 = [obj1 frame].size;
        CGSize size2 = [obj2 frame].size;
        if (size1.width*size1.height >= size2.width*size2.height) {
            return NSOrderedAscending;
        } else if (size1.width*size1.height == size2.width*size2.height) {
            return NSOrderedSame;
        } else {
            return NSOrderedDescending;
        }
    }];
    return shapes;
}
-(void)clearCurrentStrokes {
    [_strokes removeAllObjects];
}

@end
