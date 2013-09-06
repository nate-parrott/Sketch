//
//  UIGridViewCell.h
//  UIGridView
//
//  Created by Nate Parrott on 1/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NPGridViewSelectionOverlay.h"
#import <QuartzCore/QuartzCore.h>

@class NPGridView2;
@interface NPGridViewCell : UIView {
	BOOL _selected, _inSelectionMode;
	NPGridViewSelectionOverlay *_selectionOverlay;
	NSTimer *_touchHoldTimer, *_stillCheckTimer, *_dragScrollTimer;
    
    CGPoint _lastSuperviewTouchPosition;
    CGPoint _positionAtLastStillCheck;
    
    BOOL _dragging;
}
-(void)touchHeld;
@property(nonatomic,retain)NSString *reuseIdentifier;
-(NPGridViewCell*)initWithReuseIdentifier:(NSString*)reuseID;
@property(nonatomic)int representsIndex;
@property(nonatomic,assign)NPGridView2 *parentGridView;

-(void)setSelected:(BOOL)selected;
-(BOOL)selected;
-(void)setInSelectionMode:(BOOL)selectionMode;
-(BOOL)isDragging;
@end
