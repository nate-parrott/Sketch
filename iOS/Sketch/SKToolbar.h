//
//  SKToolbar.h
//  Sketch
//
//  Created by Nate Parrott on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKToolbarItem.h"
#import "SKToolbarScrollView.h"

@interface SKToolbar : UIView {
    UIImageView* _backgroundImage;
    UIImageView* _outlineImage;
    SKToolbarScrollView* _scrollView;
}

@property(strong,nonatomic)NSArray* toolbarItems;

@end
