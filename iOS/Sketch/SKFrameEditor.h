//
//  SKFrameEditor.h
//  Sketch
//
//  Created by Nate Parrott on 9/19/12.
//
//

#import <UIKit/UIKit.h>

@class SKFrameEditor;
@protocol SKFrameEditorDelegate <NSObject>

-(void)frameEditor:(SKFrameEditor*)frameEditor didChangeFrameFrom:(CGRect)oldFrame toFrame:(CGRect)newFrame;

@end

@class SKImageEditorView;

@interface SKFrameEditor : UIView {
    struct {
        unsigned char leftEdge: 1;
        unsigned char rightEdge: 1;
        unsigned char topEdge: 1;
        unsigned char bottomEdge: 1;
    } _dragging;
    NSArray* _handles;
    NSMutableArray* _touchesDown;
    CGPoint _initialTouchPos;
    CGRect _frameAtStartOfTouch;
}

@property(nonatomic)CGRect rect;
@property(assign)id<SKFrameEditorDelegate> delegate;
@property(assign)SKImageEditorView* imageView;

@property(nonatomic)CGFloat scale;

@end
