//
//  UIGridViewCell.m
//  UIGridView
//
//  Created by Nate Parrott on 1/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NPGridViewCell.h"
#import "NPGridView2.h"
#import "CGPointExtras.h"

@implementation NPGridViewCell
@synthesize representsIndex, reuseIdentifier, parentGridView;

-(NPGridViewCell*)initWithReuseIdentifier:(NSString*)reuseID {
	[super init];
	self.reuseIdentifier = reuseID;
	[self setOpaque:NO];
	return self;
}
-(void)setSelected:(BOOL)selected {
	if (selected==_selected) {
		return;
	}
	_selected = selected;
	if (_selected) {
		_selectionOverlay = [[NPGridViewSelectionOverlay alloc] initWithFrame:self.frame];
		_selectionOverlay.cell = self;
		_selectionOverlay.opaque = NO;
		[self.superview addSubview:[_selectionOverlay autorelease]];
	} else {
		[_selectionOverlay removeFromSuperview];
		_selectionOverlay = nil;
	}
}
-(BOOL)selected {
	return _selected;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)layoutSubviews {
    if (_selected)
        _selectionOverlay.frame = self.bounds;
}
- (void)dealloc {
	if (_selectionOverlay) {
		[_selectionOverlay removeFromSuperview];
	}
    [super dealloc];
}
/*-(void)_stillCheck {
    if (CGPointDistance(_positionAtLastStillCheck, self.center)<10) {
        [parentGridView cellDidMove:self mustReposition:NO];
    }
    _positionAtLastStillCheck = self.center;
}*/
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _lastSuperviewTouchPosition = [[touches anyObject] locationInView:self.superview];
	_touchHoldTimer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(touchHeld) userInfo:nil repeats:NO];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self.superview];
    if (_dragging) {
        if (!CGPointEqualToPoint(_lastSuperviewTouchPosition, CGPointZero)) {
            CGPoint difference = CGPointMake(_lastSuperviewTouchPosition.x-touchPoint.x, _lastSuperviewTouchPosition.y-touchPoint.y);
            self.center = CGPointMake(self.center.x-difference.x, self.center.y-difference.y);
        }
    }
    if (_touchHoldTimer && CGPointDistance(touchPoint, _lastSuperviewTouchPosition)>10) {
        [_touchHoldTimer invalidate];
        _touchHoldTimer = nil;
    }
    _lastSuperviewTouchPosition = touchPoint;
}
-(BOOL)isDragging {
    return _dragging;
}
const float dragScrollCheckInterval = 0.02;
-(void)_dragScrollCheck:(id)sender {
    CGFloat scrollThreshold = 42;
    CGFloat scrollSpeedPerPixelPerSecond = 5;
    CGFloat pixelsInThreshold = 0;
    if (_lastSuperviewTouchPosition.y<[parentGridView scrollView].contentOffset.y+scrollThreshold) {
        pixelsInThreshold = _lastSuperviewTouchPosition.y-[parentGridView scrollView].contentOffset.y+scrollThreshold;
    } else if (_lastSuperviewTouchPosition.y>[parentGridView scrollView].contentOffset.y+[parentGridView scrollView].frame.size.height-scrollThreshold) {
        pixelsInThreshold = [parentGridView scrollView].contentOffset.y+[parentGridView scrollView].frame.size.height-scrollThreshold-_lastSuperviewTouchPosition.y;
    }
    NSLog(@"[parentGridView scrollView].contentOffset.y=%f;\n _lastSuperviewTouchPosition.y=%f;\n pixel difference:%f\n",[parentGridView scrollView].contentOffset.y,_lastSuperviewTouchPosition.y,pixelsInThreshold);
    if (pixelsInThreshold!=0) {
        CGPoint contentOffsetDifference = CGPointMake(0, pixelsInThreshold*dragScrollCheckInterval*scrollSpeedPerPixelPerSecond);
        CGPoint newContentOffset = CGPointMake([[self parentGridView] scrollView].contentOffset.x-contentOffsetDifference.x, [[self parentGridView] scrollView].contentOffset.y-contentOffsetDifference.y);
        if (newContentOffset.y<0 ||
            newContentOffset.y>[[self parentGridView] scrollView].contentSize.height)
            return;
        [[self parentGridView] scrollView].contentOffset = newContentOffset;
        self.center = CGPointMake(self.center.x-contentOffsetDifference.x, self.center.y-contentOffsetDifference.y);
        _lastSuperviewTouchPosition.x-=contentOffsetDifference.x;
        _lastSuperviewTouchPosition.y-=contentOffsetDifference.y;
    }
}
-(void)doneDragging {
    _dragging = NO;
    [parentGridView cellDidMove:self mustReposition:YES];
    [_stillCheckTimer invalidate];
    [_dragScrollTimer invalidate];
    _stillCheckTimer = nil;
    _dragScrollTimer = nil;
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.alpha = 1.0;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
    [[parentGridView scrollView] setScrollEnabled:YES];
}
-(void)startDragging {
    _dragging = YES;
    [[parentGridView scrollView] setScrollEnabled:NO];
    _positionAtLastStillCheck = CGPointZero;
    //_stillCheckTimer =[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_stillCheck) userInfo:nil repeats:YES];
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.alpha = 0.6;
        self.transform = CGAffineTransformMakeScale(1.6, 1.6);
    }];
    _dragScrollTimer = [NSTimer scheduledTimerWithTimeInterval:dragScrollCheckInterval target:self selector:@selector(_dragScrollCheck:) userInfo:nil repeats:YES];
}
-(void)touchHeld {
	if (!_inSelectionMode) {
        if ([parentGridView supportsSelectionMode]) {
            NSArray *options = [[parentGridView delegate] selectionModeOptionsForGridView:parentGridView];
            [parentGridView enterSelectionModeWithOptions:options];
        }
    }
    if (_inSelectionMode && [parentGridView supportsReordering]) {//start reordering
        [self startDragging];
    } else if ([parentGridView.delegate respondsToSelector:@selector(gridView:heldDownCellAtIndex:)]) {
        [parentGridView.delegate gridView:parentGridView heldDownCellAtIndex:representsIndex];
    }
    _touchHoldTimer = nil;
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	if (_touchHoldTimer) {
		[_touchHoldTimer invalidate];
	}
    if (_dragging) {
        [self doneDragging];
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (_touchHoldTimer) {
		[_touchHoldTimer invalidate];
		[parentGridView _clickedCell:self];
	}
    if (_dragging) {
        [self doneDragging];
    }
}
float frand() {
    return (float)(rand()-RAND_MAX/2)/(float)RAND_MAX;
}
-(void)addWobble {
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^(void) {
        if (![self isDragging])
            self.transform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(M_PI*0.04*frand()), 2.0*frand(), 2.0*frand());
    } completion:^(BOOL finished) {
        if (_inSelectionMode)
            [self addWobble];
        else {
            [UIView animateWithDuration:0.15 animations:^(void) {
                self.transform = CGAffineTransformIdentity;
            }];
        }
    }];
}
-(void)setInSelectionMode:(BOOL)selectionMode {
    if (selectionMode==_inSelectionMode)
        return;
    _inSelectionMode = selectionMode;
    if (_inSelectionMode) {
        [self addWobble];
    } else {
        
    }
}
-(void)setFrame:(CGRect)frame {
    CGAffineTransform transform = self.transform;
    self.transform = CGAffineTransformIdentity;
    [super setFrame:frame];
    self.transform = transform;
}
@end
