//
//  SKImagePicker.m
//  Sketch
//
//  Created by Nate Parrott on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKImagePicker.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SKImageExtractViewController.h"

@interface SKImagePicker ()

@end

@implementation SKImagePicker
@synthesize callback=_callback;

-(id)init {
    self = [super initWithNibName:@"SKImagePicker" bundle:nil];
    self.title = @"Image";
    return self;
}
@synthesize imageFill=_imageFill;
-(void)setImageFill:(SKImageFill *)imageFill {
    _imageFill = imageFill;
    [self updateDisplay];
}
-(void)viewDidLoad {
    self.view.backgroundColor = BACKGROUND_COLOR;
    if (!self.imageFill) {
        self.imageFill = [SKImageFill new];
    }
    _takeImageButton.hidden = ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    [self updateDisplay];
}
-(void)updateDisplay {
    _imageView.image = self.imageFill.image;
    _fillModePicker.selectedSegmentIndex = self.imageFill.fillMode;
}
-(void)imageFillDidUpdate {
    if (self.callback) {
        self.callback(self.imageFill);
    }
    [self updateDisplay];
}
-(IBAction)pickImage:(id)sender {
    if (_pickerPopover) return;
    
    UIImagePickerController* picker = [[UIImagePickerController alloc] init
                                       ];
    picker.delegate = self;
    picker.mediaTypes = [NSArray arrayWithObject:(id)kUTTypeImage];
    picker.sourceType = (sender==_selectImageButton)? UIImagePickerControllerSourceTypePhotoLibrary : UIImagePickerControllerSourceTypeCamera;
    picker.allowsEditing = YES;
    
    _pickerPopover = [[UIPopoverController alloc] initWithContentViewController:picker];
    _pickerPopover.delegate = self;
    [_pickerPopover presentPopoverFromRect:[sender bounds] inView:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}
-(IBAction)mask:(id)sender {
    if (self.imageFill.image==nil) return;
    
    SKImageExtractViewController* extractVC = [SKImageExtractViewController new];
    extractVC.imageFill = self.imageFill;
    extractVC.updateCallback = ^() {
        [self imageFillDidUpdate];
    };
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:extractVC];
    navController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self presentModalViewController:navController animated:YES];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [_pickerPopover dismissPopoverAnimated:YES];
    _pickerPopover = nil;
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    self.imageFill.image = editedImage;
    [self imageFillDidUpdate];
    
    [_pickerPopover dismissPopoverAnimated:YES];
    _pickerPopover = nil;
}
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    _pickerPopover = nil;
}
-(IBAction)fillModeChanged:(id)sender {
    self.imageFill.fillMode = [_fillModePicker selectedSegmentIndex];
    [self imageFillDidUpdate];
}

@end
