//
//  SKColorFill.h
//  Sketch
//
//  Created by Nate Parrott on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKFill.h"

@interface SKColorFill : SKFill <NSCoding>

@property(strong)UIColor* color;
-(id)initWithColor:(UIColor*)color;

@end
