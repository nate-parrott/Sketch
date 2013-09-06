//
//  SKDocumentList.h
//  Sketch
//
//  Created by Nate Parrott on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKGridView.h"

@interface SKDocumentList : UIViewController <SKGridViewDelegate, UIActionSheetDelegate> {
    NSString* _dir;
    SKGridView* _gridView;
    NSMutableArray* _bundles;
    
    int _bundleIndexCorrespondingToActionSheet;
}
@property(nonatomic)BOOL editMode;

@end
