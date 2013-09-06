//
//  SKImage.m
//  Sketch
//
//  Created by Nate Parrott on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKImage.h"
#import "SKElement.h"
#import "SKAppDelegate.h"

@implementation SKImage
@synthesize size=_size;
@synthesize elements=_elements;
@synthesize delegate=_delegate;
@synthesize bundlePath=_bundlePath;
@synthesize parentElement=_parentElement;

-(void)setup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(save) name:SKAppDelegateShouldSaveData object:nil];
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    [self setup];
    _elements = [aDecoder decodeObjectForKey:@"Elements"];
    self.size = [aDecoder decodeCGSizeForKey:@"Size"];
    self.infiniteSize = [aDecoder decodeBoolForKey:@"InfiniteSize"];
    self.parentElement = [aDecoder decodeObjectForKey:@"ParentElement"];
    return self;
}
-(id)init {
    self = [super init];
    [self setup];
    _elements = [NSMutableArray new];
    self.size = CGSizeMake(500, 500);
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_elements forKey:@"Elements"];
    [aCoder encodeCGSize:self.size forKey:@"Size"];
    [aCoder encodeBool:self.infiniteSize forKey:@"InfiniteSize"];
    [aCoder encodeObject:self.parentElement forKey:@"ParentElement"];
}
-(void)save {
    NSString* imageDir = [self.bundlePath stringByAppendingPathComponent:@"image"];
    [NSKeyedArchiver archiveRootObject:self toFile:imageDir];
    
    NSString* thumbnailDir = [self.bundlePath stringByAppendingPathComponent:@"thumbnail.png"];
    [UIImagePNGRepresentation([self thumbnailWithMaxDimension:SKDocumentThumbnailMaxDimension]) writeToFile:thumbnailDir atomically:NO];
    
}
#pragma mark Elements
-(NSArray*)elements {
    // do we really need the copy?
    return [_elements copy];
}
-(void)addElement:(SKElement*)element {
    [_elements addObject:element];
    element.parentImage = self;
    [self.delegate image:self didAddElement:element];
}
-(void)removeElement:(SKElement*)element {
    [_elements removeObject:element];
    element.parentImage = nil;
    [self.delegate image:self didRemoveElement:element];
}
#pragma mark Layout/sizing
@synthesize infiniteSize=_infiniteSize;
-(CGSize)size {
    if (self.infiniteSize) {
        CGSize size = _size;
        for (SKElement* el in self.elements) {
            size.width = MAX(size.width, el.frame.origin.x+el.frame.size.width);
            size.height = MAX(size.height, el.frame.origin.y+el.frame.size.height);
        }
        return size;
    } else {
        return _size;
    }
}
-(void)bringElementToFront:(SKElement*)element {
    [_elements removeObject:element];
    [_elements addObject:element];
}
-(void)sendElementToBack:(SKElement*)element {
    [_elements removeObject:element];
    [_elements insertObject:element atIndex:0];
}
#pragma mark Dirtying/drawing
-(void)didUpdateChild:(SKElement*)child {
    [self.parentElement didUpdate];
    
    [self.delegate image:self didUpdateElement:child];
}
-(void)drawRect:(CGRect)imageRect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //CGContextConcatCTM(ctx, CGAffineTransformMakeScale(scale, scale));
    //CGContextConcatCTM(ctx, CGAffineTransformMakeTranslation(-imageRect.origin.x, -imageRect.origin.y));
    for (SKElement* element in self.elements) {
        if (CGRectIntersectsRect(element.frame, imageRect)) {
            CGContextSaveGState(ctx);
            CGContextConcatCTM(ctx, CGAffineTransformMakeTranslation(element.frame.origin.x, element.frame.origin.y));
            [element _draw];
            CGContextRestoreGState(ctx);
            //[element drawAtScale:CGPointMake(1, 1)];
        }
    }
}
/*-(void)drawInRect:(CGRect)rect {
    CGFloat scale = MIN(rect.size.width/self.size.width, rect.size.height/self.size.height);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGSize size = CGSizeMake(self.size.width*scale, self.size.height*scale);
    CGContextConcatCTM(ctx, CGAffineTransformMakeTranslation((rect.size.width-size.width)/2, (rect.size.height-size.height)/2));
    CGContextConcatCTM(ctx, CGAffineTransformMakeScale(scale, scale));
    [self drawRect:CGRectMake(0, 0, self.size.width, self.size.height)];
}*/
-(UIImage*)thumbnailWithMaxDimension:(CGFloat)dimension {
    CGSize imageSize = self.size;
    CGFloat aspectRatio = self.size.width / self.size.height;
    CGSize thumbnailSize = aspectRatio > 1? CGSizeMake(dimension, dimension/aspectRatio) : CGSizeMake(dimension*aspectRatio, dimension);
    CGPoint scale = CGPointMake(thumbnailSize.width/imageSize.width, thumbnailSize.height/imageSize.height);
    UIGraphicsBeginImageContext(thumbnailSize);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(ctx, CGAffineTransformMakeScale(scale.x, scale.y));
    [self drawRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
-(NSData*)PDFThumbnailWithMaxDimension:(CGFloat)dimension {
    CGSize imageSize = self.size;
    CGFloat aspectRatio = self.size.width / self.size.height;
    CGSize thumbnailSize = aspectRatio > 1? CGSizeMake(dimension, dimension/aspectRatio) : CGSizeMake(dimension*aspectRatio, dimension);
    CGPoint scale = CGPointMake(thumbnailSize.width/imageSize.width, thumbnailSize.height/imageSize.height);
    NSMutableData* data = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(data, CGRectMake(0, 0, thumbnailSize.width, thumbnailSize.height), nil);
    UIGraphicsBeginPDFPage();
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(ctx, CGAffineTransformMakeScale(scale.x, scale.y));
    [self drawRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    UIGraphicsEndPDFContext();
    return data;
}

@end
