//
//  SKFontPicker.h
//  Sketch
//
//  Created by Nate Parrott on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SKFontPickerCallback)(NSString*);

@interface SKFontPicker : UITableViewController {
    NSArray* _families;
    NSMutableDictionary* _fontsForFamily;
    NSMutableSet* _expandedFamilies;
}

@property(strong,nonatomic)NSString* fontName;
@property(strong)SKFontPickerCallback callback;

@end
