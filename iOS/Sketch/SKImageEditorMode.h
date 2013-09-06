//
//  SKImageEditorMode.h
//  Sketch
//
//  Created by Nate Parrott on 9/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SKImageEditorModeCallback)();

@interface SKImageEditorMode : NSObject

@property(strong)NSArray *leftBarButtonItems, *rightBarButtonItems;
@property(strong)SKImageEditorModeCallback didPush, willPop, didBecomeActive, didResignActive;
@property(strong)NSString* title;

@end
