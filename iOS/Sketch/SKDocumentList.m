//
//  SKDocumentList.m
//  Sketch
//
//  Created by Nate Parrott on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKDocumentList.h"
#import "SKDocumentPreviewCell.h"
#import "SKDocumentEditor.h"
#import "SKImage.h"
#import "SKPathElement.h"

const CGFloat SKDocumentListCellPadding = 10;

@interface SKDocumentList ()

@end

@implementation SKDocumentList

-(id)init {
    self = [super init];
    _dir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Documents"];
    self.title = @"Sketches";
    self.editMode = NO;
    return self;
}
/*-(void)printTree:(UIView*)v indent:(int)ind {
    NSMutableString* indent = [NSMutableString new];
    for (int i=0; i<ind; i++) {
        [indent appendString:@" "];
    }
    NSLog(@"%@%@", indent, NSStringFromClass([v class]));
    for (UIView* s in v.subviews) {
        [self printTree:s indent:ind+1];
    }
}*/
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    /*
    // first, let's print the UIView tree
    UIView* v = self.view;
    while (v && ![v isKindOfClass:[UIWindow class]]) {
        v = v.superview;
    }
    [self printTree:v indent:0];*/
    
    return YES;
}
-(void)loadBundleList {
    _bundles = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:_dir error:nil] mutableCopy];
    NSMutableDictionary* creationDatesForBundles = [NSMutableDictionary new];
    for (NSString* bundle in _bundles) {
        NSDictionary* attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:[_dir stringByAppendingPathComponent:bundle] error:nil];
        [creationDatesForBundles setObject:[attribs objectForKey:NSFileCreationDate] forKey:bundle];
    }
    [_bundles sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[creationDatesForBundles objectForKey:obj1] compare:[creationDatesForBundles objectForKey:obj2]]*-1;
    }];
}
#pragma mark View
-(void)loadView {
    self.view = [UIView new];
    _gridView = [SKGridView new];//[NPGridView2 new];
    _gridView.contentInsets = UIEdgeInsetsMake(SKDocumentListCellPadding, SKDocumentListCellPadding, SKDocumentListCellPadding, SKDocumentListCellPadding);
    _gridView.scrollView.backgroundColor = TEXTURED_BACKGROUND_COLOR;
    _gridView.cellSize = [UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad? CGSizeMake(172, 200) : CGSizeMake(150, 170);
    _gridView.delegate = self;
    [self.view addSubview:_gridView];
    
    UIImageView* shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 5)];
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    shadowView.image = [UIImage imageNamed:@"shadow"];
    [self.view addSubview:shadowView];
}
-(void)viewDidLayoutSubviews {
    _gridView.frame = self.view.bounds;
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    _bundles = nil;
    [_gridView reloadData];
}
#pragma mark UI
-(void)add:(id)sender {
    NSString* bundleName = [NSString stringWithFormat:@"%f.sketch", [NSDate timeIntervalSinceReferenceDate]];
    NSString* bundlePath = [_dir stringByAppendingPathComponent:bundleName];
    [[NSFileManager defaultManager] createDirectoryAtPath:bundlePath withIntermediateDirectories:YES attributes:nil error:nil];
    [_bundles insertObject:bundleName atIndex:0];
    //_gridView insertCellsAtIndices:[NSArray arrayWithObject:[NSNumber numberWithInt:0]] animated:YES];
    [_gridView removeCells:nil andInsertCellsAtIndices:[NSArray arrayWithObject:[NSNumber numberWithInt:0]] animated:YES];

    [self performSelector:@selector(openNewBundle) withObject:nil afterDelay:0.5];
}
-(void)openNewBundle {
    [self gridView:_gridView clickedCellAtIndex:0];
}
#pragma mark GridView
-(int)numberOfCellsInGridView:(SKGridView *)gridView {
    if (!_bundles) {
        [self loadBundleList];
    }
    return _bundles.count;
}
-(SKGridViewCell*)gridView:(SKGridView *)gridView cellForIndex:(int)index {
    SKDocumentPreviewCell* cell = (SKDocumentPreviewCell*)[gridView dequeueCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[SKDocumentPreviewCell alloc] initWithReuseIdentifier:@"Cell"];
        cell.padding = UIEdgeInsetsMake(SKDocumentListCellPadding, SKDocumentListCellPadding, SKDocumentListCellPadding, SKDocumentListCellPadding);
    }
    cell.bundlePath = [_dir stringByAppendingPathComponent:[_bundles objectAtIndex:index]];
    return cell;
}
/*-(int)numberOfCellsInGridView:(NPGridView2 *)gridView {
    if (!_bundles) {
        [self loadBundleList];
    }
    return _bundles.count;
}
-(CGSize)sizeForCellsInGridView:(NPGridView2 *)gridView {
    return CGSizeMake(140, 170);
}
-(NPGridViewCell*)gridView:(NPGridView2 *)gridView cellAtIndex:(int)index {
    SKDocumentPreviewCell* cell = (SKDocumentPreviewCell*)[gridView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[SKDocumentPreviewCell alloc] initWithReuseIdentifier:@"Cell"];
    }
    cell.bundlePath = [_dir stringByAppendingPathComponent:[_bundles objectAtIndex:index]];
    return cell;
}
-(void)gridView:(NPGridView2 *)gridView clickedCellAtIndex:(int)index {
    SKDocumentEditor* editor = [SKDocumentEditor new];
    SKImage* image;
    NSString* bundlePath = [_dir stringByAppendingPathComponent:[_bundles objectAtIndex:index]];
    NSString* imageFilePath = [bundlePath stringByAppendingPathComponent:@"image"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageFilePath]) {
        image = [NSKeyedUnarchiver unarchiveObjectWithFile:imageFilePath];
    } else {
        image = [SKImage new];
        image.infiniteSize = YES;
    }
    image.bundlePath = bundlePath;
    editor.rootImage = image;
    
    UIImageView* animationView = [(SKThumbnailCell*)[_gridView cellForIndex:index] thumbnailView];
    CGRect animationTargetRect = CGRectMake(0, 44, image.size.width, image.size.height);
    
    [[SKSpecialNavigationController navControllerForViewController:self] pushViewController:editor animatedByZoomingView:animationView intoRect:animationTargetRect];
    //[self presentModalViewController:editor animated:YES];
}
-(void)gridView:(NPGridView2 *)gridView heldDownCellAtIndex:(int)index {
    _bundleIndexCorrespondingToActionSheet = index;
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
    NPGridViewCell* cell = [gridView cellForIndex:index];
    [sheet showFromRect:cell.bounds inView:cell animated:YES];
}*/
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex==actionSheet.destructiveButtonIndex) {
        NSString* path = [_dir stringByAppendingPathComponent:[_bundles objectAtIndex:_bundleIndexCorrespondingToActionSheet]];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        [_bundles removeObjectAtIndex:_bundleIndexCorrespondingToActionSheet];
        //[_gridView removeCellsAtIndices:[NSArray arrayWithObject:[NSNumber numberWithInt:_bundleIndexCorrespondingToActionSheet]] animated:YES];
    }
}
-(void)gridView:(SKGridView *)gridView clickedCellAtIndex:(int)index {
    SKDocumentEditor* editor = [SKDocumentEditor new];
    SKImage* image;
    NSString* bundlePath = [_dir stringByAppendingPathComponent:[_bundles objectAtIndex:index]];
    NSString* imageFilePath = [bundlePath stringByAppendingPathComponent:@"image"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageFilePath]) {
        image = [NSKeyedUnarchiver unarchiveObjectWithFile:imageFilePath];
    } else {
        image = [SKImage new];
        image.infiniteSize = YES;
    }
    image.bundlePath = bundlePath;
    editor.rootImage = image;
    
    UIImageView* animationView = [(SKThumbnailCell*)[_gridView cellForIndex:index] thumbnailView];
    CGRect animationTargetRect = CGRectMake(0, 44, image.size.width, image.size.height);
    
    [[SKSpecialNavigationController navControllerForViewController:self] pushViewController:editor animatedByZoomingView:animationView intoRect:animationTargetRect];
    //[self presentModalViewController:editor animated:YES];
}
@synthesize editMode=_editMode;
-(void)setEditMode:(BOOL)editMode {
    _gridView.inSelectionMode = editMode;
    if (editMode) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteSelected:)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(endEditMode)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(enterEditMode)];

    }
}
-(void)enterEditMode {
    self.editMode = YES;
}
-(void)endEditMode {
    self.editMode = NO;
}
-(void)deleteSelected:(id)sender {
    for (NSNumber* idx in [[[_gridView.selectedIndices allObjects] sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator]) {
        NSString* bundle = [_dir stringByAppendingPathComponent:[_bundles objectAtIndex:idx.intValue]];
        [[NSFileManager defaultManager] removeItemAtPath:bundle error:nil];
        [_bundles removeObjectAtIndex:idx.intValue];
    }
    [_gridView removeCells:[_gridView.selectedIndices allObjects] andInsertCellsAtIndices:nil animated:YES];
}


@end
