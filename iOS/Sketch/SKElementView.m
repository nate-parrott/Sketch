//
//  SKRectEditor.m
//  Sketch
//
//  Created by Nate Parrott on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKElementView.h"
#import "UIView+FreezeScrolling.h"
#import "SKElement.h"

@implementation SKElementView
@synthesize delegate=_delegate;
@synthesize correspondsTo=_correspondsTo;
-(void)setCorrespondsTo:(SKElement *)correspondsTo {
    _correspondsTo = correspondsTo;
    self.selected = _correspondsTo.selected;
}
@synthesize resizer=_resizer;

#pragma mark Touch handling
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return [self.correspondsTo hitTest:CGPointMake(point.x+self.frame.origin.x, point.y+self.frame.origin.y)];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_touchesDown) {
        _touchesDown = [NSMutableArray new];
    }
    [_touchesDown addObjectsFromArray:[touches allObjects]];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_touchesDown.count==1) {
        CGPoint curPoint = [[touches anyObject] locationInView:self.superview];
        CGPoint prevPoint = [[touches anyObject] previousLocationInView:self.superview];
        CGPoint translation = CGPointMake(curPoint.x-prevPoint.x, curPoint.y-prevPoint.y);
        CGRect rect = self.rect;
        rect.origin.x += translation.x;
        rect.origin.y += translation.y;
        self.rect = rect;
        [self.delegate rectDidChange:self fromRect:_prevRect];
    } else if (_touchesDown.count==2) {
        CGPoint currentMin = CGPointMake(MAXFLOAT, MAXFLOAT);
        CGPoint currentMax = CGPointZero;
        CGPoint prevMin = CGPointMake(MAXFLOAT, MAXFLOAT);
        CGPoint prevMax = CGPointZero;
        for (UITouch* touch in _touchesDown) {
            CGPoint cur = [touch locationInView:self.superview];
            currentMin.x = MIN(currentMin.x, cur.x);
            currentMin.y = MIN(currentMin.y, cur.y);
            currentMax.x = MAX(currentMax.x, cur.x);
            currentMax.y = MAX(currentMax.y, cur.y);
            
            CGPoint prev = [touch previousLocationInView:self.superview];
            prevMin.x = MIN(prevMin.x, prev.x);
            prevMin.y = MIN(prevMin.y, prev.y);
            prevMax.x = MAX(prevMax.x, prev.x);
            prevMax.y = MAX(prevMax.y, prev.y);
        }
        CGPoint originTranslation = CGPointMake(currentMin.x-prevMin.x, currentMin.y-prevMin.y);
        CGRect rect = self.rect;
        rect.origin.x += originTranslation.x;
        rect.origin.y += originTranslation.y;
        rect.size.width -= originTranslation.x;
        rect.size.height -= originTranslation.y;
        
        CGPoint lowerRightCornerTranslation = CGPointMake(currentMax.x-prevMax.x, currentMax.y-prevMax.y);
        rect.size.width += lowerRightCornerTranslation.x;
        rect.size.height += lowerRightCornerTranslation.y;
        
        self.rect = rect; // trigger reposition
        
        [self.delegate rectDidChange:self fromRect:_prevRect];
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch* touch in touches) {
        [_touchesDown removeObject:touch];
    }
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}
-(int)numTouchesDown {
    return _touchesDown.count;
}
#pragma mark Setup/data
-(id)init {
    self = [super init];
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
    return self;
}
@synthesize rect=_rect;
-(void)setRect:(CGRect)rect {
    _prevRect = _rect;
    _rect = rect;
    self.frame = rect;
    self.resizer.size = rect.size;
}
-(void)didResize:(SKResizer *)resizer {
    self.rect = CGRectMake(self.frame.origin.x, self.frame.origin.y, resizer.size.width, resizer.size.height);
    [self.delegate rectDidChange:self fromRect:_prevRect];
}
#pragma mark Drawing
@synthesize scale=_scale;
-(void)setScale:(CGFloat)scale {
    _scale = scale;
    [self setNeedsDisplay];
}
/*-(void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //CGContextSetAllowsAntialiasing(ctx, NO);
    [self.correspondsTo _draw];
}*/
-(void)setNeedsDisplay {
    [super setNeedsDisplay];
    if (_drawInProgress) {
        _needsDrawAgain = YES;
    } else {
        _drawInProgress = YES;
        [self performSelectorInBackground:@selector(draw) withObject:nil];
    }
}
-(void)draw {
    @autoreleasepool {
        CGFloat scale = [UIScreen mainScreen].scale*self.scale;
        UIGraphicsBeginImageContext(CGSizeMake(self.frame.size.width*scale, self.frame.size.height*scale));
        CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformMakeScale(scale, scale));
        [self.correspondsTo _draw];
        UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self performSelectorOnMainThread:@selector(didDraw:) withObject:image waitUntilDone:NO];
    }
}
-(void)didDraw:(UIImage*)image {
    _drawInProgress = NO;
    self.image = image;
    if (_needsDrawAgain) {
        _needsDrawAgain = NO;
        _drawInProgress = YES;
        [self performSelectorInBackground:@selector(draw) withObject:nil];
    }
}
@synthesize selected=_selected;
-(void)setSelected:(BOOL)selected {
    if (selected==_selected) return;
    _selected = selected;
    /*if (selected) {
        self.layer.borderWidth = 1;
        CABasicAnimation* selectionAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
        [selectionAnimation setAutoreverses:YES];
        [selectionAnimation setDuration:0.7];
        [selectionAnimation setRepeatCount:HUGE_VALF];
        [selectionAnimation setFromValue:(id)[UIColor colorWithRed:1 green:0.5 blue:0 alpha:1].CGColor];
        [selectionAnimation setToValue:(id)[UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor];
        [selectionAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.layer addAnimation:selectionAnimation forKey:@"selectionAnimation"];
    } else {
        self.layer.borderWidth = 0;
        [self.layer removeAnimationForKey:@"selectionAnimation"];
    }*/
}

@end
