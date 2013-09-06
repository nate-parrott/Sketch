//
//  SKPenOverlayView.h
//  Sketch
//
//  Created by Nate Parrott on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKPenOverlayView : UIView {
    NSMutableArray* _strokes;
    NSMutableArray* _currentStrokePoints;
    CGPoint _lastTouchPoint;
    NSTimer* _pointInsertionTicker;
    UIButton* _undoButton;
}
-(NSArray*)shapes;
-(void)clearCurrentStrokes;
@property CGFloat smoothing; // in seconds

@end
