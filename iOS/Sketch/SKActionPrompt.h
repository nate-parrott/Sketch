//
//  SKActionPrompt.h
//  Sketch
//
//  Created by Nate Parrott on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SKActionCallback)();

@interface SKActionPrompt : NSObject <UIActionSheetDelegate> {
    NSMutableArray* _callbacks;
}
@property(strong)UIActionSheet* actionSheet;

-(id)initWithTitle:(NSString*)title;
-(void)addDestructiveButtonWithTitle:(NSString*)title callback:(SKActionCallback)callback;
-(void)addButtonWithTitle:(NSString*)title callback:(SKActionCallback)callback;
-(void)presentFromRect:(CGRect)rect inView:(UIView*)view;
-(void)presentFromBarButtonItem:(UIBarButtonItem*)barButtonItem;

@end
