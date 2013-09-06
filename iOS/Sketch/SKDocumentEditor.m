//
//  SKDocumentEditor.m
//  Sketch
//
//  Created by Nate Parrott on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKDocumentEditor.h"
#import "SKEditor.h"
#import "SKImageEditorView.h"
#import "SKTextElement.h"

@interface SKDocumentEditor ()

@end

@implementation SKDocumentEditor

#pragma mark Data

@synthesize rootImage=_rootImage;
-(void)setRootImage:(SKImage *)rootImage {
    _rootImage = rootImage;
    SKImageEditorView* rootEditor = [SKImageEditorView new];
    rootEditor.isRoot = YES;
    rootEditor.documentEditor = self;
    rootEditor.image = rootImage;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillClose:) name:SKAppDelegateShouldSaveData object:nil];
        
    self.viewControllers = [NSArray arrayWithObject:rootEditor];
}
-(UIBarButtonItem*)saveAndCloseButton {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveAndClose:)];
}
-(void)save {
    [(SKImageEditorView*)[self.viewControllers objectAtIndex:0] willSave];
    [self.rootImage save];
}
-(void)appWillClose:(NSNotification*)notif {
    [self save];
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark UI
-(void)saveAndClose:(id)sender {
    [self save];
    //[self dismissModalViewControllerAnimated:YES];
    UIImageView* thumbnailView = (UIImageView*)[[SKSpecialNavigationController navControllerForViewController:self] thumbnailViewForViewController:self];
    thumbnailView.image = [self.rootImage thumbnailWithMaxDimension:SKDocumentThumbnailMaxDimension];
    [[SKSpecialNavigationController navControllerForViewController:self] popViewController];
}
#pragma mark Editing views
-(void)pushEditor:(SKEditor *)editor {
    editor.documentEditor = self;
    [self pushViewController:editor animated:YES];
}
-(void)popEditor {
    [self popViewControllerAnimated:YES];
}

@end
