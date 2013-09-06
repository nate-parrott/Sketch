//
//  SKFillPreviewCell.m
//  Sketch
//
//  Created by Nate Parrott on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKFillPreviewCell.h"
#import "SKFillPicker.h"
#import "SKImageEditorView.h"

@implementation SKFillPreviewCell

-(void)setup {
    [super setup];
    self.textLabel.text = [self.propertyInfo objectForKey:@"title"];
    _preview = [SKColorView new];
    [self addSubview:_preview];
    _preview.userInteractionEnabled = NO;
    _preview.color = [self value];
}
-(void)layoutSubviews {
    _preview.frame = CGRectMake(0, 0, 30, 30);
    _preview.center = CGPointMake(self.bounds.size.width - 30, self.bounds.size.height/2);
    [super layoutSubviews];
}
-(BOOL)clicked {
    SKFillPicker* picker = [[SKFillPicker alloc] initWithFill:[self value]];
    picker.callback = ^(id fill) {
        [self setValue:fill];
    };
    [self.propertyEditor.navigationController pushViewController:picker animated:YES];
    //[self.propertyEditor.associatedImageEditor setPropPaneWidth:400 animated:YES];
    return NO;
}

@end
