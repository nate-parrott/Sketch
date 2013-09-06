//
//  SKImageEditorView+ImageActions.h
//  Sketch
//
//  Created by Nate Parrott on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKImageEditorView.h"
#import <MessageUI/MessageUI.h>
#import <Twitter/Twitter.h>

@interface SKImageEditorView (ImageActions) <MFMailComposeViewControllerDelegate>

-(void)showImageActions:(UIBarButtonItem*)sender;

@end
