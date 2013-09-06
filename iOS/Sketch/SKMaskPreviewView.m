//
//  SKMaskPreviewView.m
//  Sketch
//
//  Created by Nate Parrott on 9/25/12.
//
//

#import "SKMaskPreviewView.h"
#import "SKElement.h"
#import "SKImage.h"

@implementation SKMaskPreviewView

-(id)initWithMaskedElement:(SKElement*)element maskImage:(SKImage*)maskImage {
    self = [super init];
    _elementView = [UIImageView new];
    [self addSubview:_elementView];
    _elementMaskLayer = [CALayer layer];
    _maskedElement = element;
    _maskImage = maskImage;
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    self.layer.borderColor = [UIColor colorWithWhite:0.7 alpha:0.7].CGColor;
    self.layer.borderWidth = 1;
    self.layer.cornerRadius = 5;
    [self imageDidUpdate];
    return self;
}
-(void)layoutSubviews {
    [super layoutSubviews];
    _elementView.frame = self.bounds;
    _elementMaskLayer.frame = _elementView.bounds;
    if (!CGSizeEqualToSize(self.bounds.size, _lastRenderSize)) {
        [self imageDidUpdate];
    }
}
-(void)imageDidUpdate {
    _lastRenderSize = self.bounds.size;
    if (_lastRenderSize.width * _lastRenderSize.height == 0) return;
    if (_updateInProgress) {
        _needsUpdateAfter = YES;
    } else {
        _updateInProgress = YES;
        [self performSelectorInBackground:@selector(updateMask) withObject:nil];
    }
}
-(void)updateMask {
    @autoreleasepool {
        NSMutableDictionary* d = [NSMutableDictionary new];
        d[@"elementImage"] = [_maskedElement thumbnailWithMaxDimension:MAX(_lastRenderSize.width, _lastRenderSize.height)];
        if (_maskImage.elements.count) {
            d[@"maskImage"] = [_maskImage thumbnailWithMaxDimension:MAX(_lastRenderSize.width, _lastRenderSize.height)];
        }
        [self performSelectorOnMainThread:@selector(updatedMask:) withObject:d waitUntilDone:NO];
    }
}
-(void)updatedMask:(NSDictionary*)images {
    _elementView.image = images[@"elementImage"];
    _elementMaskLayer.contents = (id)[images[@"maskImage"] CGImage];
    _elementView.layer.mask = nil;
    if (_elementMaskLayer.contents) {
        _elementView.layer.mask = _elementMaskLayer;
    }
    if (_needsUpdateAfter) {
        _needsUpdateAfter = NO;
        [self performSelectorInBackground:@selector(updateMask) withObject:nil];
    } else {
        _updateInProgress = NO;
    }
}

@end
