//
//  SKDocumentEditor.h
//  Sketch
//
//  Created by Nate Parrott on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKImage.h"

@class SKEditor;

@interface SKDocumentEditor : UINavigationController {
}

-(void)pushEditor:(SKEditor*)editor;
-(void)popEditor;
@property(strong,nonatomic)SKImage* rootImage;
-(UIBarButtonItem*)saveAndCloseButton;

@end
