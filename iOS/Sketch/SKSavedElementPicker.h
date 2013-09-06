//
//  SKSavedElementPicker.h
//  Sketch
//
//  Created by Nate Parrott on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NPGridView2.h"
#import "SKGridView.h"

@class SKSavedElementPicker, SKElement, SKPropertyEditor;
typedef SKPropertyEditor* (^SKSavedElementPickerCallback)(SKSavedElementPicker* picker, SKElement* element);

@interface SKSavedElementPicker : UIViewController <SKGridViewDelegate, UIActionSheetDelegate> {
    SKGridView* _gridView;
    //int _selectedCellIndex;
}
@property(strong)SKSavedElementPickerCallback callback;
@property(nonatomic)BOOL inSelectionMode;

@end
