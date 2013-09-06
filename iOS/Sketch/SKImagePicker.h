//
//  SKImagePicker.h
//  Sketch
//
//  Created by Nate Parrott on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKImageFill.h"

typedef void (^SKImagePickerCallback)(SKImageFill*);

@interface SKImagePicker : UIViewController <UIImagePickerControllerDelegate, UIPopoverControllerDelegate> {
    IBOutlet UIImageView* _imageView;
    IBOutlet UISegmentedControl* _fillModePicker;
    IBOutlet UIButton *_selectImageButton, *_takeImageButton;
    
    UIPopoverController* _pickerPopover;
}

@property(strong,nonatomic)SKImageFill* imageFill;
-(IBAction)pickImage:(id)sender;
-(IBAction)fillModeChanged:(id)sender;
@property(strong)SKImagePickerCallback callback;
-(IBAction)mask:(id)sender;

@end
