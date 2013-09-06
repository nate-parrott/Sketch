//
//  SKResizer.h
//  Sketch
//
//  Created by Nate Parrott on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SKResizer;
@protocol SKResizerDelegate <NSObject>

-(void)didResize:(SKResizer*)resizer;

@end

@interface SKResizer : UIView

@property(nonatomic)CGSize size;
@property(assign)id<SKResizerDelegate> delegate;

@end
