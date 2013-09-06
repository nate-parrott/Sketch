//
//  SKToolbarItem.h
//  Sketch
//
//  Created by Nate Parrott on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKToolbarItem : UIButton {
    UIView* _contentView;
}

@property(strong,nonatomic)id content; // NSString, UIImage or UIView

@property(assign)id target;
@property SEL selector;

+(SKToolbarItem*)itemWithContent:(id)content target:(id)target selector:(SEL)selector;

@property(nonatomic)CGFloat width;

// Paste/paste: Copy/copy: Delete/delete: Duplicate/duplicate: - Group/group: Ungroup/ungroup: - Send_to_back/sendToBack: Bring_to_front/bringToFront: - Save_shape/saveAsTemplate:
+(NSArray*)itemsFromString:(NSString*)specifier target:(id)target;

@end
