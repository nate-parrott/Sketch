//
//  SKImageFill.m
//  Sketch
//
//  Created by Nate Parrott on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKImageFill.h"

@implementation SKImageFill
@synthesize image=_image;
@synthesize fillMode=_fillMode;

-(void)drawInRect:(CGRect)rect {
    if (self.fillMode==SKImageFillTile) {
        CGFloat scale = CGContextGetCTM(UIGraphicsGetCurrentContext()).a;
        UIImage* scaledImage = [UIImage imageWithCGImage:self.image.CGImage scale:1/scale orientation:self.image.imageOrientation];
        [scaledImage drawAsPatternInRect:rect];
    } else if (self.fillMode==SKImageFillScale) {
        [self.image drawInRect:rect];
    } else if (self.fillMode==SKImageFillAspectScale) {
        CGSize drawAtSize = self.image.size;
        CGPoint scale = CGPointMake(rect.size.width/drawAtSize.width, rect.size.height/drawAtSize.height);
        drawAtSize.width *= MIN(scale.x, scale.y);
        drawAtSize.height *= MIN(scale.x, scale.y);
        CGRect imageRect = CGRectMake(rect.origin.x + (rect.size.width-drawAtSize.width)/2, rect.origin.y + (rect.size.height-drawAtSize.height)/2, drawAtSize.width, drawAtSize.height);
        [self.image drawInRect:imageRect];
    }
}
-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.image = [UIImage imageWithData:[aDecoder decodeObjectForKey:@"ImageData"]];
    self.fillMode = [aDecoder decodeIntForKey:@"FillMode"];
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:UIImagePNGRepresentation(self.image) forKey:@"ImageData"];
    [aCoder encodeInt:self.fillMode forKey:@"FillMode"];
}
-(BOOL)isEqual:(id)object {
    if (object==self) return YES;
    return [object isKindOfClass:[SKImageFill class]] && [self.image isEqual:[object class]];
}

@end
