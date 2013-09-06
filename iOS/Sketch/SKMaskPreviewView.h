//
//  SKMaskPreviewView.h
//  Sketch
//
//  Created by Nate Parrott on 9/25/12.
//
//

#import <UIKit/UIKit.h>

@class SKImage;
@class SKElement;

@interface SKMaskPreviewView : UIView {
    UIImageView* _elementView;
    CALayer* _elementMaskLayer;
    BOOL _updateInProgress;
    BOOL _needsUpdateAfter;
    SKElement* _maskedElement;
    SKImage* _maskImage;
    CGSize _lastRenderSize;
}

-(void)imageDidUpdate;

-(id)initWithMaskedElement:(SKElement*)element maskImage:(SKImage*)maskImage;

@end
