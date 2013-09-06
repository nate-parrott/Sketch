//
//  SKFrameEditor.m
//  Sketch
//
//  Created by Nate Parrott on 9/19/12.
//
//

#import "SKFrameEditor.h"
#import "SKImageEditorView+PositionSnapping.h"
#import "CGPointExtras.h"

const CGFloat SKFrameEditorHandleDiameter = 15;
const CGFloat SKFrameEditorHandleTouchRadius = 20;

@implementation SKFrameEditor

@synthesize delegate=_delegate;
@synthesize imageView=_imageView;
@synthesize scale=_scale;

-(id)init {
    self = [super init];
    NSMutableArray* handles = [NSMutableArray new];
    for (int i=0; i<8; i++) {
        UIView* handle = [UIView new];
        handle.userInteractionEnabled = NO;
        /*handle.layer.borderWidth = 2;
         handle.layer.borderColor = [UIColor whiteColor].CGColor;
         handle.backgroundColor = [UIColor blueColor];
        handle.layer.shadowColor = [UIColor blackColor].CGColor;
        handle.layer.shadowOffset = CGSizeZero;*/
        handle.backgroundColor = [UIColor blackColor];
        [self addSubview:handle];
        [handles addObject:handle];
    }
    _handles = handles;
    [self setScale:1];
    _touchesDown = [NSMutableArray new];
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 1;
    return self;
}

@synthesize rect=_rect;
-(void)setRect:(CGRect)rect {
    _rect = rect;
    self.frame = rect;
}
-(void)setScale:(CGFloat)scale {
    _scale = scale;
    for (UIView* handle in _handles) {
        CGPoint center = handle.center;
        handle.frame = CGRectMake(0, 0, SKFrameEditorHandleDiameter/scale, SKFrameEditorHandleDiameter/scale);
        handle.layer.cornerRadius = SKFrameEditorHandleDiameter/scale/2;
        /*handle.layer.shadowPath = [[UIBezierPath bezierPathWithOvalInRect:handle.bounds] CGPath];
        handle.layer.shadowOpacity = 1/scale;
        handle.layer.shadowRadius = 2/scale;*/
        handle.center = center;
    }
    [self setNeedsDisplay];
}
-(void)layoutSubviews {
    [super layoutSubviews];
    int i = 0;
    for (int x=0; x<3; x++) {
        for (int y=0; y<3; y++) {
            if (! (x==1 && y==1)) {
                UIView* handle = _handles[i];
                handle.center = CGPointMake(x*self.bounds.size.width/2, y*self.bounds.size.height/2);
                i++;
            }
        }
    }
}
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView* handle in _handles) {
        if (CGPointDistance(point, handle.center) <= SKFrameEditorHandleTouchRadius/_scale) {
            return YES;
        }
    }
    return NO;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_touchesDown addObjectsFromArray:[touches allObjects]];
    if (_touchesDown.count==1) {
        CGPoint pointInView = [_touchesDown[0] locationInView:self];
        
        memset(&_dragging, 0, sizeof(_dragging));
        _dragging.leftEdge = pointInView.x < SKFrameEditorHandleDiameter;
        _dragging.rightEdge = pointInView.x > self.bounds.size.width-SKFrameEditorHandleDiameter;
        
        _dragging.topEdge = pointInView.y < SKFrameEditorHandleDiameter;
        _dragging.bottomEdge = pointInView.y > self.bounds.size.height-SKFrameEditorHandleDiameter;
        
        _frameAtStartOfTouch = self.rect;
        CGPoint pos = [_touchesDown[0] locationInView:self.superview];
        _initialTouchPos = pos;
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint pos = [[touches anyObject] locationInView:self.superview];
    //CGPoint lastPos = [[touches anyObject] previousLocationInView:self.superview];
    CGPoint translation = CGPointMake(pos.x-_initialTouchPos.x, pos.y-_initialTouchPos.y);
    CGRect newRect = _frameAtStartOfTouch;
    if (_dragging.leftEdge) {
        CGPoint leftEdge = CGPointMake(newRect.origin.x + translation.x, 0);
        CGPoint newLeftEdge = [self.imageView snapPoint:leftEdge withTolerance:CGPointStandardSnappingThreshold/self.scale fromOriginalPoint:leftEdge];
        CGFloat newTranslation = newLeftEdge.x - newRect.origin.x;
        newRect.origin.x += newTranslation;
        newRect.size.width -= newTranslation;
    }
    if (_dragging.rightEdge) {
        CGPoint rightEdge = CGPointMake(newRect.origin.x+newRect.size.width+translation.x, 0);
        CGPoint newRightEdge = [self.imageView snapPoint:rightEdge withTolerance:CGPointStandardSnappingThreshold/self.scale fromOriginalPoint:rightEdge];
        CGFloat newTranslation = newRightEdge.x - newRect.origin.x - newRect.size.width;
        newRect.size.width += newTranslation;
    }
    if (_dragging.topEdge) {
        CGPoint topEdge = CGPointMake(0, newRect.origin.y + translation.y);
        CGPoint newLeftEdge = [self.imageView snapPoint:topEdge withTolerance:CGPointStandardSnappingThreshold/self.scale fromOriginalPoint:topEdge];
        CGFloat newTranslation = newLeftEdge.y - newRect.origin.y;
        newRect.origin.y += newTranslation;
        newRect.size.height -= newTranslation;
    }
    if (_dragging.bottomEdge) {
        CGPoint bottomEdge = CGPointMake(0, newRect.origin.y+newRect.size.height+translation.y);
        CGPoint newBottomEdge = [self.imageView snapPoint:bottomEdge withTolerance:CGPointStandardSnappingThreshold/self.scale fromOriginalPoint:bottomEdge];
        CGFloat newTranslation = newBottomEdge.y - newRect.origin.y - newRect.size.height;
        newRect.size.height += newTranslation;
    }
    CGRect oldRect = self.rect;
    self.rect = newRect;
    [self.delegate frameEditor:self didChangeFrameFrom:oldRect toFrame:newRect];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [_touchesDown removeObjectsInArray:touches.allObjects];

}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [_touchesDown removeObjectsInArray:touches.allObjects];
}



@end
