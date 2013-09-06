//
//  SKSavedElementPicker.m
//  Sketch
//
//  Created by Nate Parrott on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKSavedElementPicker.h"
#import "SKSavedElementStore.h"
#import "SKPathElement.h"
#import "SKImageFill.h"
#import "SKTextElement.h"
#import "SKPropertyEditor.h"
#import "SKImageEditorView.h"
#import "SKColorFill.h"
#import "SKThumbnailCell.h"

@interface SKSavedElementPicker ()

@end

@implementation SKSavedElementPicker
@synthesize callback=_callback;

#pragma mark View loading
-(void)loadView {
    _gridView = [SKGridView new];
    _gridView.delegate = self;
    _gridView.cellSize = CGSizeMake(100, 100);
    
    self.inSelectionMode = NO;
    
    self.view = _gridView;
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
    
    NSMutableArray* toolbarItems = [NSMutableArray new];
    UIBarButtonItem* insertText = [[UIBarButtonItem alloc] initWithTitle:@"Insert text..." style:UIBarButtonItemStyleBordered target:self action:@selector(insertText:)];
    [toolbarItems addObject:insertText];
    
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    
    UIBarButtonItem* customShape = [[UIBarButtonItem alloc] initWithTitle:@"Custom shape..." style:UIBarButtonItemStyleBordered target:self action:@selector(insertCustomShape:)];
    [toolbarItems addObject:customShape];
    
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    
    UIBarButtonItem* insertImage = [[UIBarButtonItem alloc] initWithTitle:@"Insert image..." style:UIBarButtonItemStyleBordered target:self action:@selector(insertImage:)];
    [toolbarItems addObject:insertImage];
    
    self.toolbarItems = toolbarItems;
}
-(void)insertText:(id)sender {
    SKTextElement* textEl = [[SKTextElement alloc] init];
    textEl.frame = CGRectMake(0, 0, 100, 100);
    [textEl setProperty:[NSNumber numberWithBool:YES] forKey:@"fillShape"];
    [textEl setProperty:[NSNumber numberWithBool:NO] forKey:@"strokeShape"];
    SKPropertyEditor* propEditor = self.callback(self, textEl);
    if (!propEditor.associatedImageEditor.propertyEditorExpanded)
        propEditor.associatedImageEditor.propertyEditorExpanded = YES;
    [propEditor clickProperty:@"text"];
}
-(void)insertCustomShape:(id)sender {
    SKPathElement* el = [[SKPathElement alloc] init];
    el.frame = CGRectMake(0,0,200,200);
    SKPropertyEditor* propEditor = self.callback(self, el);
    [propEditor.associatedImageEditor editSelectedElementPath];
}
-(void)insertImage:(id)sender {
    SKPathElement* pathEl = [SKPathElement elementForImage:nil];
    SKPropertyEditor* propEditor = self.callback(self, pathEl);
    if (!propEditor.associatedImageEditor.propertyEditorExpanded)
        propEditor.associatedImageEditor.propertyEditorExpanded = YES;
    [propEditor clickProperty:@"fill"];
}
-(void)viewDidLoad {
    self.title = @"Shapes";
    [_gridView reloadData];
    _gridView.backgroundColor = [UIColor whiteColor];
}
-(void)viewDidUnload {
    _gridView = nil;
}
-(CGSize)contentSizeForViewInPopover {
    return CGSizeMake(320, 400);
}
#pragma mark GridViewDelegate
/*-(CGSize)sizeForCellsInGridView:(NPGridView2*)gridView {
    return CGSizeMake(100, 100);
}*/
-(int)numberOfCellsInGridView:(NPGridView2 *)gridView {
    return [[[SKSavedElementStore shared] storedElements] count];
}
-(SKGridViewCell*)gridView:(SKGridView*)gridView cellForIndex:(int)index {
    SKThumbnailCell* imageCell = (SKThumbnailCell*)[gridView dequeueCellWithIdentifier:@"ImageCell"];
    if (!imageCell) {
        imageCell = [[SKThumbnailCell alloc] initWithReuseIdentifier:@"ImageCell"];
        imageCell.thumbnailView.contentMode = UIViewContentModeScaleAspectFit;
    }
    CGFloat maxDimension = MAX(_gridView.cellSize.width, _gridView.cellSize.height) * [UIScreen mainScreen].scale;
    UIImage* thumbnail = [[[[SKSavedElementStore shared] storedElements] objectAtIndex:index] thumbnailWithMaxDimension:maxDimension];
    imageCell.thumbnailView.image = thumbnail;
    return imageCell;
}
#pragma mark Cell actions
-(void)gridView:(SKGridView*)gridView clickedCellAtIndex:(int)index {
    self.callback(self, [[[[SKSavedElementStore shared] storedElements] objectAtIndex:index] detatchedCopy]);
}
@synthesize inSelectionMode=_inSelectionMode;
-(void)setInSelectionMode:(BOOL)inSelectionMode {
    _inSelectionMode = inSelectionMode;
    _gridView.inSelectionMode = inSelectionMode;
    if (inSelectionMode) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(endEditMode)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteSelectedCells)];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(enterEditMode)];
    }
}
-(void)enterEditMode {
    self.inSelectionMode = YES;
}
-(void)endEditMode {
    self.inSelectionMode = NO;
}
-(void)deleteSelectedCells {
    for (NSNumber* index in [[[_gridView.selectedIndices allObjects] sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator]) {
        [[SKSavedElementStore shared] removeElementAtIndex:index.intValue];
    }
    [_gridView removeCells:[_gridView.selectedIndices allObjects] andInsertCellsAtIndices:nil animated:YES];
}
/*-(void)gridView:(SKGridView*)gridView heldDownCellAtIndex:(int)index {
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
    _selectedCellIndex = index;
    [actionSheet showInView:[gridView cellForIndex:index]];
}
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex==actionSheet.destructiveButtonIndex) {
        [[SKSavedElementStore shared] removeElementAtIndex:_selectedCellIndex];
        [_gridView removeCellsAtIndices:[NSArray arrayWithObject:[NSNumber numberWithInt:_selectedCellIndex]] animated:YES];
    }
}*/

@end
