//
//  SKScrollViewLocker.m
//  Sketch
//
//  Created by Nate Parrott on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKScrollViewLocker.h"

@implementation SKScrollViewLocker
@synthesize scrollView=_scrollView;

-(void)willMoveToWindow:(UIWindow *)newWindow {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.showsTouchWhenHighlighted = YES;
        [self addSubview:_button];
        [_button addTarget:self action:@selector(toggleLock) forControlEvents:UIControlEventTouchUpInside];
        [self updateButtonState];
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
}
-(void)layoutSubviews {
    _button.frame = self.bounds;
    _button.contentEdgeInsets = UIEdgeInsetsMake(self.bounds.size.height*0.1, self.bounds.size.width*0.1, self.bounds.size.height*0.1, self.bounds.size.width*0.1);
}
-(void)updateButtonState {
    if (self.scrollView.scrollEnabled) {
        [_button setImage:[UIImage imageNamed:@"scrollViewLockOff.png"] forState:UIControlStateNormal];
    } else {
        [_button setImage:[UIImage imageNamed:@"scrollViewLockOn.png"] forState:UIControlStateNormal];
    }
}
-(void)toggleLock {
    self.scrollView.scrollEnabled = !self.scrollView.scrollEnabled;
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationTransition:(self.scrollView.scrollEnabled? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft) forView:_button cache:YES];
        [self updateButtonState];
    }];
}

@end
