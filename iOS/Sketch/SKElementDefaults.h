//
//  SKElementDefaults.h
//  Sketch
//
//  Created by Nate Parrott on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKElementDefaults : NSObject

+(id)defaultValueForProperty:(NSString*)property withElementClass:(Class)elementClass;

@end
