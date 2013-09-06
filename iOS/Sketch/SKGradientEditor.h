//
//  SKGradientEditor.h
//  Sketch
//
//  Created by Nate Parrott on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKGradientColorStopEditor.h"
#import "SKGradientPointEditor.h"
#import "SKGradient.h"

typedef void (^SKGradientEditorCallback)(SKGradient*);

@interface SKGradientEditor : UIViewController {
    IBOutlet SKGradientColorStopEditor* _colorStopEditor;
    IBOutlet SKGradientPointEditor* _pointEditor;
    IBOutlet UISegmentedControl* _typePicker;
    IBOutlet UIImageView* _checkerboardView;
}

-(void)updatedGradient;
@property(strong,nonatomic)SKGradient* gradient;
@property(strong)SKGradientEditorCallback callback;
-(IBAction)pickedType:(id)sender;

@end
