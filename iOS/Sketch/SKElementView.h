//
//  SKRectEditor.h
//  Sketch
//
//  Created by Nate Parrott on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKResizer.h"

@class SKElementView;
@class SKElement;
@protocol SKRectEditorDelegate <NSObject>

-(void)rectDidChange:(SKElementView*)rectEditor fromRect:(CGRect)oldRect;

@end

@interface SKElementView : UIImageView <SKResizerDelegate> {
    NSMutableArray* _touchesDown;
    
    BOOL _drawInProgress, _needsDrawAgain;
    
    CGRect _prevRect;
}

@property(nonatomic)CGRect rect;
@property(assign)id<SKRectEditorDelegate> delegate;
@property(assign,nonatomic)SKElement* correspondsTo; // the model or view this corresponds to; basically a userInfo property
@property(strong)SKResizer* resizer;
@property(nonatomic)BOOL selected;
-(int)numTouchesDown;
@property(nonatomic)CGFloat scale;

@end
