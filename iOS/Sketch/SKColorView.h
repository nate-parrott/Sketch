//
//  SKColorView.h
//  Sketch
//
//  Created by Nate Parrott on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKColorView : UIView {
    
}

@property(nonatomic,strong)id color; // supports UIColor or SKFill

@property(assign)id clickTarget;
@property SEL clickSelector;

@end
