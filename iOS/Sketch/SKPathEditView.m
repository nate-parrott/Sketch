//
//  SKPathEditView.m
//  Sketch
//
//  Created by Nate Parrott on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKPathEditView.h"

#define WIDTH (self.bounds.size.width-_padding*2)
#define HEIGHT (self.bounds.size.height-_padding*2)

#define SELECTED_INDEX (_selectedPointIndex==-1? _points.count-1 : _selectedPointIndex)

@implementation SKPathEditView

-(id)initWithPathElement:(SKPathElement*)pathElement {
    self = [super init];
    _pathElement = pathElement;
    _padding = 50;
    _selectedPointIndex = -1;
    _numSnapGridLines = 20;
    
    self.opaque = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.multipleTouchEnabled = NO;
     
    NSMutableArray* points = [NSMutableArray new];
    NSArray* lines = pathElement.strokes.count? pathElement.strokes.lastObject : nil;
    for (int i=0; i<lines.count; i++) {
        SKLine* line = [lines objectAtIndex:i];
        if (i==0) {
            [points addObject:[NSValue valueWithCGPoint:line.from]];
        }
        [points addObject:[NSValue valueWithCGPoint:line.control1]];
        [points addObject:[NSValue valueWithCGPoint:line.control2]];
        [points addObject:[NSValue valueWithCGPoint:line.to]];
    }
    _points = points;
    
    _gridView = [UIImageView new];
    [self addSubview:_gridView];
    
    _undoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_undoButton setImage:[UIImage imageNamed:@"undo"] forState:UIControlStateNormal];
    _undoButton.adjustsImageWhenDisabled = YES;
    _undoButton.showsTouchWhenHighlighted = YES;
    [self addSubview:_undoButton];
    [_undoButton addTarget:self action:@selector(undo:) forControlEvents:UIControlEventTouchUpInside];
    _undoButton.enabled = NO;
    _undoStack = [NSMutableArray new];
    
    return self;
}
-(void)savePath {    
    NSMutableArray* lines = [NSMutableArray new];
    if (_points.count) {
        for (int i=1; i<_points.count; i+=3) {
            SKLine* line = [SKLine new];
            line.control1 = [[_points objectAtIndex:i] CGPointValue];
            line.control2 = [[_points objectAtIndex:i+1] CGPointValue];
            line.to = [[_points objectAtIndex:i+2] CGPointValue];
            [lines addObject:line];
        }
        [[lines objectAtIndex:0] setFrom:[[_points objectAtIndex:0] CGPointValue]];
    }
    _pathElement.strokes = [NSMutableArray arrayWithObject:lines];
    [_pathElement didUpdate];
}
#pragma mark Undo
-(void)undo:(id)sender {
    _selectedPointIndex = -1;
    _points = [[_undoStack lastObject] mutableCopy];
    [_undoStack removeLastObject];
    _undoButton.enabled = _undoStack.count>0;
    [self setNeedsDisplay];
}
-(void)savePointsForUndo {
    [_undoStack addObject:[_points copy]];
    _undoButton.enabled = YES;
}
#pragma mark Layout
-(CGPoint)toViewCoordinates:(CGPoint)pointInPathCoordinates {
    return CGPointMake(pointInPathCoordinates.x*WIDTH+_padding, pointInPathCoordinates.y*HEIGHT+_padding);
}
-(CGPoint)toPathCoordinates:(CGPoint)pointInViewCoordinates {
    return CGPointMake((pointInViewCoordinates.x-_padding)/WIDTH, (pointInViewCoordinates.y-_padding)/HEIGHT);
}
-(CGPoint)snapToGrid:(CGPoint)touchPoint {
    CGPoint pathCoord = [self toPathCoordinates:touchPoint];
    pathCoord.x = roundf(pathCoord.x * _numSnapGridLines) / _numSnapGridLines;
    pathCoord.y = roundf(pathCoord.y * _numSnapGridLines) / _numSnapGridLines;
    return [self toViewCoordinates:pathCoord];
}
-(void)layoutSubviews {
    _gridView.frame = CGRectInset(self.bounds, _padding, _padding);
    [self drawGrid];
    
    UIImage* undoImage = [UIImage imageNamed:@"undo"];
    CGSize undoSize = CGSizeMake(50, 50);
    _undoButton.frame = CGRectMake(10, self.bounds.size.height-undoSize.height-10, undoSize.width, undoSize.height);
}
#pragma mark Drawing
-(void)drawGrid {
    CGSize gridSize = CGSizeMake(WIDTH*[UIScreen mainScreen].scale, HEIGHT*[UIScreen mainScreen].scale);
    UIGraphicsBeginImageContext(gridSize);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(ctx, CGAffineTransformMakeScale([UIScreen mainScreen].scale, [UIScreen mainScreen].scale));
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0.3 alpha:0.5].CGColor);
    CGFloat xLineDist = WIDTH / _numSnapGridLines;
    CGFloat yLineDist = HEIGHT / _numSnapGridLines;
    for (int i=1; i<_numSnapGridLines; i++) {
        CGContextMoveToPoint(ctx, i*xLineDist, 0);
        CGContextAddLineToPoint(ctx, i*xLineDist, HEIGHT);
        CGContextStrokePath(ctx);
        
        CGContextMoveToPoint(ctx, 0, i*yLineDist);
        CGContextAddLineToPoint(ctx, WIDTH, i*yLineDist);
        CGContextStrokePath(ctx);
    }
    _gridView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}
-(CGPoint)effectivePointForPointAtIndex:(int)i {
    if (CGPointIsNull([[_points objectAtIndex:i] CGPointValue])) {
        int offsetFromPrevPoint = i%3;
        CGPoint from = [[_points objectAtIndex:i-offsetFromPrevPoint] CGPointValue];
        CGPoint to = [[_points objectAtIndex:i+(3-offsetFromPrevPoint)] CGPointValue];
        return CGPointMake((from.x+to.x)/2, (from.y+to.y)/2);
    } else {
        return [[_points objectAtIndex:i] CGPointValue];
    }
}
-(void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGContextStrokeRect(ctx, CGRectMake(_padding, _padding, WIDTH, HEIGHT));
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.8 alpha:1].CGColor);
    CGContextSetLineWidth(ctx, 2);
    if (_points.count>0) {
        CGPoint startPoint = [self toViewCoordinates:[[_points objectAtIndex:0] CGPointValue]];
        CGContextMoveToPoint(ctx, startPoint.x, startPoint.y);
    }
    for (int i=1; i<_points.count; i+=3) {
        CGPoint c1 = [self toViewCoordinates:[self effectivePointForPointAtIndex:i]];
        CGPoint c2 = [self toViewCoordinates:[self effectivePointForPointAtIndex:i+1]];
        CGPoint to = [self toViewCoordinates:[[_points objectAtIndex:i+2] CGPointValue]];
        CGContextAddCurveToPoint(ctx, c1.x, c1.y, c2.x, c2.y, to.x, to.y);
    }
    CGContextDrawPath(ctx, kCGPathEOFillStroke);
    
    // draw lines from control points to line points
    CGContextSaveGState(ctx);
    CGContextSetStrokeColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGFloat dash[] = {2,2};
    CGContextSetLineDash(ctx, 0, dash, 2);
    for (int i=1; i+2<_points.count; i+=3) {
        if (!CGPointIsNull([[_points objectAtIndex:i] CGPointValue])) {
            CGPoint from = [self toViewCoordinates:[self effectivePointForPointAtIndex:i-1]];
            CGPoint c1 = [self toViewCoordinates:[self effectivePointForPointAtIndex:i]];
            CGContextBeginPath(ctx);
            CGContextMoveToPoint(ctx, from.x, from.y);
            CGContextAddLineToPoint(ctx, c1.x, c1.y);
            CGContextClosePath(ctx);
            CGContextStrokePath(ctx);
        }
        if (!CGPointIsNull([[_points objectAtIndex:i+1] CGPointValue])) {
            CGPoint c2 = [self toViewCoordinates:[self effectivePointForPointAtIndex:i+1]];
            CGPoint to = [self toViewCoordinates:[[_points objectAtIndex:i+2] CGPointValue]];
            CGContextBeginPath(ctx);
            CGContextMoveToPoint(ctx, to.x, to.y);
            CGContextAddLineToPoint(ctx, c2.x, c2.y);
            CGContextClosePath(ctx);
            CGContextStrokePath(ctx);
        }
    }
    CGContextRestoreGState(ctx);
    
    // draw circles at points:
    for (int i=0; i<_points.count; i++) {
        CGFloat radius = 7;
        UIColor* color = [UIColor blueColor];
        if (i%3==1 || i%3==2) { // control point
            radius = 5;
            color = [UIColor grayColor];
        }
        CGPoint p = [self toViewCoordinates:[self effectivePointForPointAtIndex:i]];
        CGContextSetFillColorWithColor(ctx, [[color colorWithAlphaComponent:0.5] CGColor]);
        CGContextFillEllipseInRect(ctx, CGRectMake(p.x-radius, p.y-radius, radius*2, radius*2));
        if (i == SELECTED_INDEX) {
            CGContextSetLineWidth(ctx, 2);
            CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
            CGContextStrokeEllipseInRect(ctx, CGRectMake(p.x-radius, p.y-radius, radius*2, radius*2));
        }
    }
}
#pragma mark Touch handling
-(int)indexOfPathPointAtPoint:(CGPoint)touchPoint {
    CGFloat maxDistance = 25;
    for (int i=0; i<_points.count; i++) {
        CGPoint point = [self toViewCoordinates:[self effectivePointForPointAtIndex:i]];
        CGFloat distance = sqrtf(powf(point.x-touchPoint.x, 2) + powf(point.y-touchPoint.y, 2));
        if (distance <= maxDistance) {
            return i;
        }
    }
    return -1;
}
-(void)addLineWithTouchPoint:(CGPoint)point {
    int indexOfFirstPointInCurrentLine = SELECTED_INDEX - (SELECTED_INDEX%3);
    if (_points.count==0) {
        [_points addObject:[NSValue valueWithCGPoint:[self toPathCoordinates:point]]];
        [_points addObject:[NSValue valueWithCGPoint:CGPointNull]];
        [_points addObject:[NSValue valueWithCGPoint:CGPointNull]];
        [_points addObject:[NSValue valueWithCGPoint:[self toPathCoordinates:point]]];
        _selectedPointIndex = 3;
    } else if (indexOfFirstPointInCurrentLine==0) {
        [_points insertObject:[NSValue valueWithCGPoint:[self toPathCoordinates:point]] atIndex:0];
        [_points insertObject:[NSValue valueWithCGPoint:CGPointNull] atIndex:1];
        [_points insertObject:[NSValue valueWithCGPoint:CGPointNull] atIndex:2];
        _selectedPointIndex = 0;
    } else {
        [_points insertObject:[NSValue valueWithCGPoint:CGPointNull] atIndex:indexOfFirstPointInCurrentLine+1];
        [_points insertObject:[NSValue valueWithCGPoint:CGPointNull] atIndex:indexOfFirstPointInCurrentLine+2];
        [_points insertObject:[NSValue valueWithCGPoint:[self toPathCoordinates:point]] atIndex:indexOfFirstPointInCurrentLine+3];
        _draggingBothControlPoints = YES;
        _selectedPointIndex = indexOfFirstPointInCurrentLine+3;
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self savePointsForUndo];
    
    _lastTouchPoint = [[touches anyObject] locationInView:self];
    if ([[UIMenuController sharedMenuController] isMenuVisible]) {
        [[UIMenuController sharedMenuController] setMenuVisible:NO];
    }
    CGPoint point = [[touches anyObject] locationInView:self];
    int newSelectedPoint = [self indexOfPathPointAtPoint:point];
    if (newSelectedPoint==-1) { // touched area was empty; create a new point off the current one and begin freehand point insertion
        [self addLineWithTouchPoint:[self snapToGrid:point]];
        _movingExistingPoint = YES;
        _actedOnTouch = YES;
        /*_movingExistingPoint = NO;
        _ticksUntilDontCurveLastPoint = 0;
        _actedOnTouch = YES;
        _freehandPathTickTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(freehandPathTick) userInfo:nil repeats:YES];*/
    } else {
        _selectedPointIndex = newSelectedPoint;
        _movingExistingPoint = YES;
        _actedOnTouch = NO;
    }
    _pointMovementCancelled = NO;
    [self setNeedsDisplay];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_pointMovementCancelled) {return;}
    _lastTouchPoint = [[touches anyObject] locationInView:self];
    _actedOnTouch = YES;
    CGPoint point = [self snapToGrid:[[touches anyObject] locationInView:self]];
    if (_movingExistingPoint) {
        if (_draggingBothControlPoints) {
            [_points replaceObjectAtIndex:_selectedPointIndex-2 withObject:[NSValue valueWithCGPoint:[self toPathCoordinates:point]]];
            [_points replaceObjectAtIndex:_selectedPointIndex-1 withObject:[NSValue valueWithCGPoint:[self toPathCoordinates:point]]];
        } else {
            [_points replaceObjectAtIndex:_selectedPointIndex withObject:[NSValue valueWithCGPoint:[self toPathCoordinates:point]]];

        }
        [self setNeedsDisplay];
    }
}
-(void)freehandPathTick {
    CGPoint pointInPathCoords = [self toPathCoordinates:_lastTouchPoint];//[self toPathCoordinates:[self snapToGrid:_lastTouchPoint]];
    if (CGPointEqualToPoint([[_points objectAtIndex:_selectedPointIndex] CGPointValue], pointInPathCoords)) {
        _ticksUntilDontCurveLastPoint--;
    } else {
        int prevSelectedIndex = _selectedPointIndex;
        [self addLineWithTouchPoint:[self toViewCoordinates:pointInPathCoords]];
        if (_ticksUntilDontCurveLastPoint > 0) {
            [self curveAroundPointAtIndex:prevSelectedIndex];
        }
        _ticksUntilDontCurveLastPoint = 3;
    }
    [self setNeedsDisplay];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [_freehandPathTickTimer invalidate];
    _draggingBothControlPoints = NO;
    if (!_movingExistingPoint && _ticksUntilDontCurveLastPoint>0) {
        [self curveAroundPointAtIndex:_selectedPointIndex];
        [self setNeedsDisplay];
    }
    if (!_actedOnTouch) {
        [self showMenuForSelectedPoint];
    }
}
#pragma mark Point editing
-(BOOL)canBecomeFirstResponder {
    return YES;
}
-(void)showMenuForSelectedPoint {
    [self becomeFirstResponder];
    UIMenuController* menuController = [UIMenuController sharedMenuController];
    CGRect targetRect;
    targetRect.origin = [self toViewCoordinates:[[_points objectAtIndex:_selectedPointIndex] CGPointValue]];
    targetRect.size = CGSizeZero;
    [menuController setTargetRect:targetRect inView:self];
    [menuController setMenuVisible:YES animated:YES];
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(delete:)) {
        return _points.count>1 && _selectedPointIndex!=-1;
    } else {
        return NO;
    }
}
-(void)delete:(id)sender {
    [self deleteSelectedPoint];
}
-(void)deleteSelectedPoint {
    if (_points.count<=1) {
        return;
    }
    int indexOfFirstPointInCurrentLine = SELECTED_INDEX - (SELECTED_INDEX%3);
    if (indexOfFirstPointInCurrentLine==_points.count-1) {
        [_points removeObjectsInRange:NSMakeRange(indexOfFirstPointInCurrentLine-2, 3)];
    } else {
        [_points removeObjectsInRange:NSMakeRange(indexOfFirstPointInCurrentLine, 3)];
    }
    _selectedPointIndex = -1;
    _pointMovementCancelled = YES;
    [self setNeedsDisplay];
}
-(void)curveAroundPointAtIndex:(int)index {
    CGPoint p = [[_points objectAtIndex:index] CGPointValue];
    
    int nextPointIdx = index+3;
    int prevPointIdx = index-3;
    if (prevPointIdx >= 0 && nextPointIdx < _points.count) {
        CGPoint p1 = [[_points objectAtIndex:prevPointIdx] CGPointValue];
        CGPoint p2 = [[_points objectAtIndex:nextPointIdx] CGPointValue];
        
        CGPoint a1 = CGPointMidpoint(p, p1);
        CGPoint a2 = CGPointMidpoint(p, p2);
        
        CGFloat d = CGPointDistance(a1, a2);
        CGFloat d1 = d*CGPointDistance(p, p1) / (CGPointDistance(p, p1) + CGPointDistance(p, p2));
        CGFloat d2 = d*CGPointDistance(p, p2) / (CGPointDistance(p, p1) + CGPointDistance(p, p2));
        
        CGPoint c = CGPointMidpoint(a1, a2);
        CGFloat controlAngle = CGPointAngleBetween(c, a1);
        
        CGPoint c1 = CGPointShift(p, controlAngle, d1);
        CGPoint c2 = CGPointShift(p, controlAngle, -d2);
        
        [_points replaceObjectAtIndex:index-1 withObject:[NSValue valueWithCGPoint:c1]];
        [_points replaceObjectAtIndex:index+1 withObject:[NSValue valueWithCGPoint:c2]];
    }
    
    /*int prevPointIdx = index-3;
    int nextControlPointIdx = index+1;
    if (prevPointIdx >= 0 && nextControlPointIdx < _points.count) {
        CGPoint prevPoint = [[_points objectAtIndex:prevPointIdx] CGPointValue];
        CGPoint newNextControlPoint = CGPointShift(point, CGPointAngleBetween(point, prevPoint), CGPointDistance(point, prevPoint)*-0.5);
        [_points replaceObjectAtIndex:nextControlPointIdx withObject:[NSValue valueWithCGPoint:newNextControlPoint]];
    }
    
    int nextPointIdx = index+3;
    int prevControlPointIdx = index-1;
    if (prevControlPointIdx >=0 && nextControlPointIdx < _points.count) {
        CGPoint nextPoint = [[_points objectAtIndex:nextPointIdx] CGPointValue];
        CGPoint newPrevControlPoint = CGPointShift(point, CGPointAngleBetween(point, nextPoint), CGPointDistance(point, nextPoint)*-0.5);
        [_points replaceObjectAtIndex:prevControlPointIdx withObject:[NSValue valueWithCGPoint:newPrevControlPoint]];
    }*/
}
@end
