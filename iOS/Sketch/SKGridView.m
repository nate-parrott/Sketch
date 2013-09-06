//
//  SKGridView.m
//  Sketch
//
//  Created by Nate Parrott on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKGridView.h"
#import "SKGridViewCell.h"

@implementation SKGridView
@synthesize scrollView=_scrollView;

-(void)setup {
    _cellReuseQueues = [NSMutableDictionary new];
    _cellsForIndices = [NSMutableDictionary new];
    
    UIScrollView* scrollView = [UIScrollView new];
    _scrollView = scrollView;
    [self addSubview:_scrollView];
    _scrollView.delegate = self;
    
    _selectedIndices = [NSMutableSet new];
}
-(id)init {
    self = [super init];
    [self setup];
    return self;
}
-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}

#pragma mark API
@synthesize delegate=_delegate;
-(void)setDelegate:(id<SKGridViewDelegate>)delegate {
    _delegate = delegate;
    [self reloadData];
}
-(void)reloadData {
    for (SKGridViewCell* cell in _cellsForIndices.allValues) {
        [self disposeOfCell:cell animated:NO];
    }
    [_cellsForIndices removeAllObjects];
    _totalCells = [self.delegate numberOfCellsInGridView:self];
    [self reloadLayout];
}
-(int)shiftForIndex:(int)oldIndex whenInsertingCells:(NSArray*)toInsert andDeletingCells:(NSArray*)toRemove {
    int shift = 0;
    for (NSNumber* idx in toRemove) {
        if (idx.intValue < oldIndex) {
            shift--;
        }
    }
    for (NSNumber* idx in toInsert) {
        if (idx.intValue <= oldIndex) {
            shift++;
        }
    }
    return shift;
}
-(void)removeCells:(NSArray*)toRemove andInsertCellsAtIndices:(NSArray*)toInsert animated:(BOOL)animated {
    // remove deleted cells and re-index old cells
    NSMutableDictionary* cellsForNewIndices = [NSMutableDictionary new];
    for (NSNumber* oldIndex in [[_cellsForIndices allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        SKGridViewCell* cell = [_cellsForIndices objectForKey:oldIndex];
        if ([toRemove containsObject:oldIndex]) {
            [self disposeOfCell:cell animated:YES];
        } else {
            int shift = [self shiftForIndex:oldIndex.intValue whenInsertingCells:toInsert andDeletingCells:toRemove];
            //NSLog(@"shifting %i to %i", oldIndex.intValue, oldIndex.intValue+shift);
            [cellsForNewIndices setObject:cell forKey:[NSNumber numberWithInt:oldIndex.intValue+shift]];
        }
    }
    _cellsForIndices = cellsForNewIndices;
    
    // re-index selected indices
    NSMutableSet* newSelectedIndices = [NSMutableSet new];
    for (NSNumber* oldIndex in _selectedIndices) {
        if (![toRemove containsObject:oldIndex]) {
            int shift = [self shiftForIndex:oldIndex.intValue whenInsertingCells:toInsert andDeletingCells:toRemove];
            [newSelectedIndices addObject:[NSNumber numberWithInt:oldIndex.intValue+shift]];
        }
    }
    _selectedIndices = newSelectedIndices;
    
    _totalCells += [self shiftForIndex:_totalCells+1 whenInsertingCells:toInsert andDeletingCells:toRemove];
    
    for (NSNumber* i in toInsert) {
        SKGridViewCell* cell = [self loadCellForIndex:i.intValue];
        cell.frame = [self frameForCellAtIndex:i.intValue];
        cell.transform = CGAffineTransformMakeScale(0.001, 0.001);
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutSubviews];
    }];
}
#pragma mark Cell loading
-(SKGridViewCell*)dequeueCellWithIdentifier:(NSString*)reuseID {
    return nil;
}
-(SKGridViewCell*)cellForIndex:(int)index {
    return [_cellsForIndices objectForKey:[NSNumber numberWithInt:index]];
}
-(SKGridViewCell*)loadCellForIndex:(int)index {
    SKGridViewCell* cell = [self.delegate gridView:self cellForIndex:index];
    cell.parentGridView = self;
    [_cellsForIndices setObject:cell forKey:[NSNumber numberWithInt:index]];
    [self.scrollView addSubview:cell];
    [cell setInSelectionMode:self.inSelectionMode];
    [cell setSelected:[self isCellSelected:index]];
    return cell;
}
-(void)disposeOfCell:(SKGridViewCell*)cell animated:(BOOL)animated {
    [cell removeFromSuperview];
    if (animated) {
        [self addSubview:cell];
        cell.frame = [self convertRect:cell.frame fromView:self.scrollView];
        [UIView animateWithDuration:0.3 animations:^{
            cell.transform = CGAffineTransformMakeScale(0.001, 0.001);
        } completion:^(BOOL finished) {
            [cell removeFromSuperview];
        }];
    }
}
-(int)indexOfCell:(SKGridViewCell*)cell {
    for (NSNumber* idx in _cellsForIndices.keyEnumerator) {
        if ([[_cellsForIndices objectForKey:idx] isEqual:cell]) {
            return [idx intValue];
        }
    }
    return -1;
}
#pragma mark Layout
-(void)setContentInsets:(UIEdgeInsets)contentInsets {
    _scrollView.contentInset = contentInsets;
    [self reloadLayout];
}
-(UIEdgeInsets)contentInsets {
    return _scrollView.contentInset;
}
-(CGFloat)contentAreaWidth {
    return _scrollView.bounds.size.width-_scrollView.contentInset.left-_scrollView.contentInset.right;
}
-(void)layoutSubviews {
    _scrollView.frame = self.bounds;
    _scrollView.contentSize = CGSizeMake(self.contentAreaWidth, [self numRows]*[self rowHeight]+[self cellSpacing]);
    [self reloadLayout];
}
-(void)reloadLayout {
    _lastVisibleRange = NSMakeRange(0, 0);
    [self updateVisibleCells];
}
-(void)updateVisibleCells {
    NSRange visible = [self visibleRange];
    if (!NSEqualRanges(visible, _lastVisibleRange)) {
        /*NSLog(@"LAYOUT OUT\n===========");
        NSLog(@"%i cells: %i cols; %i rows", [self.delegate numberOfCellsInGridView:self], [self numColumns], [self numRows]);
        NSLog(@"Cell spacing: %f", [self cellSpacing]);
        NSLog(@"\n");
        */
        _lastVisibleRange = visible;
        for (NSNumber *idx in _cellsForIndices.allKeys) {
            if (idx.intValue < _lastVisibleRange.location || idx.intValue >= _lastVisibleRange.location+_lastVisibleRange.length) {
                [self disposeOfCell:[_cellsForIndices objectForKey:idx] animated:NO];
                [_cellsForIndices removeObjectForKey:idx];
            }
        }
        for (int i=_lastVisibleRange.location; i<MIN(_totalCells, _lastVisibleRange.location+_lastVisibleRange.length); i++) {
            NSNumber* idx = [NSNumber numberWithInt:i];
            SKGridViewCell* cell = [_cellsForIndices objectForKey:idx];
            if (!cell) {
                cell = [self loadCellForIndex:i];
            }
            //NSLog(@"%i: %@", i, NSStringFromCGRect([self frameForCellAtIndex:i]));
            if (!CGAffineTransformIsIdentity(cell.transform)) {
                cell.transform = CGAffineTransformIdentity;
            }
            cell.frame = [self frameForCellAtIndex:i];
        }
    }
}
-(CGRect)frameForCellAtIndex:(int)index {
    int col = index % [self numColumns];
    int row = index / [self numColumns];
    CGPoint center = CGPointMake([self cellSpacing]*(col+1) + self.cellSize.width*(col+0.5), [self rowHeight]*row + [self cellSpacing] + self.cellSize.height/2);
    CGRect frame;
    frame.size = self.cellSize;
    frame.origin = CGPointMake(center.x - frame.size.width/2, center.y - frame.size.height/2);
    return CGRectIntegral(frame);
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateVisibleCells];
}
@synthesize cellSize=_cellSize;
-(void)setCellSize:(CGSize)cellSize {
    _cellSize = cellSize;
}
-(int)numColumns {
    return MAX(1, (int)self.contentAreaWidth/_cellSize.width);
}
-(int)numRows {
    return (int)ceilf([self.delegate numberOfCellsInGridView:self]*1.0 / [self numColumns]);
}
-(CGFloat)cellSpacing {
    return (self.contentAreaWidth - [self numColumns]*self.cellSize.width) / ([self numColumns] + 1.0);
}
-(CGFloat)rowHeight {
    return self.cellSize.height + [self cellSpacing];
}
-(NSRange)visibleRange {
    CGRect visibleRect;
    visibleRect.origin = self.scrollView.contentOffset;
    visibleRect.size = _scrollView.bounds.size;
    return NSMakeRange(MAX((visibleRect.origin.y/[self rowHeight]-1)*[self numColumns], 0), (visibleRect.size.height/[self rowHeight]+2)*[self numColumns]);
}
#pragma mark Interaction
-(void)clickedCell:(SKGridViewCell*)cell {
    int idx = [self indexOfCell:cell];
    if (_inSelectionMode) {
        [self setSelected:![self isCellSelected:idx] forCell:idx];
    } else {
        [self.delegate gridView:self clickedCellAtIndex:idx];
    }
}
#pragma mark Selection
-(void)setSelected:(BOOL)selected forCell:(int)index {
    if ([self isCellSelected:index] != selected) {
        if (selected) {
            [_selectedIndices addObject:[NSNumber numberWithInt:index]];
        } else {
            [_selectedIndices removeObject:[NSNumber numberWithInt:index]];
        }
        [[self cellForIndex:index] setSelected:selected];
    }
}
-(BOOL)isCellSelected:(int)index {
    return [_selectedIndices containsObject:[NSNumber numberWithInt:index]];
}
-(void)setSelectedIndices:(NSSet *)newSelectedIndices {
    for (NSNumber* idx in self.selectedIndices) {
        [self setSelected:NO forCell:idx.intValue];
    }
    for (NSNumber* idx in newSelectedIndices) {
        [self setSelected:YES forCell:idx.intValue];
    }
}
-(NSSet*)selectedIndices {
    return [_selectedIndices copy];
}
@synthesize inSelectionMode=_inSelectionMode;
-(void)setInSelectionMode:(BOOL)inSelectionMode {
    for (SKGridViewCell* cell in _cellsForIndices.allValues) {
        [cell setInSelectionMode:inSelectionMode];
    }
    
    _inSelectionMode = inSelectionMode;
    if (!_inSelectionMode) {
        [self setSelectedIndices:[NSSet set]];
    }
}

@end
