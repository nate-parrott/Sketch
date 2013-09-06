//
//  UIGridView.h
//  UIGridView
//
//  Created by Nate Parrott on 1/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NPGridViewCell.h"
#import "NPGridViewDelegate.h"

const float NPGridViewVerticalCellPaddingMatchHorizontalPadding;
const float NPGridViewPadContentHeightDuringSelectionMode;
const float NPGridViewCellSizeFillWidth;

@interface NPGridView2 : UIView <UIScrollViewDelegate> {
	UIScrollView *_scrollView;
	int _lastRow;
	int _rowsOnScreen;
	CGSize _cellSize;
	int _totalCells;
	int _columns;
	int _rows;
	NSMutableArray *_cellsForReuse;
	int _rowBuffer;
	CGFloat _leftoverCellSpace;
	BOOL _suspendRepositioning;
	NSMutableArray *_reclaimationQueue;
	CGRect _lastBounds;
	BOOL _alreadyLoaded;
	BOOL _selectionMode;
	NSMutableArray *_selectedIndices;
    CGSize _cellSizeAtStartOfZoomGesture;
	
	UISegmentedControl *_selectionModeOptions;
}
@property(nonatomic,retain)IBOutlet id<NPGridView2Delegate>delegate;
@property(nonatomic)CGFloat verticalCellPadding;
@property(nonatomic)BOOL allowsCellResizing;
@property(nonatomic)BOOL initialCellLoading;

-(BOOL)inSelectionMode;
-(void)enterSelectionModeWithOptions:(NSArray*)options;
-(NSMutableArray*)selectedIndices;
-(void)selectCellAtIndex:(int)index;
-(void)deselectCellAtIndex:(int)index;

-(void)reloadData;
-(NPGridViewCell*)dequeueReusableCellWithIdentifier:(NSString*)reuseId;
-(void)removeCellsAtIndices:(NSArray*)indicesAsNSNumbers animated:(BOOL)animated;
-(void)insertCellsAtIndices:(NSArray*)indicesAsNSNumbers animated:(BOOL)animated;
-(void)reloadCellAtIndex:(int)index;
//-cellForIndex: will only return cells that are currently onscreen, it will not generate cells
-(NPGridViewCell*)cellForIndex:(int)index;
-(void)endSelectionMode;
-(UIScrollView*)scrollView;
-(void)setCellSize:(CGSize)size;
-(void)setCellSize:(CGSize)size animated:(BOOL)animated;
-(CGSize)cellSize;

//internal methods
-(CGFloat)_verticalCellPadding;
-(void)_setup;
-(void)_clickedCell:(NPGridViewCell*)cell;
-(void)_heldDownCell:(NPGridViewCell*)cell;
-(void)reposition;
-(BOOL)supportsSelectionMode;
-(BOOL)supportsReordering;
-(void)cellDidMove:(NPGridViewCell*)moved mustReposition:(BOOL)mustReposition;
-(int)indexForPosition:(CGPoint)point;
@end
