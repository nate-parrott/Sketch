//
//  SKToolbar.m
//  Sketch
//
//  Created by Nate Parrott on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKToolbar.h"

@implementation SKToolbar

-(void)setup {
    self.layer.cornerRadius = 10;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    _backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"skToolbarBackground"]];
    _backgroundImage.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:_backgroundImage];
    _scrollView = [SKToolbarScrollView new];
    [self addSubview:_scrollView];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.opaque = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.canCancelContentTouches = YES;
    _scrollView.delaysContentTouches = NO;
    _outlineImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"skToolbarOutline"] stretchableImageWithLeftCapWidth:12 topCapHeight:12]];
    _outlineImage.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:_outlineImage];
}

-(id)init {
    self = [super init];
    [self setup];
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

@synthesize toolbarItems=_toolbarItems;
-(void)setToolbarItems:(NSArray *)toolbarItems {
    for (SKToolbarItem* existingItem in _toolbarItems) {
        [existingItem removeFromSuperview];
    }
    _toolbarItems = toolbarItems;
    for (SKToolbarItem* item in _toolbarItems) {
        [_scrollView addSubview:item];
    }
    //[self layoutSubviews]; // to fix an animation bug where all the buttons fly out from (0,0): the first time they're being laid out is inside an animation, so we have to lay out earlier
    [self setNeedsLayout];
}

-(void)layoutSubviews {
    _backgroundImage.frame = self.bounds;
    _outlineImage.frame = self.bounds;
    _scrollView.frame = self.bounds;
    CGFloat x = 0;
    for (SKToolbarItem* item in self.toolbarItems) {
        CGFloat buttonWidth = [item width];
        item.frame = CGRectMake(x, 0, buttonWidth, self.bounds.size.height);
        x += buttonWidth;
    }
    _scrollView.contentSize = CGSizeMake(x, self.bounds.size.height);
}

@end
