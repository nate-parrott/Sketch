//
//  SKColorStopDetail.h
//  Sketch
//
//  Created by Nate Parrott on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKGradientColorStopEditor.h"
#import "SKGradientColorStop.h"
#import "CPColorPicker.h"

@interface SKColorStopDetail : UIViewController {
    IBOutlet CPColorPicker* _colorPicker;
    IBOutlet UIButton* _deleteButton;
    IBOutlet UIView* _colorPickerPlaceholder;
}

@property(assign)SKGradientColorStopEditor* colorStopEditor;
@property(assign)SKGradientColorStop* colorStop;
@property(assign)UIPopoverController* parentPopover;
-(IBAction)deleteColorStop:(id)sender;

@end
