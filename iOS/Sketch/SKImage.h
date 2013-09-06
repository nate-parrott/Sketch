//
//  SKImage.h
//  Sketch
//
//  Created by Nate Parrott on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef void(^SKImageDidUpdateCallback)();
@class SKImage, SKElement;
@protocol SKImageDelegate <NSObject>

-(void)image:(SKImage*)image didAddElement:(SKElement*)element;
-(void)image:(SKImage*)image didRemoveElement:(SKElement*)element;
-(void)image:(SKImage*)image didUpdateElement:(SKElement*)element;

@end

@interface SKImage : NSObject <NSCoding> {
    NSMutableArray* _elements;
}
@property(assign)id<SKImageDelegate> delegate;

@property(strong, readonly)NSArray* elements;
-(void)addElement:(SKElement*)element;
-(void)removeElement:(SKElement*)element;

-(void)bringElementToFront:(SKElement*)element;
-(void)sendElementToBack:(SKElement*)element;

@property(nonatomic) CGSize size;
@property BOOL infiniteSize;

-(void)didUpdateChild:(SKElement*)child;

-(void)drawRect:(CGRect)imageRect; // draws the portion of the image in this rect.
// -(void)drawInRect:(CGRect)rect; // draws the entire image inside this rect
-(UIImage*)thumbnailWithMaxDimension:(CGFloat)dimension;
-(NSData*)PDFThumbnailWithMaxDimension:(CGFloat)dimension;


@property(strong)NSString* bundlePath; // the code that loads or creates this document should set a value for this, and create the appropriate dir

-(void)save;

@property(assign)SKElement* parentElement; // if this image is the childImage for a GroupElement or the mask of any element, this points to it

@end
