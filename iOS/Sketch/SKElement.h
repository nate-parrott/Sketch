//
//  SKElement.h
//  Sketch
//
//  Created by Nate Parrott on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKImage;
@interface SKElement : NSObject <NSCoding/*, SKPointViewDelegate*/> {
    //SKPointView* _centerPoint;
    //SKPointView* _sizePoint;
    //CGPoint _layerScale;
    NSMutableDictionary* _properties;
}

@property CGRect frame;
@property(assign)SKImage* parentImage;
-(void)didUpdate;

-(NSArray*)UIExposedProperties;
+(NSArray*)UIExposedPropertiesForClass:(Class)cls;
//@property(strong)NSMutableDictionary* properties;

-(id)propertyForKey:(NSString*)key;
-(void)setProperty:(id)prop forKey:(NSString*)key;

@property(nonatomic) BOOL selected;
//-(NSArray*)editablePointViews;

//-(CGLayerRef)drawAtSize:(CGSize)size;
//-(CGLayerRef)drawAtScale:(CGPoint)scale;

-(void)draw;
-(void)_draw;
-(UIImage*)thumbnailWithMaxDimension:(CGFloat)dimension;
-(UIEdgeInsets)padding;
-(CGSize)innerSize;
-(BOOL)hitTest:(CGPoint)point;

-(CGAffineTransform)transform;

-(NSData*)toData;
+(SKElement*)fromData:(NSData*)data;
-(id)detatchedCopy;

//@property(nonatomic) CGLayerRef layer;

@end
