//
//  SKColorPreviewCell.m
//  Sketch
//
//  Created by Nate Parrott on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKColorPreviewCell.h"
#import "SKColorFill.h"
#import "SKImageEditorView.h"
#import "CPColorPicker.h"

@implementation SKColorPreviewCell

-(BOOL)clicked {
    /*SKColorPicker* picker = [SKColorPicker new];
    picker.color = [self value];
    picker.callback = ^(UIColor* color) {
        [self setValue:color];
    };*/
    CPColorPicker* picker = [CPColorPicker new];
    picker.color = [self value];
    picker.callback = ^(UIColor* color) {
        [self setValue:color];
    };
    [self.propertyEditor.navigationController pushViewController:picker animated:YES];
    //[self.propertyEditor.associatedImageEditor setPropPaneWidth:400 animated:YES];
    return NO;
}

@end
