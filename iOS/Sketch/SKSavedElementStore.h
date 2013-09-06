//
//  SKSavedElementStore.h
//  Sketch
//
//  Created by Nate Parrott on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKElement;
@interface SKSavedElementStore : NSObject {
    NSMutableArray* _savedElements;
    BOOL _modified;
}

+(SKSavedElementStore*)shared;
-(void)save;
-(void)storeElement:(SKElement*)element;
-(NSArray*)storedElements;
-(void)removeElementAtIndex:(int)index;

@end
