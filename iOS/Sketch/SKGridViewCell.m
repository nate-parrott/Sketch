//
//  SKGridViewCell.m
//  Sketch
//
//  Created by Nate Parrott on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKGridViewCell.h"
#import "SKGridView.h"

@implementation SKGridViewCell

@synthesize reuseIdentifier=_reuseIdentifier;
-(id)initWithReuseIdentifier:(NSString*)reuseID {
    self = [super init];
    _reuseIdentifier = reuseID;
    _overlay = [UIButton buttonWithType:UIButtonTypeCustom];
    [_overlay addTarget:self action:@selector(clickedOverlay) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_overlay];
    return self;
}
-(void)layoutSubviews {
    if ([self.subviews lastObject]!=_overlay) {
        [_overlay removeFromSuperview];
        [self addSubview:_overlay];
    }
    _overlay.frame = self.bounds;
}
@synthesize parentGridView=_parentGridView;
@synthesize inSelectionMode=_inSelectionMode;
-(void)setInSelectionMode:(BOOL)inSelectionMode {
    _inSelectionMode = inSelectionMode;
    [self updateOverlayImage];
}
@synthesize selected=_selected;
-(void)setSelected:(BOOL)selected {
    _selected = selected;
    [self updateOverlayImage];
}
@synthesize overlay=_overlay;
-(void)clickedOverlay {
    [self.parentGridView clickedCell:self];
}
-(void)updateOverlayImage {
    UIImage* image = nil;
    if (self.inSelectionMode) {
        if (self.selected) {
            image = [[UIImage imageNamed:@"overlaySelected"] stretchableImageWithLeftCapWidth:40 topCapHeight:40];
        } else {
            image = [[UIImage imageNamed:@"overlayDeselected"] stretchableImageWithLeftCapWidth:40 topCapHeight:40];
        }
    } else {
        image = nil;
    }
    [_overlay setBackgroundImage:image forState:UIControlStateNormal];
}
@end
