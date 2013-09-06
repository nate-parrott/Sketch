//
//  SKTextCell.m
//  Sketch
//
//  Created by Nate Parrott on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKTextCell.h"

@implementation SKTextCell

-(void)setup {
    _textView = [UITextView new];
    [self addSubview:_textView];
    _textView.backgroundColor = self.backgroundColor;
    _textView.delegate = self;
    _textView.text = [self value];
    _textView.font = [UIFont systemFontOfSize:14];
}
-(void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"Your text here..."]) { // replace this w/ a better solution in the future
        textView.text = nil;
    }
}
-(void)textViewDidChange:(UITextView *)textView {
    [self setValue:_textView.text];
}
-(void)layoutSubviews {
    _textView.frame = CGRectInset(self.bounds, 10, 5);
    [super layoutSubviews];
}
-(BOOL)clicked {
    [_textView becomeFirstResponder];
    return NO;
}

@end
