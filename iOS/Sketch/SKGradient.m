//
//  SKGradient.m
//  Sketch
//
//  Created by Nate Parrott on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKGradient.h"

@implementation SKGradient
@synthesize colors, positions;
@synthesize type;
@synthesize startPoint, endPoint;

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.colors = [aDecoder decodeObjectForKey:@"Colors"];
    self.positions = [aDecoder decodeObjectForKey:@"Positions"];
    self.type = [aDecoder decodeIntForKey:@"Type"];
    self.startPoint = [aDecoder decodeCGPointForKey:@"StartPoint"];
    self.endPoint = [aDecoder decodeCGPointForKey:@"EndPoint"];
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.colors forKey:@"Colors"];
    [aCoder encodeObject:self.positions forKey:@"Positions"];
    [aCoder encodeInt:self.type forKey:@"Type"];
    [aCoder encodeCGPoint:startPoint forKey:@"StartPoint"];
    [aCoder encodeCGPoint:endPoint forKey:@"EndPoint"];
}
-(void)drawInRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSMutableArray* cgColors = [NSMutableArray new];
    for (UIColor* color in self.colors) {
        [cgColors addObject:(id)color.CGColor];
    }
    CGFloat* positionArray = malloc(sizeof(CGFloat)*self.positions.count);
    for (int i=0; i<positions.count; i++) {
        positionArray[i] = [[positions objectAtIndex:i] floatValue];
    }
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)cgColors, positionArray);
    CGPoint transformedStartPoint = CGPointMake(startPoint.x*rect.size.width+rect.origin.x, startPoint.y*rect.size.height+rect.origin.y);
    CGPoint transformedEndPoint = CGPointMake(endPoint.x*rect.size.width+rect.origin.x, endPoint.y*rect.size.height+rect.origin.y);
    if (self.type==SKGradientTypeLinear) {
        CGContextDrawLinearGradient(ctx, gradient, transformedStartPoint, transformedEndPoint, NULL);
    } else if (self.type==SKGradientTypeRadial) {
        CGFloat outerRadius = sqrtf(powf(rect.size.width, 2) + powf(rect.size.height, 2))/2;
        CGContextDrawRadialGradient(ctx, gradient, transformedStartPoint, 0, transformedEndPoint, outerRadius, NULL);
    }
    free(positionArray);
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}
-(BOOL)isEqual:(id)object {
    return [object isKindOfClass:[SKGradient class]] && [colors isEqualToArray:[object colors]] && [positions isEqualToArray:[object positions]] && CGPointEqualToPoint(self.startPoint, [object startPoint]) && CGPointEqualToPoint(self.endPoint, [object endPoint]);
}

@end
