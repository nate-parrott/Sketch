//
//  SKMinimalPopoverBackgroundView.h
//  Sketch
//
//  Created by Nate Parrott on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKMinimalPopoverBackgroundView : UIPopoverBackgroundView {
    BOOL _setupYet;
    UIImageView* _backgroundImage;
    UIImageView* _arrowImage;
}

@end
