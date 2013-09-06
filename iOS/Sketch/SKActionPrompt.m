//
//  SKActionPrompt.m
//  Sketch
//
//  Created by Nate Parrott on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKActionPrompt.h"

const NSMutableArray* _SKActionPrompts = nil;

@implementation SKActionPrompt
@synthesize actionSheet=_actionSheet;

-(id)initWithTitle:(NSString*)title {
    self = [super init];
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    _callbacks = [NSMutableArray new];
    return self;
}
// we need these b/c ARC doesn't allow manually retain/release, but we need the SKActionPrompt object to stick around until its UIActionSheet is dismissed
-(void)xRetain {
    if (!_SKActionPrompts) {
        _SKActionPrompts = [NSMutableArray new];
    }
    [_SKActionPrompts addObject:self];
}
-(void)xRelease {
    [_SKActionPrompts removeObject:self];
}
-(void)addDestructiveButtonWithTitle:(NSString*)title callback:(SKActionCallback)callback {
    [self addButtonWithTitle:title callback:callback];
    _actionSheet.destructiveButtonIndex = _actionSheet.numberOfButtons-1;
}
-(void)addButtonWithTitle:(NSString*)title callback:(SKActionCallback)callback {
    [_actionSheet addButtonWithTitle:title];
    [_callbacks addObject:callback];
}
-(void)prepareToShow {
    if ([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone) {
        [self addButtonWithTitle:@"Cancel" callback:^(){}];
    }
    [self xRetain];
}
-(void)presentFromRect:(CGRect)rect inView:(UIView*)view {
    [self prepareToShow];
    [_actionSheet showFromRect:rect inView:view animated:YES];
}
-(void)presentFromBarButtonItem:(UIBarButtonItem*)barButtonItem {
    [self prepareToShow];
    [_actionSheet showFromBarButtonItem:barButtonItem animated:YES];
}
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex < _callbacks.count) {
        ((SKActionCallback)[_callbacks objectAtIndex:buttonIndex])();
    }
    [self xRelease];
}

@end
