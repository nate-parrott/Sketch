
//
//  SKMagnificationLoupe.m
//  Sketch
//
//  Created by Nate Parrott on 9/22/12.
//
//

#import "SKMagnificationLoupe.h"

@implementation SKMagnificationLoupe

-(void)layoutSubviews {
    [super layoutSubviews];
    _clippingContainer.layer.cornerRadius = [self clippingContainerFrame].size.width/2;
    _clippingContainer.frame = [self clippingContainerFrame];
    for (UIImageView* imageView in _imageViews) {
        CGRect imageViewFrame;
        imageViewFrame.size = _imageSize;
        imageViewFrame.origin.x = self.bounds.size.width/2 - _focusPoint.x;
        imageViewFrame.origin.y = self.bounds.size.height/2 - _focusPoint.y;
        imageView.frame = imageViewFrame;
    }
}
-(CGRect)outerEllipseFrame {
    return CGRectInset(self.bounds, 5, 5);
}
-(CGRect)innerEllipseFrame {
    return CGRectInset([self outerEllipseFrame], 2, 2);
}
-(CGRect)clippingContainerFrame {
    return CGRectInset([self innerEllipseFrame], 1, 1);
}
-(void)didMoveToSuperview {
    [super didMoveToSuperview];
    self.opaque = NO;
}
-(void)magnifyImages:(NSArray*)images toSize:(CGSize)size focusPoint:(CGPoint)focusPoint {
    for (UIImageView* imageView in _imageViews) {
        [imageView removeFromSuperview];
    }
    if (!_clippingContainer) {
        _clippingContainer = [UIView new];
        _clippingContainer.clipsToBounds = YES;
        [self addSubview:_clippingContainer];
    }
    NSMutableArray* imageViews = [NSMutableArray new];
    for (UIImage* image in images) {
        UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
        [_clippingContainer addSubview:imageView];
        [imageViews addObject:imageView];
    }
    _imageViews = imageViews;
    _imageSize = size;
    _focusPoint = focusPoint;
    
    [self setNeedsLayout];
}
-(void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextSetShadow(ctx, CGSizeZero, 4);
    CGContextSetFillColorWithColor(ctx, [UIColor grayColor].CGColor);
    CGContextFillEllipseInRect(ctx, [self outerEllipseFrame]);
    CGContextRestoreGState(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0.3 alpha:0.7].CGColor);
    CGContextSetLineWidth(ctx, 1);
    CGContextStrokeEllipseInRect(ctx, [self outerEllipseFrame]);
    CGContextStrokeEllipseInRect(ctx, [self innerEllipseFrame]);
}

@end
