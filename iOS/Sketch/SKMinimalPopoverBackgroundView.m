//
//  SKMinimalPopoverBackgroundView.m
//  Sketch
//
//  Created by Nate Parrott on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKMinimalPopoverBackgroundView.h"

@implementation SKMinimalPopoverBackgroundView

-(void)setup {
    _setupYet = YES;
    UIImage* backgroundImage = [UIImage imageNamed:@"popoverBackground"];
    UIImage* backgroundImageStretched = [backgroundImage stretchableImageWithLeftCapWidth:backgroundImage.size.width/2 topCapHeight:backgroundImage.size.height/2];
    _backgroundImage = [[UIImageView alloc] initWithImage:backgroundImageStretched];
    [self addSubview:_backgroundImage];
    _arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popoverUpArrow"]];
    [self addSubview:_arrowImage];
}
-(void)layoutSubviews {
    //UIEdgeInsets backgroundViewInsets = [SKMinimalPopoverBackgroundView backgroundViewInsets];
    //_backgroundImage.frame = CGRectMake(backgroundViewInsets.left, backgroundViewInsets.top, self.bounds.size.width-backgroundViewInsets.left-backgroundViewInsets.right, self.bounds.size.height-backgroundViewInsets.top-backgroundViewInsets.bottom);
    CGRect backgroundImageFrame = self.bounds;
    if (self.arrowDirection==UIPopoverArrowDirectionLeft) {
        backgroundImageFrame.origin.x += [SKMinimalPopoverBackgroundView arrowHeight];
        backgroundImageFrame.size.width -= [SKMinimalPopoverBackgroundView arrowHeight];
    } else if (self.arrowDirection==UIPopoverArrowDirectionRight) {
        backgroundImageFrame.size.width -= [SKMinimalPopoverBackgroundView arrowHeight];
    } else if (self.arrowDirection==UIPopoverArrowDirectionUp) {
        backgroundImageFrame.origin.y += [SKMinimalPopoverBackgroundView arrowHeight];
        backgroundImageFrame.size.height += [SKMinimalPopoverBackgroundView arrowHeight];
    } else if (self.arrowDirection==UIPopoverArrowDirectionDown) {
        backgroundImageFrame.size.height -= [SKMinimalPopoverBackgroundView arrowHeight];
    }
    _backgroundImage.frame = backgroundImageFrame;
    
    _arrowImage.transform = CGAffineTransformIdentity;
    _arrowImage.frame = CGRectMake(0, 0, [SKMinimalPopoverBackgroundView arrowBase], [SKMinimalPopoverBackgroundView arrowHeight]);
    
    CGFloat arrowAndBackgroundOverlap = 6;
    if (self.arrowDirection==UIPopoverArrowDirectionUp) {
        _arrowImage.center = CGPointMake(self.bounds.size.width/2 + self.arrowOffset, arrowAndBackgroundOverlap+[SKMinimalPopoverBackgroundView arrowHeight]/2);
    } else if (self.arrowDirection==UIPopoverArrowDirectionRight) {
        _arrowImage.center = CGPointMake(self.bounds.size.width-[SKMinimalPopoverBackgroundView arrowHeight]/2-arrowAndBackgroundOverlap, self.bounds.size.height/2 + self.arrowOffset);
        _arrowImage.transform = CGAffineTransformMakeRotation(M_PI*0.5);
    } else if (self.arrowOffset==UIPopoverArrowDirectionLeft) {
        _arrowImage.center = CGPointMake(arrowAndBackgroundOverlap+[SKMinimalPopoverBackgroundView arrowHeight]/2, self.bounds.size.height/2+self.arrowOffset);
        _arrowImage.transform = CGAffineTransformMakeRotation(M_PI*-0.5);
    } else if (self.arrowOffset==UIPopoverArrowDirectionDown) {
        _arrowImage.center = CGPointMake(self.bounds.size.width/2+self.arrowOffset, self.bounds.size.height-[SKMinimalPopoverBackgroundView arrowHeight]/2-arrowAndBackgroundOverlap);
        _arrowImage.transform = CGAffineTransformMakeRotation(M_PI);
    }
}
-(void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (!_setupYet) {
        [self setup];
    }
}

@synthesize arrowDirection=_arrowDirection;
-(void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection {
    _arrowDirection = arrowDirection;
    [self setNeedsLayout];
}

@synthesize arrowOffset=_arrowOffset;
-(void)setArrowOffset:(CGFloat)arrowOffset {
    _arrowOffset = arrowOffset;
    [self setNeedsLayout];
}

+(UIEdgeInsets)contentViewInsets {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    CGFloat padding = 15;
    insets.top+=padding;
    insets.bottom+=padding;
    insets.left+=padding;
    insets.right+=padding;
    return insets;
}

+(CGFloat)arrowBase {
    return [[UIImage imageNamed:@"popoverUpArrow"] size].width;
}

+(CGFloat)arrowHeight {
    return [[UIImage imageNamed:@"popoverUpArrow"] size].height;
}

@end
