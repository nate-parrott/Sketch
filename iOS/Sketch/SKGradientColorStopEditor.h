//
//  SKGradientColorStopEditor.h
//  Sketch
//
//  Created by Nate Parrott on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKGradient.h"

@class SKGradientEditor, SKGradientColorStop;
@interface SKGradientColorStopEditor : UIView {
    IBOutlet SKGradientEditor* _gradientEditor;
}
@property(strong,nonatomic)SKGradient* gradient;
-(void)updatedColorStops;
-(SKGradientEditor*)gradientEditor;

@end
