//
//  SKNullViewController.h
//  Sketch
//
//  Created by Nate Parrott on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKNullViewController : UIViewController {
    UILabel* _label;
}
@property(strong,nonatomic)NSString* message;

@end
