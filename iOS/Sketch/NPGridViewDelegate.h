//
//  NPGridViewDelegate.h
//  NPGridView2
//
//  Created by Nate Parrott on 10/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef NPGridView2_NPGridViewDelegate_h
#define NPGridView2_NPGridViewDelegate_h

@protocol NPGridView2Delegate <NSObject>

-(int)numberOfCellsInGridView:(NPGridView2*)gridView;
-(CGSize)sizeForCellsInGridView:(NPGridView2*)gridView;
-(NPGridViewCell*)gridView:(NPGridView2*)gridView cellAtIndex:(int)index;
-(void)gridView:(NPGridView2*)gridView didScrollTo:(CGPoint)offset;
-(void)gridView:(NPGridView2*)gridView clickedCellAtIndex:(int)index;
-(void)gridView:(NPGridView2*)gridView heldDownCellAtIndex:(int)index;
@end

#endif
