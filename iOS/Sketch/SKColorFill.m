//
//  SKColorFill.m
//  Sketch
//
//  Created by Nate Parrott on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKColorFill.h"

@implementation SKColorFill
@synthesize color=_color;

-(id)initWithColor:(UIColor*)color {
    self = [super init];
    self.color = color;
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.color = [aDecoder decodeObjectForKey:@"Color"];
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.color forKey:@"Color"];
}

-(void)drawInRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [self.color CGColor]);
    CGContextFillRect(ctx, rect);
}
-(BOOL)isEqual:(id)object {
    return [object isKindOfClass:[SKColorFill class]] && [self.color isEqual:[object color]];
}

@end
