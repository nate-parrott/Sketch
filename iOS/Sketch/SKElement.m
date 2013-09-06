//
//  SKElement.m
//  Sketch
//
//  Created by Nate Parrott on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKElement.h"
#import "SKImage.h"
#import "SKElementDefaults.h"

@implementation SKElement

#pragma mark Data
@synthesize frame=_frame;
@synthesize parentImage=_parentImage;

-(id)init {
    self = [super init];
    _properties = [NSMutableDictionary new];
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    self.frame = [aDecoder decodeCGRectForKey:@"Frame"];
    self.parentImage = [aDecoder decodeObjectForKey:@"ParentImage"];
    _properties = [aDecoder decodeObjectForKey:@"Properties"];
    if (!_properties) {_properties = [NSMutableDictionary new];}
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeCGRect:self.frame forKey:@"Frame"];
    [aCoder encodeObject:self.parentImage forKey:@"ParentImage"];
    [aCoder encodeObject:_properties forKey:@"Properties"];
}
-(NSData*)toData {
    SKImage* parent = self.parentImage;
    self.parentImage = nil; // detatch from parent image when serializing just this
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self];
    self.parentImage = parent;
    return data;
}
+(SKElement*)fromData:(NSData*)data {
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}
-(id)detatchedCopy {
    // TODO: possibly make this more efficient
    return [SKElement fromData:[self toData]];
}
#pragma mark UI
-(NSArray*)UIExposedProperties {
    return [SKElement UIExposedPropertiesForClass:[self class]];
}
+(NSArray*)UIExposedPropertiesForClass:(Class)cls {
    NSMutableArray* props = [NSMutableArray new];
    Class class = cls;
    while ([class isSubclassOfClass:[SKElement class]]) {
        NSString* path = [[NSBundle mainBundle] pathForResource:NSStringFromClass(class) ofType:@"props"];
        if (path) {
            NSArray* thisClassProps = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:0 error:nil];
            [props addObjectsFromArray:thisClassProps];
        }
        class = [class superclass];
    }
    return props;
}
@synthesize selected=_selected;
-(void)setSelected:(BOOL)selected {
    _selected = selected;
    
    [self didUpdate];
}
-(BOOL)hitTest:(CGPoint)point {
    return CGRectContainsPoint(self.frame, point);
}
#pragma mark Properties
-(id)propertyForKey:(NSString*)key {
    id val = [_properties objectForKey:key];
    if (!val)
        val = [SKElementDefaults defaultValueForProperty:key withElementClass:[self class]];
    return val;
}
-(void)setProperty:(id)prop forKey:(NSString*)key {
    if (prop==nil)
        [_properties removeObjectForKey:key];
    else
        [_properties setObject:prop forKey:key];
}
-(CGAffineTransform)transform {
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformRotate(transform, [[self propertyForKey:@"rotation"] floatValue]);
    
    // skew
    CGAffineTransform skewTransform = CGAffineTransformMake(1, 0, tanf([[self propertyForKey:@"skewX"] floatValue]), 1, 0, 0);
    transform = CGAffineTransformConcat(transform, skewTransform);
    
    return transform;
}
#pragma mark Drawing/dirtying
/*@synthesize layer=_layer;
-(void)setLayer:(CGLayerRef)layer {
    if (_layer) CGLayerRelease(_layer);
    _layer = layer;
    if (_layer) CGLayerRetain(_layer);
}
*/
-(void)didUpdate {
    [self.parentImage didUpdateChild:self];
}
-(UIImage*)thumbnailWithMaxDimension:(CGFloat)dimension {
    CGFloat aspectRatio = self.frame.size.width / self.frame.size.height;
    CGSize imageSize = aspectRatio > 1? CGSizeMake(dimension, dimension/aspectRatio) : CGSizeMake(dimension*aspectRatio, dimension);
    CGPoint scale = CGPointMake(imageSize.width/self.frame.size.width, imageSize.height/self.frame.size.height);
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(ctx, CGAffineTransformMakeScale(scale.x, scale.y));
    [self _draw];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
-(void)_draw {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    if ([[self propertyForKey:@"mask"] boolValue] && [self propertyForKey:@"maskImage"]) {
        SKImage* maskImage = [self propertyForKey:@"maskImage"];
        UIImage* mask = [maskImage thumbnailWithMaxDimension:MAX(self.frame.size.width, self.frame.size.height)];
        CGAffineTransform flipTransform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.frame.size.height), 1, -1);
        CGContextConcatCTM(ctx, flipTransform);
        CGContextClipToMask(ctx, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), mask.CGImage);
        CGContextConcatCTM(ctx, CGAffineTransformInvert(flipTransform));
    }
    if ([[self propertyForKey:@"showShadow"] boolValue]) {
        CGContextSetShadowWithColor(ctx, [[self propertyForKey:@"shadowOffset"] CGSizeValue], [[self propertyForKey:@"shadowRadius"] floatValue], [[self propertyForKey:@"shadowColor"] CGColor]);
    }
    
    CGContextConcatCTM(ctx, CGAffineTransformMakeTranslation(self.padding.left, self.padding.top));
    
    CGContextConcatCTM(ctx, CGAffineTransformMakeTranslation(self.innerSize.width/2, self.innerSize.height/2));
    
    CGPoint scaling = [self scalingToAccommodateTransform];
    CGFloat scale = MIN(scaling.x, scaling.y);
    CGContextConcatCTM(ctx, CGAffineTransformMakeScale(scale, scale));
    
    CGAffineTransform transform = self.transform;
    if (!CGAffineTransformIsIdentity(transform))
        CGContextConcatCTM(ctx, transform);
    CGContextConcatCTM(ctx, CGAffineTransformMakeTranslation(-self.innerSize.width/2, -self.innerSize.height/2));
    
    [self draw];
}
-(void)draw {
    // to be overriden by subclasses
}
-(UIEdgeInsets)padding {
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
    
    CGFloat allAroundBorder = 0;
    
    if ([[self propertyForKey:@"strokeShape"] boolValue]) {
        // stroke
        allAroundBorder += [[self propertyForKey:@"strokeWidth"] floatValue] / 2;
    }
    
    if ([[self propertyForKey:@"showShadow"] boolValue]) {
        // shadow
        allAroundBorder += [[self propertyForKey:@"shadowRadius"] floatValue];
        CGPoint shadowOffset = [[self propertyForKey:@"shadowOffset"] CGPointValue];
        if (shadowOffset.x<0) 
            padding.left += -shadowOffset.x;
        else
            padding.right += shadowOffset.x;
        if (shadowOffset.y<0)
            padding.top += -shadowOffset.y;
        else
            padding.bottom += shadowOffset.y;
    }
    
    padding.left += allAroundBorder;
    padding.right += allAroundBorder;
    padding.top += allAroundBorder;
    padding.bottom += allAroundBorder;
        
    return padding;
}
-(CGSize)innerSize {
    return CGSizeMake(self.frame.size.width-self.padding.left-self.padding.right, self.frame.size.height-self.padding.top-self.padding.bottom);
}
-(CGPoint)scalingToAccommodateTransform {
    CGAffineTransform transform = self.transform;
    CGFloat minX = -0.5;
    CGFloat maxX = 0.5;
    CGFloat minY = -0.5;
    CGFloat maxY = 0.5;
    for (CGFloat x=-0.5; x<=0.5; x++) {
        for (CGFloat y=-0.5; y<=0.5; y++) {
            CGPoint p = CGPointApplyAffineTransform(CGPointMake(x, y), transform);
            minX = MIN(minX, p.x);
            maxX = MAX(maxX, p.x);
            minY = MIN(minY, p.y);
            maxY = MAX(maxY, p.y);
        }
    }
    /*CGFloat minX = MAXFLOAT;
    CGFloat maxX = 0;
    CGFloat minY = MAXFLOAT;
    CGFloat maxY = 0;
    for (int x=0; x<=1; x++) {
        for (int y=0; y<=1; y++) {
            CGPoint p = CGPointApplyAffineTransform(CGPointMake(x, y), transform);
            minX = MIN(minX, p.x);
            maxX = MAX(maxX, p.x);
            minY = MIN(minY, p.y);
            maxY = MAX(maxY, p.y);
        }
    }*/
    return CGPointMake(1/(maxX-minX), 1/(maxY-minY));
}

@end
