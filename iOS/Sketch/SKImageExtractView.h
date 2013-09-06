//
//  SKImageExtractView.h
//  Sketch
//
//  Created by Nate Parrott on 9/22/12.
//
//

#import <UIKit/UIKit.h>
#import "SKMagnificationLoupe.h"

@class SKImageExtractView;
@protocol SKImageExtractViewDelegate <NSObject>

-(void)imageExtractView:(SKImageExtractView*)extractView didExtractImage:(UIImage*)extracted;

@end

@class ImageWrapper;

@interface SKImageExtractView : UIView {
    UIImage* _image;
    UIImageView* _imageView;
    UIImageView* _selectionOutlineView;
    UIBezierPath* _selectionPath;
    CGPoint _lastTouchPoint;
    CGPoint _lastEdgePoint;
    SKMagnificationLoupe* _magnificationLoupe;
    
    ImageWrapper* _edgeImage;
    UIImage* _edgeImageGrayscale;
    CGSize _lastEdgeImageSize;
    
    CGFloat _lastLineSegmentAngle;
}

-(void)setImage:(UIImage*)image;
-(void)reset;
@property(assign)IBOutlet id<SKImageExtractViewDelegate> delegate;

/*
// returns array of NSValues each holding a pointer to a std::vector<CGPoint>
+(NSArray*)traceContoursInPortion:(CGRect)portion ofImage:(UIImage*)image;
+(UIImage*)annotateEdges:(UIImage*)image;*/


+(NSArray*)pathFromPoint:(CGPoint)start boundingAreaStart:(CGPoint)boundingAreaStart to:(CGPoint)end radius:(CGFloat)radius inImageOfSize:(CGSize)imageSize edgeImage:(UIImage*)edges;

@end
