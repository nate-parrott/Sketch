//
//  SKGridViewCell.h
//  Sketch
//
//  Created by Nate Parrott on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SKGridView;

@interface SKGridViewCell : UIView

@property(strong,readonly)NSString *reuseIdentifier;
-(id)initWithReuseIdentifier:(NSString*)reuseID;
@property(assign)SKGridView* parentGridView;
@property(nonatomic)BOOL inSelectionMode;
@property(nonatomic)BOOL selected;
@property(strong,readonly)UIButton* overlay;

@end
