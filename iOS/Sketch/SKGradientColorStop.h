//
//  SKGradientColorStop.h
//  Sketch
//
//  Created by Nate Parrott on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SKGradientColorStopEditor;
@interface SKGradientColorStop : UIView <UIPopoverControllerDelegate> {
    UIPopoverController* _editorPopover;
    BOOL _moved;
}

@property(strong,nonatomic)UIColor* color;
@property CGFloat position;
@property(assign) SKGradientColorStopEditor* editor;
-(void)editColorStop;

@end
