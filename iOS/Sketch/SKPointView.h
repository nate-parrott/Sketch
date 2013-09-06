//
//  SKPointView.h
//  Sketch
//
//  Created by Nate Parrott on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKPoint.h"

@class SKPointView;
@protocol SKPointViewDelegate <NSObject>

-(void)pointDidMove:(SKPointView*)pointView;

@end

@interface SKPointView : UIView {
    CGPoint _prevTouchPoint;
}

@property(strong,nonatomic)SKPoint* point;
@property(assign)id<SKPointViewDelegate> delegate;

@end
