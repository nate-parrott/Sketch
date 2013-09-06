//
//  SKFontPreviewCell.m
//  Sketch
//
//  Created by Nate Parrott on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKFontPreviewCell.h"
#import "SKFontPicker.h"

@implementation SKFontPreviewCell

-(void)setup {
    if ([self value]) {
        self.textLabel.text = [self value];
        self.textLabel.font = [UIFont fontWithName:[self value] size:[UIFont systemFontSize]];
        self.textLabel.textColor = [UIColor blackColor];
    } else {
        self.textLabel.text = [self.propertyInfo objectForKey:@"placeholder"];
        self.textLabel.textColor = [UIColor grayColor];
    }
    [super setup];
}
-(BOOL)clicked {
    SKFontPicker* picker = [SKFontPicker new];
    picker.fontName = [self value];
    picker.callback = ^(NSString* fontName) {
        [self setValue:fontName];
    };
    [self.propertyEditor.navigationController pushViewController:picker animated:YES];
    return NO;
}

@end
