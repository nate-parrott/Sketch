//
//  SKMagnificationLoupe.h
//  Sketch
//
//  Created by Nate Parrott on 9/22/12.
//
//

#import <UIKit/UIKit.h>

// frame must be square

@interface SKMagnificationLoupe : UIView {
    UIView* _clippingContainer;
    NSArray* _imageViews;
    CGSize _imageSize;
    CGPoint _focusPoint;
}

-(void)magnifyImages:(NSArray*)images toSize:(CGSize)size focusPoint:(CGPoint)focusPoint;

@end
