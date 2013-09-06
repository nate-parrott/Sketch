//
//  SKPathEditView.h
//  Sketch
//
//  Created by Nate Parrott on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKPathElement.h"

@interface SKPathEditView : UIView {
    SKPathElement* _pathElement;
    
    CGFloat _padding;
    NSMutableArray* _points; // from, (control1, control2, to)+ ; control points may be null
    int _selectedPointIndex;
    BOOL _draggingBothControlPoints;
    CGFloat _numSnapGridLines;
    BOOL _pointMovementCancelled;
    
    BOOL _actedOnTouch;
    BOOL _movingExistingPoint;
    CGPoint _lastTouchPoint;
    NSTimer* _freehandPathTickTimer;
    int _ticksUntilDontCurveLastPoint;
    
    UIImageView* _gridView;
    
    NSMutableArray* _undoStack;
    UIButton* _undoButton;
}

-(id)initWithPathElement:(SKPathElement*)pathElement;
-(void)savePath;

@end
