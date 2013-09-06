//
//  SKImageEditorView.m
//  Sketch
//
//  Created by Nate Parrott on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKImageEditorView.h"
#import "SKPathElement.h"
#import "SKPropertyEditor.h"
#import "SKPathEditor.h"
#import "SKSavedElementPicker.h"
#import "SKImageEditorView+PositionSnapping.h"
#import "SKImageEditorView+EditingMenu.h"
#import "SKGroupElement.h"
#import "SKMinimalPopoverBackgroundView.h"
#import "SKColorFill.h"
#import "SKToolbar.h"
#import "SKPopoverPresenter.h"
#import "SKMaskPreviewView.h"
#import "SKImageEditorView+EditingMenu.h"

//BOOL SKAddedImageEditorMenuItems = NO;

@implementation SKImageEditorView
@synthesize isRoot=_isRoot;

-(id)init {
    self = [super init];
        
    _elementViews = [NSMutableArray new];
    _selectedElements = [NSMutableArray new];
    
    _propertyEditor = [[SKPropertyEditor alloc] init];
    _propertyEditor.associatedImageEditor = self;
    _propEditorNav = [[UINavigationController alloc] initWithRootViewController:_propertyEditor];
    [self addChildViewController:_propEditorNav];
    _minPropPaneWidth = [UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad? 40 : 0;
    _maxPropPaneWidth = 250;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateToolbars) name:UIPasteboardChangedNotification object:[UIPasteboard generalPasteboard]];
    
    return self;
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark Data
@synthesize image=_image;
@synthesize maskingElement=_maskingElement;

-(void)setImage:(SKImage *)image {
    if (_image) {
        _image.delegate = nil;
    }
    _image = image;
    _image.delegate = self;
    
    if ([self isViewLoaded]) {
        _scrollView.contentSize = [image size];
        _imageView.frame = CGRectMake(0, 0, [image size].width, [image size].height);
    }
}
#pragma mark Setup
@synthesize scrollView=_scrollView;
@synthesize imageView=_imageView;
-(void)viewDidLoad {    
    if (_zoom==0) _zoom = 1; // initialize the zoom level
    _scrollView.contentSize = [self.image size];
    if (self.image.infiniteSize) {
        _scrollView.backgroundColor = [UIColor whiteColor];
    } else {
        _scrollView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    }
    _scrollView.canCancelContentTouches = NO;
    //_scrollView.delaysContentTouches = NO;
    _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 320, 320);
    _scrollView.delegate = self;
    _scrollView.minimumZoomScale = 0.5;
    _scrollView.maximumZoomScale = 5;
    _scrollView.zoomScale = _zoom;
    
    _imageView = [SKImageView new];
    _imageView.clipsToBounds = YES;
    _imageView.scale = _zoom;
    _imageView.image = self.image;
    _imageView.backgroundColor = [UIColor whiteColor];
    _imageView.opaque = YES;
    [_scrollView addSubview:_imageView];
    
    if (!self.image.infiniteSize) { // allow the user to explicitly set the size
        _canvasResizer = [SKResizer new];
        _canvasResizer.size = self.image.size;
        _canvasResizer.delegate = self;
        [_imageView addSubview:_canvasResizer];
    }
    
    self.selected = nil;
    _imageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer* singleTapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [_scrollView addGestureRecognizer:singleTapRec];
    
    UITapGestureRecognizer* doubleTapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    doubleTapRec.numberOfTapsRequired = 2;
    [_scrollView addGestureRecognizer:doubleTapRec];
    [singleTapRec requireGestureRecognizerToFail:doubleTapRec];
        
    UIPanGestureRecognizer* threeFingerScroll = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(threeFingerScroll:)];
    threeFingerScroll.minimumNumberOfTouches = 3;
    [_scrollView addGestureRecognizer:threeFingerScroll];
    
    
    UILongPressGestureRecognizer* overlappingElementsPicker = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(overlappingElementPicking:)];
    [_scrollView addGestureRecognizer:overlappingElementsPicker];
    
    [self layout];
    
    for (SKElement* element in self.image.elements) {
        [self image:self.image didAddElement:element];
    }
    
    [self.view addSubview:_propEditorNav.view];
    [self.view bringSubviewToFront:_propertyEditorExpansionToggleButton];
    
    _selectionRectGestureRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(selectionRectDidPan:)];
    [_scrollView addGestureRecognizer:_selectionRectGestureRec];
    _selectionRectGestureRec.delegate = self;
    
    _modeStack = [NSMutableArray new];
    [self loadRootMode];
    
    [self setInScrollMode:NO];
    //self.mode = SKImageEditorModeEdit;
    
    self.selectedElementHandleEditor = [SKFrameEditor new];
    [_imageView addSubview:self.selectedElementHandleEditor];
    self.selectedElementHandleEditor.rect = [self selectionBoundingRect];
    self.selectedElementHandleEditor.delegate = self;
    self.selectedElementHandleEditor.imageView = self;
    
    if (self.maskingElement) {
        self.maskPreviewView = [[SKMaskPreviewView alloc] initWithMaskedElement:self.maskingElement maskImage:self.image];
        [self.view addSubview:self.maskPreviewView];
    }
}
@synthesize actionButtonItem=_actionButtonItem;
@synthesize savedElementsButtonItem=_savedElementsButtonItem;
#pragma mark View callbacks
@synthesize maskPreviewView=_maskPreviewView;
-(void)didReceiveMemoryWarning {
    // at this point, the code isn't ready to deal w/ memory warnings
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[self.navigationController setToolbarHidden:NO animated:animated];
    [self updateToolbars];
    
    //[self imageElementsDidChange];
    //[self needsRerender];
    for (SKElementView* ed in _elementViews) {
        [ed setNeedsDisplay];
    }
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[self.navigationController setToolbarHidden:YES animated:animated];
}
-(void)viewDidUnload {
    [_elementViews removeAllObjects];
}
#pragma mark UI
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == _selectionRectGestureRec) {
        if ([self elementAtPoint:[touch locationInView:_imageView]] ||
            [self.selectedElementHandleEditor pointInside:[touch locationInView:self.selectedElementHandleEditor] withEvent:nil]) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return YES;
    }
}
-(void)addSavedShape:(id)sender {
    //if (self.mode!=SKImageEditorModeEdit)
    //    self.mode = SKImageEditorModeEdit;
    
    SKSavedElementPicker* picker = [SKSavedElementPicker new];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:picker];
    SKPopoverPresenter* presenter = [SKPopoverPresenter presentViewController:navController fromViewController:self fromBarButtonItem:sender];
    picker.callback = ^(SKSavedElementPicker* picker, SKElement* element) {
        [self addShape:element withPreferredPosition:_lastTouchPoint canResize:YES animated:YES];
        [presenter dismiss];
        return _propertyEditor;
    };
    
    /*if (_savedShapesPopover!=nil) {return;}
    
    SKSavedElementPicker* picker = [SKSavedElementPicker new];
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:picker];
    _savedShapesPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
    //_savedShapesPopover.popoverBackgroundViewClass = [SKMinimalPopoverBackgroundView class];
    _savedShapesPopover.delegate = self;
    [_savedShapesPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    picker.callback = ^(SKSavedElementPicker* picker, SKElement* element) {
        element = [element detatchedCopy];
        [self addShape:element withPreferredPosition:_lastTouchPoint canResize:YES animated:YES];
        [_savedShapesPopover dismissPopoverAnimated:YES];
        _savedShapesPopover = nil;
        return _propertyEditor;
    };*/
}
/*-(void)addFreehandShape:(id)sender {
    SKPathElement* newElement = [SKPathElement new];
    newElement.frame = CGRectMake(10, 10, 150, 150);
    [newElement setProperty:[[SKColorFill alloc] initWithColor:[UIColor grayColor]] forKey:@"fill"];
    [newElement setProperty:[NSNumber numberWithBool:YES] forKey:@"fillShape"];
    [newElement setProperty:[NSNumber numberWithBool:YES] forKey:@"strokeShape"];
    [newElement setProperty:[UIColor blackColor] forKey:@"strokeColor"];
    [newElement setProperty:[NSNumber numberWithFloat:4] forKey:@"strokeWidth"];
    SKPathEditor* pathEditor = [[SKPathEditor alloc] init];
    pathEditor.element = newElement;
    [self addShape:newElement];
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:pathEditor];
    pathEditor.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditingFreehandPath)];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navController animated:YES];
}
-(void)doneEditingFreehandPath {
    [self dismissModalViewControllerAnimated:YES];
}*/
-(SKElement*)elementAtPoint:(CGPoint)point {
    for (SKElement* element in self.image.elements.reverseObjectEnumerator) {
        //CGPoint adjustedPoint = CGPointMake(point.x-element.frame.origin.x, point.y-element.frame.origin.y);
        if ([element hitTest:point] ||
            ([self.selectedElements containsObject:element] && CGRectContainsPoint(element.frame, point)) ) {
            return element;
        }
    }
    // okay, if this point isn't contained in any of the paths of the image's elements, let's just see if it falls w/in their bounding rects
    for (SKElement* element in self.image.elements.reverseObjectEnumerator) {
        if (CGRectContainsPoint(element.frame, point)) {
            return element;
        }
    }
    return nil;
}
@synthesize lastTouchPoint=_lastTouchPoint;
-(void)tapped:(UITapGestureRecognizer*)gestureRec {
    if (gestureRec.state==UIGestureRecognizerStateRecognized) {
        CGPoint point = [gestureRec locationInView:_imageView];
        _lastTouchPoint = point;
        SKElement* element = [self elementAtPoint:point];
        self.selected = element;
        //[self performSelector:@selector(showEditMenu) withObject:nil afterDelay:0.01];
    }
}
-(void)doubleTapped:(UITapGestureRecognizer*)gestureRec {
    if ([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        // add this to the multiple selection
        if (gestureRec.state==UIGestureRecognizerStateRecognized) {
            CGPoint point = [gestureRec locationInView:_imageView];
            _lastTouchPoint = point;
            SKElement* element = [self elementAtPoint:point];
            if (element.selected) {
                [self deselectElement:element];
            } else {
                [self selectElement:element];
            }
            //[self performSelector:@selector(showEditMenu) withObject:nil afterDelay:0.01];
        }
    } else {
        [self setPropertyEditorExpanded:YES];
    }
}
-(void)addShape:(SKElement*)el withPreferredPosition:(CGPoint)preferredPos canResize:(BOOL)canResize animated:(BOOL)animated {
    CGRect visibleRect = CGRectMake(_scrollView.contentOffset.x/_zoom, _scrollView.contentOffset.y/_zoom, _scrollView.frame.size.width/_zoom, _scrollView.frame.size.height/_zoom);
    CGRect documentRect = CGRectMake(0, 0, _image.size.width, _image.size.height);
    CGRect insertionArea = CGRectIntersection(visibleRect, documentRect);
    
    CGRect elFrame;
    if (canResize) {
        CGFloat maxEdgeLength = 400/_zoom;
        elFrame.size = el.frame.size.width>el.frame.size.height? CGSizeMake(maxEdgeLength, el.frame.size.height*maxEdgeLength/el.frame.size.height) : CGSizeMake(el.frame.size.width*maxEdgeLength/el.frame.size.width, maxEdgeLength);
    } else {
        elFrame.size = el.frame.size;
    }
    
    CGPoint center = preferredPos;
    CGRect possibleCenterArea = CGRectMake(insertionArea.origin.x+elFrame.size.width/2, insertionArea.origin.y+elFrame.size.height/2, insertionArea.size.width-elFrame.size.height, insertionArea.size.height-elFrame.size.height);
    if (center.x < possibleCenterArea.origin.x) {
        center.x = possibleCenterArea.origin.x;
    } else if (center.x > possibleCenterArea.origin.x+possibleCenterArea.size.width) {
        center.x = possibleCenterArea.origin.x+possibleCenterArea.size.width;
    }
    if (center.y < possibleCenterArea.origin.y) {
        center.y = possibleCenterArea.origin.y;
    } else if (center.y > possibleCenterArea.origin.y+possibleCenterArea.size.height) {
        center.y = possibleCenterArea.origin.y;
    }
    elFrame.origin = CGPointMake(center.x-elFrame.size.width/2, center.y-elFrame.size.height/2);
    
    el.frame = elFrame;
    
    [self.image addElement:el];
    
    if (animated) {
        SKElementView* rectEditor = [self viewForElement:el];
        rectEditor.alpha = 0;
        rectEditor.transform = CGAffineTransformMakeScale(2, 2);
        [UIView animateWithDuration:0.3 animations:^{
            rectEditor.alpha = 1;
            rectEditor.transform = CGAffineTransformMakeScale(1, 1);
        }];
    }
    // when animation is on, it's unlikely that this is being called in a constructor or other behind-the-scenes method; it's probably the result of user action, so let's anticipate the user and select this element
    //if (animated) {
        [self setSelected:el];
        //[self displayPropertyEditorForElement:el];
    //}
}
-(void)addShape:(SKElement*)el {
    [self addShape:el withPreferredPosition:_lastTouchPoint canResize:YES animated:YES];
}
-(void)threeFingerScroll:(UIPanGestureRecognizer*)gestureRec {
    if (gestureRec.state==UIGestureRecognizerStateBegan) {
        _scrollViewContentOffsetAtStartOfGesture = _scrollView.contentOffset;
    } else if (gestureRec.state==UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRec translationInView:self.view];
        CGPoint newContentOffset = CGPointMake(_scrollViewContentOffsetAtStartOfGesture.x-translation.x, _scrollViewContentOffsetAtStartOfGesture.y-translation.y);
        _scrollView.contentOffset = newContentOffset;
    }
}
-(void)overlappingElementPicking:(UILongPressGestureRecognizer*)gestureRec {
    SKElement* selected = nil;
    if (gestureRec.state==UIGestureRecognizerStateBegan) {
        CGPoint touchPoint = [gestureRec locationInView:_scrollView];
        NSMutableArray* overlappingElements = [NSMutableArray new];
        for (SKElement* element in self.image.elements) {
            if (CGRectContainsPoint(element.frame, touchPoint)) {
                [overlappingElements addObject:element];
            }
        }
        _centerOfOverlapConstellation = touchPoint;
        _overlappingElementsBeingPickedFrom = overlappingElements;
        [UIView animateWithDuration:0.3 animations:^{
            CGFloat angle = 0;
            CGFloat translation = 100 / _scrollView.zoomScale;
            CGFloat targetSize = 65 / _scrollView.zoomScale;
            for (SKElement* element in _overlappingElementsBeingPickedFrom) {
                CGPoint targetPosition = CGPointMake(touchPoint.x + translation*cos(angle), touchPoint.y + translation*sin(angle));
                CGPoint center = [self viewForElement:element].center;
                CGSize size = [self viewForElement:element].frame.size;
                CGAffineTransform transform = CGAffineTransformMakeTranslation(targetPosition.x-center.x, targetPosition.y-center.y);
                CGFloat scale = MIN(targetSize / size.width, targetSize / size.height);
                transform = CGAffineTransformScale(transform, scale, scale);
                
                [[self viewForElement:element] setTransform:transform];
                angle += M_PI*2/_overlappingElementsBeingPickedFrom.count;
            }
        }];
    } else if (gestureRec.state==UIGestureRecognizerStateChanged) {
        CGPoint touchPoint = [gestureRec locationInView:_scrollView];
        CGFloat distance = CGPointDistance(touchPoint, _centerOfOverlapConstellation);
        if (distance > 80 && _overlappingElementsBeingPickedFrom.count) {
            CGFloat angle = atan2f(touchPoint.y-_centerOfOverlapConstellation.y, touchPoint.x-_centerOfOverlapConstellation.x) + M_PI*2;
            int selectedIndex = 0;
            if (_overlappingElementsBeingPickedFrom.count > 1) {
                selectedIndex = ((int)roundf(angle / (M_PI*2/_overlappingElementsBeingPickedFrom.count)))%_overlappingElementsBeingPickedFrom.count;
            }
            selected = _overlappingElementsBeingPickedFrom[selectedIndex];
        }
    }
    if ((gestureRec.state==UIGestureRecognizerStateEnded || gestureRec.state==UIGestureRecognizerStateCancelled || selected) &&
        _overlappingElementsBeingPickedFrom) {
        [UIView animateWithDuration:0.3 animations:^{
            for (SKElement* element in _overlappingElementsBeingPickedFrom) {
                [[self viewForElement:element] setTransform:CGAffineTransformIdentity];
            }
        }];
        if (selected) {
            [self setSelected:selected];
        }
        _overlappingElementsBeingPickedFrom = nil;
    }
}
#pragma mark Element rect editors
@synthesize selectedElementHandleEditor=_selectedElementHandleEditor;
-(void)frameEditor:(SKFrameEditor *)frameEditor didChangeFrameFrom:(CGRect)oldFrame toFrame:(CGRect)newFrame {
    for (SKElement* element in self.selectedElements) {
        CGRect elFrame = element.frame;
        CGRect elFractionalFrame = CGRectMake((elFrame.origin.x - oldFrame.origin.x) / oldFrame.size.width, (elFrame.origin.y - oldFrame.origin.y) / oldFrame.size.height, elFrame.size.width/oldFrame.size.width, elFrame.size.height/oldFrame.size.height);
        element.frame = CGRectMake(newFrame.origin.x+elFractionalFrame.origin.x*newFrame.size.width, newFrame.origin.y+elFractionalFrame.origin.y*newFrame.size.height, elFractionalFrame.size.width*newFrame.size.width, elFractionalFrame.size.height*newFrame.size.height);
        [element didUpdate];
    }
}
-(CGRect)selectionBoundingRect {
    if (self.selectedElements.count==0) {
        return CGRectMake(-1000, -1000, 0, 0);
    }
    CGFloat minX = MAXFLOAT;
    CGFloat minY = MAXFLOAT;
    CGFloat maxX = 0;
    CGFloat maxY = 0;
    for (SKElement* element in self.selectedElements) {
        CGRect frame = element.frame;
        minX = MIN(minX, frame.origin.x);
        minY = MIN(minY, frame.origin.y);
        maxX = MAX(maxX, frame.origin.x+frame.size.width);
        maxY = MAX(maxY, frame.origin.y+frame.size.height);
    }
    return CGRectMake(minX, minY, maxX-minX, maxY-minY);
}

-(SKElementView*)viewForElement:(SKElement*)element {
    for (SKElementView* ed in _elementViews) {
        if (ed.correspondsTo==element) {
            return ed;
        }
    }
    return nil;
}
-(void)image:(SKImage *)image didAddElement:(SKElement *)element {
    if (![self isViewLoaded]) return;
    SKElementView* rectEditor = [SKElementView new];
    rectEditor.backgroundColor = [UIColor clearColor];
    rectEditor.opaque = NO;
    rectEditor.rect = element.frame;
    rectEditor.delegate = self;
    rectEditor.correspondsTo = element;
    rectEditor.scale = _zoom;
    [_imageView addSubview:rectEditor];
    [_elementViews addObject:rectEditor];
    [self image:image didUpdateElement:element];
    
    [_scrollView bringSubviewToFront:_selectedElementHandleEditor];
}
-(void)image:(SKImage *)image didRemoveElement:(SKElement *)element {
    SKElementView* rectEditor = [self viewForElement:element];
    [_elementViews removeObject:rectEditor];
    rectEditor.correspondsTo = nil;
    [rectEditor removeFromSuperview];
}
-(void)image:(SKImage *)image didUpdateElement:(SKElement *)element {
    SKElementView* rectEditor = [self viewForElement:element];
    if (!CGRectEqualToRect(element.frame, rectEditor.rect)) {
        // while the rect editor is receiving touches, update just the visible frame, not the rect property, b/c that would screw up the touch handling (should be fixed)
        if (rectEditor.numTouchesDown > 0) {
            rectEditor.frame = element.frame;
        } else {
            rectEditor.rect = element.frame;
        }
    }
    [rectEditor setNeedsDisplay];
    [self layout];
}
-(void)rectDidChange:(SKElementView *)rectEditor fromRect:(CGRect)oldRect {
    if (![self.selectedElements containsObject:rectEditor.correspondsTo]) {
        self.selected = rectEditor.correspondsTo;
    }
    if (rectEditor.numTouchesDown==1) {
        CGPoint translation = CGPointMake(rectEditor.rect.origin.x-oldRect.origin.x, rectEditor.rect.origin.y-oldRect.origin.y);
        for (SKElement* el in self.selectedElements) {
            if (el != rectEditor.correspondsTo) {
                el.frame = CGRectMake(el.frame.origin.x+translation.x, el.frame.origin.y+translation.y, el.frame.size.width, el.frame.size.height);
                [[self viewForElement:el] setFrame:el.frame];
            }
        }
    }
    
    CGRect adjustedRect = [self stickySnapFrameRect:rectEditor.rect withTolerance:CGPointStandardSnappingThreshold/_zoom];
    rectEditor.frame = adjustedRect;
    [rectEditor.correspondsTo setFrame:adjustedRect];
    [rectEditor.correspondsTo didUpdate];
}
#pragma mark PropertyEditor
@synthesize propertyEditorExpanded=_propertyEditorExpanded;
/*-(void)displayPropertyEditorForElement:(SKElement*)element {
    [_propertyEditor setElement:element];
}*/
-(void)setPropertyEditorExpanded:(BOOL)propertyEditorExpanded {
    _propertyEditorExpanded = propertyEditorExpanded;
    [UIView animateWithDuration:0.3 animations:^{
        [self layout];
    }];
}
-(IBAction)togglePropertyEditorExpansion:(id)sender {
    self.propertyEditorExpanded = !self.propertyEditorExpanded;
}
#pragma mark Selection
//@synthesize selected=_selected;
-(void)updatePropertyEditor {
    _propertyEditor.elements = self.selectedElements;
}
-(void)setSelected:(SKElement *)selected {
    self.selectedElements = selected? [NSArray arrayWithObject:selected] : [NSArray array];
}
-(SKElement*)selected {
    return _selectedElements.count>0? [_selectedElements lastObject] : nil;
}
-(void)_selectElement:(SKElement*)element {
    [[self viewForElement:element] setSelected:YES];
    if (element) {
        [_selectedElements addObject:element];
        element.selected = YES;
    }
    self.selectedElementHandleEditor.rect = [self selectionBoundingRect];
}
-(void)_deselectElement:(SKElement*)element {
    [[self viewForElement:element] setSelected:NO];
    [_selectedElements removeObject:element];
    element.selected = NO;
    self.selectedElementHandleEditor.frame = [self selectionBoundingRect];
    [_scrollView bringSubviewToFront:self.selectedElementHandleEditor];
}
-(void)selectElement:(SKElement *)element {
    if ([_selectedElements containsObject:element])
        return;
    [self _selectElement:element];
    [self updatePropertyEditor];
    [self updateToolbars];
}
-(void)deselectElement:(SKElement *)element {
    [self _deselectElement:element];
    [self updatePropertyEditor];
    [self updateToolbars];
}
-(NSArray*)selectedElements {
    return [_selectedElements copy];
}
-(void)setSelectedElements:(NSArray *)toSelect {
    for (SKElement* element in self.selectedElements) {
        [self _deselectElement:element];
    }
    for (SKElement* el in toSelect) {
        [self selectElement:el];
    }
    [self updatePropertyEditor];
    [self updateToolbars];
}
-(void)selectionRectDidPan:(UIPanGestureRecognizer*)gestureRec {
    if (gestureRec.state==UIGestureRecognizerStateBegan) {
        _selectionRect = [UIView new];
        _selectionRect.userInteractionEnabled = NO;
        _selectionRect.opaque = NO;
        _selectionRect.backgroundColor = [UIColor clearColor];
        _selectionRect.layer.borderColor = [[UIColor colorWithWhite:0.3 alpha:0.6] CGColor];
        _selectionRect.layer.borderWidth = 1;
        [self.scrollView addSubview:_selectionRect];
    }
    if (gestureRec.state==UIGestureRecognizerStateBegan ||
        gestureRec.state==UIGestureRecognizerStateChanged) {
        CGPoint end = [gestureRec locationInView:self.imageView];
        CGPoint translation = [gestureRec translationInView:self.imageView];
        CGPoint start = CGPointMake(end.x - translation.x, end.y - translation.y);
        CGRect selectionRect = CGRectZero;
        selectionRect.origin = CGPointMake(MIN(start.x, end.x), MIN(start.y, end.y));
        selectionRect.size = CGSizeMake(MAX(start.x, end.x)-selectionRect.origin.x, MAX(start.y, end.y)-selectionRect.origin.y);
        _selectionRect.frame = [self.scrollView convertRect:selectionRect fromView:self.imageView];
    } else if (gestureRec.state==UIGestureRecognizerStateEnded ||
               gestureRec.state==UIGestureRecognizerStateFailed ||
               gestureRec.state==UIGestureRecognizerStateCancelled) {
        if (gestureRec.state==UIGestureRecognizerStateEnded) {
            CGRect selectionRect = [_imageView convertRect:_selectionRect.frame fromView:_scrollView];
            NSMutableSet* selectedElements = [NSMutableSet new];
            for (SKElementView* rectEditor in _elementViews) {
                if (CGRectIntersectsRect(rectEditor.frame, selectionRect)) {
                    [selectedElements addObject:rectEditor.correspondsTo];
                }
            }
            [self setSelectedElements:[selectedElements allObjects]];
        }
        [_selectionRect removeFromSuperview];
    }
}
#pragma mark Zooming
-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}
-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    _zoom = scrollView.zoomScale;
    _selectedElementHandleEditor.scale = _zoom;
    [_zoomIndicator setTitle:[NSString stringWithFormat:@"%i%%", (int)roundf(_zoom*100)] forState:UIControlStateNormal];
}
-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    _zoom = scale;
    //_imageView.transform = CGAffineTransformMakeScale(_zoom, _zoom);
    _imageView.scale = _zoom;
    for (SKElementView* ed in _elementViews) {
        ed.scale = _zoom;
    }
    //[self needsRerender];
}
-(IBAction)resetZoom:(id)sender {
    [_scrollView setZoomScale:1 animated:YES];
}
#pragma mark Layout
-(void)didResize:(SKResizer*)resizer {
    self.image.size = resizer.size;
    [self layout];
    //[self needsRerender];
}
-(void)layout {
    self.selectedElementHandleEditor.rect = [self selectionBoundingRect];
    
    CGSize maskPreviewSize = CGSizeMake(150, 150);
    self.maskPreviewView.frame = CGRectMake(self.view.bounds.size.width-200-maskPreviewSize.width, self.view.bounds.size.height-200-maskPreviewSize.height, maskPreviewSize.width, maskPreviewSize.height);
    
    _scrollView.frame = self.view.bounds;
    
    CGFloat propWidth = _propertyEditorExpanded? _maxPropPaneWidth : _minPropPaneWidth;
    if (_propertyEditorExpanded) {
        _propEditorNav.view.frame = CGRectMake(self.view.bounds.size.width-_maxPropPaneWidth, 0, _maxPropPaneWidth, self.view.bounds.size.height);
        _propertyEditorExpansionToggleButton.frame = CGRectMake(self.view.bounds.size.width-_maxPropPaneWidth, self.view.bounds.size.height-40, _maxPropPaneWidth, 40);
        [_propertyEditorExpansionToggleButton setTitle:@"»" forState:UIControlStateNormal];
    } else {
        _propEditorNav.view.frame = CGRectMake(self.view.bounds.size.width-_minPropPaneWidth, 0, _maxPropPaneWidth, self.view.bounds.size.height);
        _propertyEditorExpansionToggleButton.frame = CGRectMake(self.view.bounds.size.width-_minPropPaneWidth, 0, _minPropPaneWidth, self.view.bounds.size.height);
        [_propertyEditorExpansionToggleButton setTitle:@"«" forState:UIControlStateNormal];
    }
    
    // 86 x 37
    if ([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        CGFloat inset = 50;
        _toolbar.frame = CGRectMake(inset, self.view.bounds.size.height-44-inset, self.view.bounds.size.width-inset*2-propWidth, 44);
        _zoomIndicator.frame = CGRectMake(0, self.view.bounds.size.height-37, 86, 37);
    } else {
        _toolbar.frame = CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width-propWidth, 44);
        _zoomIndicator.frame = CGRectMake(0, self.view.bounds.size.height-37-44, 60, 37);
    }
    
    CGSize imageDisplaySize = CGSizeMake(self.image.size.width*_zoom, self.image.size.height*_zoom);
    CGFloat displaySizePadding = self.image.infiniteSize? 20 : 0;
    imageDisplaySize.width += displaySizePadding;
    imageDisplaySize.height += displaySizePadding;
    _scrollView.contentSize = imageDisplaySize;
    _imageView.frame = CGRectMake(0, 0, imageDisplaySize.width+20, imageDisplaySize.height+20);
    
    if (_penOverlay) {
        _penOverlay.frame = _scrollView.frame;
    }
    
    [self.maskPreviewView imageDidUpdate];
}
-(void)viewDidLayoutSubviews {
    [self layout];
}
/*#pragma mark Rendering
-(void)needsRerender {
    CGSize imageDisplaySize = CGSizeMake(self.image.size.width*_zoom, self.image.size.height*_zoom);
    if (!CGSizeEqualToSize(_scrollView.contentSize, imageDisplaySize)) {
        _scrollView.contentSize = imageDisplaySize;
    }
    _imageView.frame = CGRectMake(0, 0, imageDisplaySize.width, imageDisplaySize.height);
    [_imageView setNeedsDisplay];
    //_imageView.image = [self.image imageAtSize:CGSizeMake(imageDisplaySize.width*[UIScreen mainScreen].scale, imageDisplaySize.height*[UIScreen mainScreen].scale)];
}
-(void)imageElementsDidChange {
    for (SKRectEditor* ed in _rectEditors) {
        [ed removeFromSuperview];
    }
    _rectEditors = [NSMutableArray new];
    for (SKElement* el in self.image.elements) {
        SKRectEditor* rectEditor = [SKRectEditor new];
        rectEditor.correspondsTo = el;
        rectEditor.rect = el.frame;
        rectEditor.delegate = self;
        [_imageView addSubview:rectEditor];
        [_rectEditors addObject:rectEditor];
    }
}*/
#pragma mark Property editor callbacks
-(void)editSelectedElementPath {
    SKPathEditor* pathEditor = [[SKPathEditor alloc] init];
    pathEditor.element = [[_propertyEditor elements] lastObject];
    [self.documentEditor pushEditor:pathEditor];
}
-(void)editSubImage {
    SKGroupElement* group = [[_propertyEditor elements] lastObject];
    SKImageEditorView* editor = [SKImageEditorView new];
    editor.image = group.childImage;
    [self.documentEditor pushEditor:editor];
}
-(void)editMask {
    SKElement* element = [[_propertyEditor elements] lastObject];
    SKImage* image = [element propertyForKey:@"maskImage"];
    if (!image) {
        image = [SKImage new];
        image.size = element.frame.size;
        image.parentElement = element;
        [element setProperty:image forKey:@"maskImage"];
    }
    SKImageEditorView* editor = [SKImageEditorView new];
    editor.image = image;
    editor.maskingElement = element;
    [self.documentEditor pushEditor:editor];
}
#pragma mark Toolbar
-(void)updateToolbars {
    // Paste/paste: Copy/copy:? Delete/delete:? Duplicate/duplicate:? Group/group:? Ungroup/ungroup:? Send_to_back/sendToBack:? Bring_to_front/bringToFront?: Save_shape/saveAsTemplate?:
    NSMutableArray* items = [NSMutableArray new];
    [items addObjectsFromArray:[SKToolbarItem itemsFromString:@"scroll/scrollMode edit_shapes/editMode -" target:self]];
    _scrollModeToolbarItem = [items objectAtIndex:0];
    _editModeToolbarItem = [items objectAtIndex:1];
    for (SKToolbarItem* item in items) {
        item.backgroundColor = [UIColor colorWithWhite:0.123 alpha:0.400];
    }
    
    [[items lastObject] setBackgroundImage:nil forState:UIControlStateNormal];
    [items addObject:[SKToolbarItem itemWithContent:[[UIImage imageNamed:@"modeBorder"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] target:nil selector:nil]];
    [[items lastObject] setBackgroundImage:nil forState:UIControlStateNormal];
    [[items lastObject] setWidth:8];
    
    [items addObjectsFromArray:[SKToolbarItem itemsFromString:@"Properties.../expandProperties:? Paste/paste: Copy/copy:? Delete/delete:? Duplicate/duplicate:? - Group/group:? Ungroup/ungroup:? ↥_front/bringToFront:? ↧_back/sendToBack:? - Save_shape/saveAsTemplate:?" target:self]];
    [_toolbar setToolbarItems:items];
    [self setInScrollMode:_inScrollMode];
    
}
#pragma mark Pen mode
-(void)addShapesFromPenOverlay {
    self.selectedElements = nil;
    for (SKPathElement* newPath in _penOverlay.shapes) {
        CGRect shapeFrame = newPath.frame;
        shapeFrame = [_imageView convertRect:shapeFrame fromView:_penOverlay];
        newPath.frame = shapeFrame;
        //[self addShape:newPath withPreferredPosition:CGPointMake(shapeFrame.origin.x+shapeFrame.size.width/2, shapeFrame.origin.y+shapeFrame.size.height/2) canResize:NO animated:NO];
        [self.image addElement:newPath];
        [newPath didUpdate];
        [self selectElement:newPath];
        //[self displayPropertyEditorForElement:newPath];
    }
    [_penOverlay clearCurrentStrokes];
}
#pragma mark Mode
// TODO: this isn't a relevant categorization...
-(void)willSave {
    [self addShapesFromPenOverlay];
}
/*@synthesize mode=_mode;
-(void)setMode:(SKImageEditorMode)mode {
    if (_mode==SKImageEditorModePen) {
        [self addShapesFromPenOverlay];
        [_penOverlay removeFromSuperview];
        _penOverlay = nil;
    }
    _mode = mode;
    _scrollView.scrollEnabled = (mode==SKImageEditorModeScroll);
    _selectionRectGestureRec.enabled = (mode==SKImageEditorModeEdit);
    [self updateToolbars];
    if (mode==SKImageEditorModePen) {
        _toolbar.alpha = 0;
        _propEditorNav.view.alpha = 0;
        _penOverlay = [SKPenOverlayView new];
        [self.view insertSubview:_penOverlay aboveSubview:_imageView];
    } else {
        _toolbar.alpha = 1;
        _propEditorNav.view.alpha = 1;
    }
}*/
#pragma mark Scroll mode
-(void)setInScrollMode:(BOOL)inScrollMode {
    _inScrollMode = inScrollMode;
    [_scrollModeToolbarItem setTitleColor:inScrollMode? [UIColor whiteColor] : [UIColor colorWithWhite:0.7 alpha:1] forState:UIControlStateNormal];
    [_editModeToolbarItem setTitleColor:inScrollMode? [UIColor colorWithWhite:0.7 alpha:1] : [UIColor whiteColor] forState:UIControlStateNormal];
    
    _scrollView.scrollEnabled = inScrollMode;
    _selectionRectGestureRec.enabled = !inScrollMode;
}
#pragma mark Mode stack
-(NSArray*)modeStack {
    return _modeStack;
}
-(void)setCurrentMode:(SKImageEditorMode*)mode {
    self.navigationItem.leftBarButtonItems = mode.leftBarButtonItems;
    self.navigationItem.rightBarButtonItems = mode.rightBarButtonItems;
    self.navigationItem.title = mode.title;
    if ([mode didBecomeActive]) [mode didBecomeActive]();
}
-(void)pushMode:(SKImageEditorMode*)mode {
    if (_modeStack.count && [[_modeStack lastObject] didResignActive])
        [[_modeStack lastObject] didResignActive]();
    [_modeStack addObject:mode];
    if ([mode didPush]) [mode didPush]();
    [self setCurrentMode:mode];
}
-(void)popMode {
    if ([[_modeStack lastObject] willPop]) [[_modeStack lastObject] willPop]();
    if ([[_modeStack lastObject] didResignActive]) [[_modeStack lastObject] didResignActive]();
    [_modeStack removeLastObject];
    [self setCurrentMode:[_modeStack lastObject]];
}
-(void)loadRootMode {
    SKImageEditorMode* rootMode = [SKImageEditorMode new];
    
    rootMode.didBecomeActive = ^() {
        if (self.isRoot) {
            self.navigationItem.leftBarButtonItem = [self.documentEditor saveAndCloseButton];
        }
    };
    NSMutableArray* toolbarItems = [NSMutableArray new];
    UIBarButtonItem* addSavedElementButton = [[UIBarButtonItem alloc] initWithTitle:@"Add shape..." style:UIBarButtonItemStyleBordered target:self action:@selector(addSavedShape:)];
    self.savedElementsButtonItem = addSavedElementButton;
    [toolbarItems addObject:addSavedElementButton];
    
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithTitle:@"Pen..." style:UIBarButtonItemStyleBordered target:self action:@selector(penMode)]];
    
    if (self.isRoot) {
        UIBarButtonItem* actionButtonItem = self.actionButtonItem;
        if (!actionButtonItem) {
            actionButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showImageActions:)];
            self.actionButtonItem = actionButtonItem;
        }
        [toolbarItems addObject:actionButtonItem];
    }
    rootMode.rightBarButtonItems = toolbarItems;
    [self pushMode:rootMode];
}
#pragma mark Modes
-(void)scrollMode {
    //self.mode = SKImageEditorModeScroll;
    [self setInScrollMode:YES];
}
-(void)editMode {
    //self.mode = SKImageEditorModeEdit;
    [self setInScrollMode:NO];
}
-(void)penMode {
    //self.mode = SKImageEditorModePen;
    SKImageEditorMode* penMode = [SKImageEditorMode new];
    penMode.title = @"Pen mode";
    penMode.leftBarButtonItems = [NSArray array];
    penMode.rightBarButtonItems = [NSArray arrayWithObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(popMode)]];
    penMode.didBecomeActive = ^() {
        _toolbar.alpha = 0;
        _propEditorNav.view.alpha = 0;
        _penOverlay = [SKPenOverlayView new];
        [self.view insertSubview:_penOverlay aboveSubview:_imageView];
    };
    penMode.didResignActive = ^() {
        [self addShapesFromPenOverlay];
        _toolbar.alpha = 1;
        _propEditorNav.view.alpha = 1;
        [_penOverlay removeFromSuperview];
    };
    [self pushMode:penMode];
}
@end
