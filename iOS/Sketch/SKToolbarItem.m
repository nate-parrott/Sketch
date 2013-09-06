//
//  SKToolbarItem.m
//  Sketch
//
//  Created by Nate Parrott on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKToolbarItem.h"

@implementation SKToolbarItem
@synthesize content=_content;
@synthesize target=_target;
@synthesize selector=_selector;

-(void)setContent:(id)content {
    _content = content;
    [self setTitle:nil forState:UIControlStateNormal];
    [self setImage:nil forState:UIControlStateNormal];
    [_contentView removeFromSuperview];
    _contentView = nil;
    if ([content isKindOfClass:[NSString class]]) {
        [self setTitle:[content lowercaseString] forState:UIControlStateNormal];
    } else if ([content isKindOfClass:[UIImage class]]) {
        [self setImage:content forState:UIControlStateNormal];
    } else if ([content isKindOfClass:[UIView class]]) {
        _contentView = content;
        _contentView.frame = self.bounds;
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self insertSubview:_contentView atIndex:0];
    }
}

+(SKToolbarItem*)itemWithContent:(id)content target:(id)target selector:(SEL)selector {
    SKToolbarItem* item = [SKToolbarItem buttonWithType:UIButtonTypeCustom];
    item.content = content;
    item.target = target;
    item.selector = selector;
    [item addTarget:item action:@selector(clicked) forControlEvents:UIControlEventTouchUpInside];
    
    [item setBackgroundImage:[[UIImage imageNamed:@"skToolbarButtonBackground"] stretchableImageWithLeftCapWidth:2 topCapHeight:2] forState:UIControlStateNormal];
    [item setBackgroundImage:[[UIImage imageNamed:@"skToolbarButtonBackgroundDown"] stretchableImageWithLeftCapWidth:2 topCapHeight:7] forState:UIControlStateHighlighted];
    [[item titleLabel] setFont:[UIFont boldSystemFontOfSize:14]];
    [item setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    [[item titleLabel] setShadowOffset:CGSizeMake(0, -1)];
    
    return item;
}
-(void)clicked {
    [self.target performSelector:self.selector withObject:self];
}
@synthesize width=_width;
-(void)setWidth:(CGFloat)width {
    _width = width;
}
-(CGFloat)width {
    if (_width)
        return _width;
    
    if ([self.content isKindOfClass:[NSString class]]) {
        return [self.content sizeWithFont:[self.titleLabel font]].width + 26;
    } else {
        return 65;
    }
}

// Paste/paste: Copy/copy:? Delete/delete:? Duplicate/duplicate:? Group/group:? Ungroup/ungroup:? Send_to_back/sendToBack:? Bring_to_front/bringToFront?: Save_shape/saveAsTemplate?:
+(NSArray*)itemsFromString:(NSString*)specifier target:(id)target {
    NSMutableArray* items = [NSMutableArray new];
    for (NSString* spec in [specifier componentsSeparatedByString:@" "]) {
        if ([spec isEqualToString:@"-"]) {
            /*SKToolbarItem* item = [SKToolbarItem itemWithContent:nil target:nil selector:nil];
            item.userInteractionEnabled = NO;
            [items addObject:item];*/
        } else {
            NSString* specifier = spec;
            BOOL shouldCheckIfCanPerform = NO;
            if ([specifier characterAtIndex:specifier.length-1]=='?') {
                shouldCheckIfCanPerform = YES;
                specifier = [specifier substringToIndex:spec.length-1];
            }
            NSArray* comps = [specifier componentsSeparatedByString:@"/"];
            NSString* title = [[comps objectAtIndex:0] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
            SEL selector = NSSelectorFromString([comps objectAtIndex:1]);
            if (!shouldCheckIfCanPerform || [target canPerformAction:selector withSender:nil]) {
                [items addObject:[SKToolbarItem itemWithContent:title target:target selector:selector]];
            }
        }
    }
    return items;
}

@end
