//
//  SKSavedElementStore.m
//  Sketch
//
//  Created by Nate Parrott on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKSavedElementStore.h"
#import "SKAppDelegate.h"
#import "SKPathElement.h"

@implementation SKSavedElementStore

SKSavedElementStore* _SKSavedElementStoreShared = nil;
+(SKSavedElementStore*)shared {
    if (!_SKSavedElementStoreShared) {
        _SKSavedElementStoreShared = [SKSavedElementStore new];
    }
    return _SKSavedElementStoreShared;
}
#pragma mark Data persistence
+(NSString*)dataPath {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES) objectAtIndex:0] stringByAppendingPathComponent:@"SavedElementStore"];
}
-(id)init {
    self = [super init];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[SKSavedElementStore dataPath]]) {
        _savedElements = [NSKeyedUnarchiver unarchiveObjectWithFile:[SKSavedElementStore dataPath]];
    } else {
        _savedElements = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"DefaultSavedElementStore" ofType:@""]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(save) name:SKAppDelegateShouldSaveData object:nil];
    return self;
}
-(void)save {
    if (_modified) {
        [NSKeyedArchiver archiveRootObject:_savedElements toFile:[SKSavedElementStore dataPath]];
        _modified = NO;
    }
}
#pragma mark Access
-(void)storeElement:(SKElement*)element {
    [_savedElements insertObject:element atIndex:0];
    _modified = YES;
}
-(NSArray*)storedElements {
    return _savedElements;
}
-(void)removeElementAtIndex:(int)index {
    [_savedElements removeObjectAtIndex:index];
    _modified = YES;
}

@end
