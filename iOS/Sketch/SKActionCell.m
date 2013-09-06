//
//  SKActionCell.m
//  Sketch
//
//  Created by Nate Parrott on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKActionCell.h"
#import "SKImageEditorView.h"

@implementation SKActionCell

-(void)setup {
    self.textLabel.text = [self.propertyInfo objectForKey:@"title"];
    self.disabled = self.disabled || self.propertyEditor.elements.count!=1;
}
-(BOOL)clicked {
    if (self.propertyEditor.elements.count!=1)
        return NO;
    SKElement* element = [self.propertyEditor.elements lastObject];
    SEL selector = NSSelectorFromString([self.propertyInfo objectForKey:@"selector"]);
    if ([element respondsToSelector:selector]) {
        [element performSelector:selector];
    } else if ([self.propertyEditor.associatedImageEditor respondsToSelector:selector]) {
        [self.propertyEditor.associatedImageEditor performSelector:selector];
    }
    return NO;
}

@end
