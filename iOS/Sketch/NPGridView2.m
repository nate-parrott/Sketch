//
//  UIGridView.m
//  UIGridView
//
//  Created by Nate Parrott on 1/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NPGridView2.h"
#import <QuartzCore/QuartzCore.h>

@implementation NPGridView2
@synthesize delegate, verticalCellPadding, allowsCellResizing, initialCellLoading;

const float NPGridViewVerticalCellPaddingMatchHorizontalPadding = MAXFLOAT;
const float NPGridViewPadContentHeightDuringSelectionMode = 73;
const float NPGridViewCellSizeFillWidth = MAXFLOAT;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self _setup];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder {
	[super initWithCoder:aDecoder];
	[self _setup];
	return self;
}
-(id)init {
	[super init];
	[self _setup];
	return self;
}
-(UIScrollView*)scrollView {
	return _scrollView;
}
-(void)didPinch:(UIPinchGestureRecognizer*)sender {
    if (!allowsCellResizing)
        return;
    if (sender.state == UIGestureRecognizerStateBegan)
        _cellSizeAtStartOfZoomGesture = _cellSize;
    _cellSize = CGSizeMake(_cellSizeAtStartOfZoomGesture.width*sender.scale, _cellSizeAtStartOfZoomGesture.height*sender.scale);
    [self reposition];
}
-(void)_setup {
    self.clipsToBounds = YES;
	_selectedIndices = nil;
	self.verticalCellPadding = NPGridViewVerticalCellPaddingMatchHorizontalPadding;
	_scrollView = [[[UIScrollView alloc] init] autorelease];
	[self addSubview:_scrollView];
    [self sendSubviewToBack:_scrollView];
	_scrollView.delegate = self;
	_suspendRepositioning = NO;
    UIPinchGestureRecognizer *zoomRec = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinch:)] autorelease];
    [self addGestureRecognizer:zoomRec];
}
-(NPGridViewCell*)dequeueReusableCellWithIdentifier:(NSString*)reuseId {
	for (int i=0; i<_cellsForReuse.count; i++) {
		NPGridViewCell *cell = [_cellsForReuse objectAtIndex:i];
		if ([[cell reuseIdentifier] isEqualToString:reuseId]) {
			[cell retain];
			[_cellsForReuse removeObjectAtIndex:i];
			return [cell autorelease];
		}
	}
	return nil;
}
-(void)reloadData {
	if (delegate==nil) {
		return;
	}
	for (UIView *subview in [_scrollView subviews]) {
		if ([subview isKindOfClass:[NPGridViewCell class]]) {
			[subview removeFromSuperview];
		}
	}
	if (_cellsForReuse) {
		[_cellsForReuse release];
	}
	_alreadyLoaded = YES;
	_rowBuffer = 2;//2 buffer rows below AND above the visible rows
	_cellsForReuse = [NSMutableArray new];
	[self cellSize];
	_totalCells = [delegate numberOfCellsInGridView:self];
    initialCellLoading = YES;
	[self reposition];
    initialCellLoading = NO;
}
-(void)reposition {
	_reclaimationQueue = [NSMutableArray new];
	[_reclaimationQueue addObjectsFromArray:[_scrollView subviews]];
	_columns = (int)floorf(self.bounds.size.width/_cellSize.width);
    if (_columns<1)
        _columns = 1;
	_leftoverCellSpace = (self.bounds.size.width-_columns*_cellSize.width)/_columns;
    if (_leftoverCellSpace<0)
        _leftoverCellSpace = 0;
	CGFloat rowHeight = _cellSize.height+[self _verticalCellPadding];
	_rows = (int)ceilf((float)_totalCells/(float)_columns);
	_rowsOnScreen = (int)ceilf(self.bounds.size.height/rowHeight)+_rowBuffer*2;
	
	CGSize contentSize;
	contentSize.width = self.bounds.size.width;
	contentSize.height = (CGFloat)_rows*rowHeight+[self _verticalCellPadding];
	if (_selectionMode) {
		contentSize.height+=NPGridViewPadContentHeightDuringSelectionMode;
	}
	_scrollView.contentSize = contentSize;
	int currentRow = [self currentRow];
	for (int i=0;i<_rowsOnScreen+1;i++) {
		[self renderRow:currentRow+i];
	}
	_lastRow = [self currentRow];
	
	for (UIView *subview in _reclaimationQueue) {
			if ([subview isKindOfClass:[NPGridViewCell class]]) {
				[subview removeFromSuperview];
			}
	}
	[_reclaimationQueue release];
	_reclaimationQueue = nil;
}
-(CGFloat)_verticalCellPadding {
	if (self.verticalCellPadding==NPGridViewVerticalCellPaddingMatchHorizontalPadding) {
		return _leftoverCellSpace/2;
	} else {
		return self.verticalCellPadding;
	}
}
-(CGSize)cellSize {
    if (CGSizeEqualToSize(_cellSize, CGSizeZero))
        _cellSize = ([(NSObject*)delegate respondsToSelector:@selector(sizeForCellsInGridView:)])? [delegate sizeForCellsInGridView:self] : CGSizeMake(50, 50);
    return _cellSize;
}
-(CGRect)positionForIndex:(int)index {
	CGRect frame;
	int column = index%_columns;
	int row = (int)floorf((float)index/_columns);
	frame.origin.x = column*_cellSize.width+_leftoverCellSpace*(column+0.5);
	frame.origin.y = row*(_cellSize.height+[self _verticalCellPadding])+[self _verticalCellPadding];
	frame.size = _cellSize;
    if (frame.size.width>=self.bounds.size.width)
        frame.size.width = self.bounds.size.width;
	
	frame.origin.x = roundf(frame.origin.x);
	frame.origin.y = roundf(frame.origin.y);
	return frame;
}
-(void)setCellSize:(CGSize)size {
    [self setCellSize:size animated:NO];
}
-(void)setCellSize:(CGSize)size animated:(BOOL)animated {
    _cellSize = size;
    if (animated)
        [UIView beginAnimations:nil context:nil];
    [self reposition];
    if (animated)
        [UIView commitAnimations];
}
-(NPGridViewCell*)generateCellAtIndex:(int)index {
    NPGridViewCell *cell;
    id contents = [delegate gridView:self cellAtIndex:index];
    if ([contents isKindOfClass:[NPGridViewCell class]])
        cell = contents;
    if ([self inSelectionMode]) {
        [cell setInSelectionMode:YES];
    }
    return cell;
}
-(void)renderRow:(int)row {
	if (row<0||row>=_rows) {
		return;
	}
	for (int column=0; column<_columns; column++) {
		int cellIndex = column+_columns*row;
		if (cellIndex>=_totalCells) {
			return;
		}
		NPGridViewCell *cell = nil;
		if (_reclaimationQueue!=nil&&
			[_reclaimationQueue count]>0) {
			for (UIView *subview in _reclaimationQueue) {
				if ([subview isKindOfClass:[NPGridViewCell class]]&&[subview representsIndex]==cellIndex) {
					[_reclaimationQueue removeObject:subview];
					cell = subview;
					break;
				}
			}
		}
		if (cell==nil) {
			cell = [self generateCellAtIndex:cellIndex];
			[_scrollView addSubview:cell];
		}
		cell.representsIndex = cellIndex;
		cell.parentGridView = self;
		cell.frame = [self positionForIndex:cellIndex];
        if (cell.frame.size.width>=self.bounds.size.width)
            cell.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
        else
            cell.autoresizingMask = 0;
		if (_selectionMode) {
			if ([self _indexIsSelected:cellIndex]) {
				[cell setSelected:YES];
			}
		}
	}
}
BOOL NSRangeContains(NSRange range, int number) {
	return (number>=range.location&&number<range.location+range.length);
}
-(NPGridViewCell*)cellForIndex:(int)index {
	for (id cell in _scrollView.subviews) {
		if ([cell isKindOfClass:[NPGridViewCell class]]&&[cell representsIndex]==index) {
			return cell;
		}
	}
	return nil;
}
CGPoint centerPointFromFrame(CGRect frame) {
	return CGPointMake(frame.origin.x+frame.size.width/2, frame.origin.y+frame.size.height/2);
}
/*CGFloat degreesToRadians(CGFloat degs) {
	return degs*M_PI/180;
}
CGFloat radiansToDegrees(CGFloat rads) {
	return rads*180/M_PI;
}
CGPoint movePoint(CGPoint initialPoint, CGFloat radians, CGFloat distance) {
	initialPoint.x = initialPoint.x+distance*cosf(radians);
	initialPoint.y = initialPoint.y+distance*sinf(radians);
	return initialPoint;
}
/*CGFloat distanceBetweenPoints (CGPoint first, CGPoint second) {
	CGFloat deltaX = second.x - first.x;
	CGFloat deltaY = second.y - first.y;
	return sqrt(deltaX*deltaX + deltaY*deltaY );
};
CGFloat angleBetweenPoints(CGPoint first, CGPoint second) {
	CGFloat height = first.y - second.y;
	CGFloat width = first.x - second.x;
	CGFloat rads = atan2(height,width);
	return rads;
}*/
/*-(void)blowOutAnimated:(BOOL)animated {
	_suspendRepositioning = YES;
	CGPoint centerPoint = CGPointMake(_scrollView.bounds.size.width/2, _scrollView.bounds.size.height/2+_scrollView.contentOffset.y);
	CGFloat distanceToMove = fmaxf(_scrollView.bounds.size.width, _scrollView.bounds.size.height)/2;
	if (animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:2.0];
	}
	for (NPGridViewCell *cell in _scrollView.subviews) {
		if (![cell isKindOfClass:[NPGridViewCell class]]) {
			continue;
		}
		CGPoint cellPosition = [cell center];
		//CGSize distanceFromCenter = CGSizeMake(cellPosition.x-centerPoint.x, cellPosition.y-centerPoint.y);
		CGFloat angleFromCenter = angleBetweenPoints(centerPoint, cellPosition);
		CGFloat thisDistance = (angleFromCenter>=0)? distanceToMove : distanceToMove*-1;
		angleFromCenter+=180;
		if (angleFromCenter>=360) {
			angleFromCenter-=360; 
		}
		cellPosition = movePoint(cellPosition, angleFromCenter, thisDistance);
		
		CGPoint a = CGPointMake(5, 5);
		CGPoint b = CGPointMake(6, 6);
		CGFloat angle = radiansToDegrees(angleBetweenPoints(a, b));
		
		[cell setCenter:cellPosition];
	}
	if (animated) {
		[UIView commitAnimations];
	}
}
-(void)blowIn {
	
}*/
-(void)disposeOfRow:(int)row {
	if (row<0||row>=_rows) {
		return;
	}
	int cellsFound = 0;
	NSRange cellsToRemove = NSMakeRange(row*_columns, _columns);
	for (int i=0; i<[_scrollView subviews].count&&cellsFound<_columns; i++) {
		NPGridViewCell *cell = [[_scrollView subviews] objectAtIndex:i];
		if (![cell isKindOfClass:[NPGridViewCell class]]) {
			continue;
		}
		if (NSRangeContains(cellsToRemove, cell.representsIndex) &&
            ![cell isDragging]) {
			[_cellsForReuse addObject:cell];
			[cell setSelected:NO];
			[cell removeFromSuperview];
			i--;
			cellsFound++;
		}
	}
}
-(int)currentRow {
	CGFloat rowHeight = _cellSize.height+[self _verticalCellPadding];
	return (int)floorf(([_scrollView contentOffset].y+[self _verticalCellPadding]/2.0)/rowHeight) - _rowBuffer;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (delegate&&[delegate respondsToSelector:@selector(gridView:didScrollTo:)]) {
		[delegate gridView:self didScrollTo:scrollView.contentOffset];
	}
	if (_suspendRepositioning) {
		return;
	}
	CGFloat row = [self currentRow];
	while (_lastRow<row) {
		[self disposeOfRow:_lastRow];
		[self renderRow:_lastRow+_rowsOnScreen+1];
		_lastRow++;
	}
	while (_lastRow>row) {
		[self disposeOfRow:_lastRow+_rowsOnScreen];
		[self renderRow:_lastRow-1];
		_lastRow--;
	}
	[_cellsForReuse removeAllObjects];
}
-(void)layoutSubviews {
	if (CGRectIsNull(_lastBounds)) {
		_lastBounds = self.bounds;
	} else if (!CGRectEqualToRect(self.bounds, _lastBounds)&&_alreadyLoaded) {
		[self reposition];
		_lastBounds = self.bounds;
	}
	if (!CGRectEqualToRect(_scrollView.frame, self.bounds)) {
		_scrollView.frame = self.bounds;
	}
	if (_selectionMode) {
		CGRect optionsFrame;
		optionsFrame.size.width = [_selectionModeOptions numberOfSegments]*86.0;
		optionsFrame.size.height = 44;
		optionsFrame.origin.x = (self.bounds.size.width-optionsFrame.size.width)/2;
		optionsFrame.origin.y = self.bounds.size.height-optionsFrame.size.height-32;
		[_selectionModeOptions setFrame:optionsFrame];
	}
}
-(BOOL)_indexIsSelected:(int)index {
	for (NSNumber *number in _selectedIndices) {
		if ([number intValue]==index) {
			return YES;
		}
	}
	return NO;
}
-(void)selectCellAtIndex:(int)index {
	if (![self _indexIsSelected:index]) {
		[_selectedIndices addObject:[NSNumber numberWithInt:index]];
	}
	NPGridViewCell *cell = [self cellForIndex:index];
	if (cell!=nil) {
		[cell setSelected:YES];
	}
}
-(void)deselectCellAtIndex:(int)index {
	for (NSNumber *number in _selectedIndices) {
		if ([number intValue]==index) {
			[_selectedIndices removeObject:number];
			break;
		}
	}
	NPGridViewCell *cell = [self cellForIndex:index];
	if (cell!=nil) {
		[cell setSelected:NO];
	}
}
-(void)_clickedCell:(NPGridViewCell*)cell {
	if (_selectionMode) {
		int index = [cell representsIndex];
		if ([self _indexIsSelected:index]) {
			[self deselectCellAtIndex:index];
		} else {
			[self selectCellAtIndex:index];
		}
	}
	else if ([delegate respondsToSelector:@selector(gridView:clickedCellAtIndex:)]) {
		[delegate gridView:self clickedCellAtIndex:[cell representsIndex]];
	}
}
-(void)_heldDownCell:(NPGridViewCell*)cell {
	if (!_selectionMode) {
		if ([delegate respondsToSelector:@selector(gridView:heldDownCellAtIndex:)]) {
			[delegate gridView:self heldDownCellAtIndex:[cell representsIndex]];
		}
	}
}
-(void)insertCellsAtIndices:(NSArray*)indicesAsNSNumbers animated:(BOOL)animated {
	if (animated) {
		[UIView beginAnimations:nil context:nil];
	}
	for (NSNumber *indexAsNSNumber in indicesAsNSNumbers) {
		int index = [indexAsNSNumber intValue];
		for (UIView *subview in _scrollView.subviews) {
			if ([subview isKindOfClass:[NPGridViewCell class]]&&
				[subview representsIndex]>=index) {
				[subview setRepresentsIndex:[subview representsIndex]+1];
			}
		}
	}
	_totalCells = [delegate numberOfCellsInGridView:self];
	[self reposition];
	if (animated) {
		[UIView commitAnimations];
	}	
}
-(void)reloadCellAtIndex:(int)index {
	NPGridViewCell *cell = [self cellForIndex:index];
	if (cell!=nil) {
		[_cellsForReuse addObject:cell];
		[cell removeFromSuperview];
		NPGridViewCell *newCell = [delegate gridView:self cellAtIndex:index];
		[_cellsForReuse removeAllObjects];
		[_scrollView addSubview:newCell];
		newCell.representsIndex = index;
		newCell.parentGridView = self;
		newCell.frame = [self positionForIndex:index];
	}
}
-(void)removeCellsAtIndices:(NSArray*)indicesAsNSNumbers animated:(BOOL)animated{
#define removeAnimationDuration 0.4
	if (animated) {
		[UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:removeAnimationDuration];
	}
	for (NSNumber *indexAsNSNumber in indicesAsNSNumbers) {
		int index = [indexAsNSNumber intValue];
		for (UIView *subview in _scrollView.subviews) {
			if ([subview isKindOfClass:[NPGridViewCell class]]&&
				[subview representsIndex]==index) {
                if (animated) {
                    subview.frame = [self convertRect:subview.frame fromView:_scrollView];
                    [subview retain];
                    [subview removeFromSuperview];
                    [self addSubview:subview];
                    [subview release];
                    subview.transform = CGAffineTransformMakeScale(0.01, 0.01);
                    subview.alpha = 0.0;
                    [subview performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:removeAnimationDuration];
                } else
                    [subview removeFromSuperview];
			}
		}
		for (UIView *subview in _scrollView.subviews) {
			if ([subview isKindOfClass:[NPGridViewCell class]]&&
				[subview representsIndex]>index) {
				int i = [subview representsIndex];
				i--;
				[subview setRepresentsIndex:i];
			}
		}
	}
	_totalCells = [delegate numberOfCellsInGridView:self];
	[self reposition];
	if (animated) {
		[UIView commitAnimations];
	}
}
-(BOOL)inSelectionMode {
	return _selectionMode;
}
-(void)enterSelectionModeWithOptions:(NSArray*)options {
	if (_selectionMode) {
		return;
	}
	_scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, _scrollView.contentSize.height+NPGridViewPadContentHeightDuringSelectionMode);
	if (_selectedIndices==nil) {
		_selectedIndices = [NSMutableArray new];
	}
	_selectionMode = YES;
	
	_selectionModeOptions = [[UISegmentedControl alloc] initWithItems:options];
	[_selectionModeOptions addTarget:self action:@selector(_clickedSelectionModeOption:) forControlEvents:UIControlEventValueChanged];
	[_selectionModeOptions setMomentary:YES];
	[_selectionModeOptions setSegmentedControlStyle:UISegmentedControlStyleBar];
	[self addSubview:[_selectionModeOptions autorelease]];
	CGRect optionsFrame;
	optionsFrame.size.width = [_selectionModeOptions numberOfSegments]*86.0;
	optionsFrame.size.height = 44;
	optionsFrame.origin.x = (self.bounds.size.width-optionsFrame.size.width)/2;
	optionsFrame.origin.y = self.bounds.size.height-optionsFrame.size.height-32;
	optionsFrame.origin.y+=44+33;
	[_selectionModeOptions setFrame:optionsFrame];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.2];
	[self layoutSubviews];
	[UIView commitAnimations];
    for (NPGridViewCell *cell in [_scrollView subviews]) {
        if (![cell isKindOfClass:[NPGridViewCell class]])
            continue;
        [cell setInSelectionMode:YES];
    }
}
-(void)_clickedSelectionModeOption:(id)sender {
	[delegate gridView:self selectionModeOptionAtIndexClicked:[_selectionModeOptions selectedSegmentIndex]];
}
-(void)endSelectionMode {
	if (_selectionMode) {
		_scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, _scrollView.contentSize.height-NPGridViewPadContentHeightDuringSelectionMode);
		[_selectedIndices release];
		
		CGRect optionsFrame;
		optionsFrame.size.width = [_selectionModeOptions numberOfSegments]*86.0;
		optionsFrame.size.height = 44;
		optionsFrame.origin.x = (self.bounds.size.width-optionsFrame.size.width)/2;
		optionsFrame.origin.y = self.bounds.size.height-optionsFrame.size.height-32;
		optionsFrame.origin.y+=44+33;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationDuration:0.2];
		_selectionModeOptions.frame = optionsFrame;
		[_selectionModeOptions performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.2];
		_selectionModeOptions = nil;
		[UIView commitAnimations];
		
		_selectedIndices = nil;
		for (NPGridViewCell *cell in _scrollView.subviews) {
            if (![cell isKindOfClass:[NPGridViewCell class]])
                continue;
			if ([cell selected]) {
				[cell setSelected:NO];
			}
            [cell setInSelectionMode:NO];
		}
	}
    [self reposition];
	_selectionMode = NO;
}
-(NSMutableArray*)selectedIndices {
	if (_selectionMode) {
		return _selectedIndices;
	} else {
		return nil;
	}
}
- (void)dealloc {
	if (_cellsForReuse) {
		[_cellsForReuse release];
	}
    [super dealloc];
}
-(BOOL)supportsSelectionMode {
    return [(NSObject*)delegate respondsToSelector:@selector(selectionModeOptionsForGridView:)];
}
-(BOOL)supportsReordering {
    return [(NSObject*)delegate respondsToSelector:@selector(gridView:movedCellFromIndex:toIndex:)];
}
-(void)cellDidMove:(NPGridViewCell*)moved mustReposition:(BOOL)mustReposition {
    int oldIndex = moved.representsIndex;
    int newIndexForMovedCell = [self indexForPosition:moved.center];
    if (oldIndex==newIndexForMovedCell &&
        !mustReposition)
        return;
    for (NPGridViewCell *aCell in _scrollView.subviews) {
        if (![aCell isKindOfClass:[NPGridViewCell class]])
            continue;
        int indexChange = 0;
        if (aCell.representsIndex>=newIndexForMovedCell)
            indexChange++;
        if (aCell.representsIndex>oldIndex)
            indexChange--;
        aCell.representsIndex+=indexChange;
        //if (aCell.representsIndex==newIndexForMovedCell)
        //    aCell.representsIndex = oldIndex;
    }
    moved.representsIndex = newIndexForMovedCell;
    [delegate gridView:self movedCellFromIndex:oldIndex toIndex:newIndexForMovedCell];
    [UIView animateWithDuration:0.4 animations:^(void) {
        [self reposition];
    }];
}
-(int)indexForPosition:(CGPoint)point {
    int row = floorf(point.y/(_cellSize.height+[self _verticalCellPadding]));
    int column = floorf((point.x)/_cellSize.width);
    int index = row*_columns+column;
    int numberOfCells = [delegate numberOfCellsInGridView:self];
    while (index>=numberOfCells) {
        index--;
    }
    return index;
}
@end
