//
//  SKColorStopDetail.m
//  Sketch
//
//  Created by Nate Parrott on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKColorStopDetail.h"

@interface SKColorStopDetail ()

@end

@implementation SKColorStopDetail
@synthesize colorStop=_colorStop;
@synthesize colorStopEditor=_colorStopEditor;
@synthesize parentPopover=_parentPopover;

-(id)init {
    self = [super initWithNibName:@"SKColorStopDetail" bundle:nil];
    return self;
}
-(void)viewDidLoad {
    self.view.backgroundColor = BACKGROUND_COLOR;
    if (!_colorPicker) {
        _colorPicker = [CPColorPicker new];
        _colorPicker.color = self.colorStop.color;
        _colorPicker.callback = ^(UIColor* color) {
            self.colorStop.color = color;
            [self.colorStopEditor updatedColorStops];
        };
        [self addChildViewController:_colorPicker];
    }
    _deleteButton.enabled = self.colorStopEditor.subviews.count > 1;
    [_colorPickerPlaceholder replaceWith:_colorPicker.view];
}
-(IBAction)deleteColorStop:(id)sender {
    [self.parentPopover dismissPopoverAnimated:YES];
    [self.colorStop removeFromSuperview];
    [self.colorStopEditor updatedColorStops];
}
#define FORWARD_MESSAGE(msg) -(void)msg:(BOOL)animated {\
[_colorPicker msg:animated];\
[super msg:animated];\
}

FORWARD_MESSAGE(viewWillAppear);
FORWARD_MESSAGE(viewDidAppear);
FORWARD_MESSAGE(viewWillDisappear);
FORWARD_MESSAGE(viewDidDisappear);

-(CGSize)contentSizeForViewInPopover {
    return CGSizeMake(320, 540);
}


@end
