//
//  SKGroupElement.m
//  Sketch
//
//  Created by Nate Parrott on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKGroupElement.h"
#import "SKImage.h"

@implementation SKGroupElement
@synthesize childImage=_childImage;

-(id)init {
    self = [super init];
    self.childImage = [SKImage new];
    self.childImage.parentElement = self;
    /*__block typeof(self) bself = self; // so that the block doesn't retain self, leading to a retain cycle (see http://stackoverflow.com/questions/4352561/retain-cycle-on-self-with-blocks )
    self.childImage.updateCallback = ^() {
        [bself didUpdate];
    };*/
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.childImage = [aDecoder decodeObjectForKey:@"ChildImage"];
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.childImage forKey:@"ChildImage"];
}
-(void)draw {
    if ([[self propertyForKey:@"tileSubImage"] boolValue]) { // draw at nominal size, then tile the damn thing
        CGAffineTransform transform = CGContextGetCTM(UIGraphicsGetCurrentContext());
        CGPoint scale = CGPointMake(transform.a, -transform.d);
        CGSize imageSize = self.childImage.size;
        UIGraphicsBeginImageContext(CGSizeMake(imageSize.width*scale.x, imageSize.height*scale.y));
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), scale.x, scale.y);
        [self.childImage drawRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
        UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [image drawAsPatternInRect:CGRectMake(0, 0, self.innerSize.width, self.innerSize.height)];
    } else {
        CGPoint scale = CGPointMake(self.innerSize.width/self.childImage.size.width, self.innerSize.height/self.childImage.size.height);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextConcatCTM(ctx, CGAffineTransformMakeScale(scale.x, scale.y));
        [self.childImage drawRect:CGRectMake(0, 0, self.childImage.size.width, self.childImage.size.height)];
    }
}
+(SKGroupElement*)groupElements:(NSArray*)elements fromImage:(SKImage*)rootImage {
    return [self groupElements:elements fromImage:rootImage asDetatchedCopy:NO];
}
+(SKGroupElement*)groupElements:(NSArray*)elements fromImage:(SKImage*)rootImage asDetatchedCopy:(BOOL)copy {
    CGFloat minX = MAXFLOAT;
    CGFloat minY = MAXFLOAT;
    CGFloat maxX = 0;
    CGFloat maxY = 0;
    for (SKElement* element in elements) {
        minX = MIN(minX, element.frame.origin.x);
        minY = MIN(minY, element.frame.origin.y);
        maxX = MAX(maxX, element.frame.origin.x+element.frame.size.width);
        maxY = MAX(maxY, element.frame.origin.y+element.frame.size.height);
    }
    
    SKGroupElement* group = [SKGroupElement new];
    if (copy) {
        
    } else {
        group.parentImage = rootImage;
        [rootImage addElement:group];
    }
    group.childImage.size = CGSizeMake(maxX-minX, maxY-minY);
    group.frame = CGRectMake(minX, minY, maxX-minX, maxY-minY);
    
    for (SKElement* element in elements) {
        SKElement* el = element;
        if (copy)
            el = [el detatchedCopy];
        else
            [rootImage removeElement:el];
        [group.childImage addElement:el];
        CGRect frame = el.frame;
        frame.origin.x -= minX;
        frame.origin.y -= minY;
        el.frame = frame;
        [el didUpdate];
    }
    if (!copy)
        [group didUpdate];
    return group;
}
-(NSArray*)ungroupAndRemove {
    NSMutableArray* freedElements = [NSMutableArray new];
    CGPoint scale = CGPointMake(self.frame.size.width/self.childImage.size.width, self.frame.size.height/self.childImage.size.height);
    for (SKElement* el in self.childImage.elements) {
        [self.childImage removeElement:el];
        [self.parentImage addElement:el];
        CGRect frame = el.frame;
        frame.origin.x = self.frame.origin.x  + frame.origin.x * scale.x;
        frame.origin.y = self.frame.origin.y + frame.origin.y * scale.y;
        frame.size.width *= scale.x;
        frame.size.height *= scale.y;
        el.frame = frame;
        [el didUpdate];
        [freedElements addObject:el];
    }
    [self.parentImage removeElement:self];
    return freedElements;
}

@end
