//
//  SKImageEditorView.h
//  Sketch
//
//  Created by Nate Parrott on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKImage.h"
#import "SKElement.h"
#import "SKEditor.h"
#import "SKElementView.h"
#import "SKResizer.h"
#import "SKScrollView.h"
#import "SKImageView.h"
#import "SKPenOverlayView.h"
#import "SKImageEditorMode.h"
#import "SKFrameEditor.h"

@class SKPropertyEditor;
@class SKToolbar;
@class SKToolbarItem;
@class SKMaskPreviewView;

@interface SKImageEditorView : SKEditor <SKImageDelegate, SKRectEditorDelegate, SKResizerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, SKFrameEditorDelegate> {
    BOOL _setupYet;
    
    IBOutlet SKToolbar* _toolbar;
            
    NSMutableArray* _elementViews;
    SKResizer* _canvasResizer;
    
    SKPropertyEditor* _propertyEditor;
    UINavigationController* _propEditorNav;
    CGFloat _maxPropPaneWidth, _minPropPaneWidth;
    IBOutlet UIButton* _propertyEditorExpansionToggleButton;
    
    CGFloat _zoom;
    IBOutlet UIButton* _zoomIndicator;
        
    NSMutableArray* _selectedElements;
    UIPanGestureRecognizer* _selectionRectGestureRec;
    UIView* _selectionRect;
    
    SKPenOverlayView* _penOverlay;
    
    BOOL _inScrollMode;
    SKToolbarItem *_scrollModeToolbarItem, *_editModeToolbarItem;
    
    NSMutableArray* _modeStack;
    
    CGPoint _scrollViewContentOffsetAtStartOfGesture;
    
    NSArray* _overlappingElementsBeingPickedFrom;
    CGPoint _centerOfOverlapConstellation;
}

@property(strong,nonatomic)SKImage* image;
@property(strong)SKElement* maskingElement; // must set before loading view

@property(nonatomic)SKElement* selected;
@property(nonatomic,strong)NSArray* selectedElements;
-(void)selectElement:(SKElement*)element;
-(void)deselectElement:(SKElement*)element;
@property(strong)SKFrameEditor* selectedElementHandleEditor;

-(SKElement*)elementAtPoint:(CGPoint)point;
-(SKElementView*)viewForElement:(SKElement*)element;

@property(strong)SKMaskPreviewView* maskPreviewView;

@property(strong)SKImageView* imageView;
@property(strong)IBOutlet UIScrollView* scrollView;
-(IBAction)resetZoom:(id)sender;

-(void)updateToolbars;

@property(nonatomic) BOOL propertyEditorExpanded;
-(IBAction)togglePropertyEditorExpansion:(id)sender;

//@property(nonatomic)CGFloat propPaneWidth;
//-(void)setPropPaneWidth:(CGFloat)propPaneWidth animated:(BOOL)animated;

-(void)addShape:(SKElement*)el;
-(void)addShape:(SKElement*)el withPreferredPosition:(CGPoint)preferredPos canResize:(BOOL)canResize animated:(BOOL)animated;
@property CGPoint lastTouchPoint;

@property(weak)UIBarButtonItem *actionButtonItem, *savedElementsButtonItem;

@property BOOL isRoot;

/*typedef enum {
    SKImageEditorModeScroll,
    SKImageEditorModeEdit,
    SKImageEditorModePen
} SKImageEditorMode;
@property(nonatomic)SKImageEditorMode mode;*/
@property(nonatomic)BOOL inScrollMode;

-(void)willSave;

-(void)editSelectedElementPath;

-(NSArray*)modeStack;
-(void)pushMode:(SKImageEditorMode*)mode;
-(void)popMode;

-(void)takeOwnershipOfPopover:(UIPopoverController*)popover;

@end
