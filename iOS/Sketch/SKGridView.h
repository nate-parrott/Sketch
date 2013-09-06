//
//  SKGridView.h
//  Sketch
//
//  Created by Nate Parrott on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SKGridView;
@class SKGridViewCell;
@protocol SKGridViewDelegate <NSObject>

-(int)numberOfCellsInGridView:(SKGridView*)gridView;
-(SKGridViewCell*)gridView:(SKGridView*)gridView cellForIndex:(int)index;
-(void)gridView:(SKGridView*)gridView clickedCellAtIndex:(int)index;

@end

@interface SKGridView : UIView <UIScrollViewDelegate> {
    NSMutableDictionary* _cellReuseQueues;
    NSMutableDictionary* _cellsForIndices;
    NSRange _lastVisibleRange;
    int _totalCells;
    NSMutableSet* _selectedIndices;
}

@property(assign,readonly)UIScrollView* scrollView;
@property(assign,nonatomic)IBOutlet id<SKGridViewDelegate> delegate;
-(SKGridViewCell*)dequeueCellWithIdentifier:(NSString*)reuseID;
-(void)reloadData;
-(void)removeCells:(NSArray*)toRemove andInsertCellsAtIndices:(NSArray*)toInsert animated:(BOOL)animated;
-(SKGridViewCell*)cellForIndex:(int)index;
@property(nonatomic) CGSize cellSize;
@property(nonatomic) UIEdgeInsets contentInsets;

@property(nonatomic,strong)NSSet* selectedIndices;
@property(nonatomic)BOOL inSelectionMode;

-(void)clickedCell:(SKGridViewCell*)cell;

@end
