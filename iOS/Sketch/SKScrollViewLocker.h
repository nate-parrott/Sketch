//
//  SKScrollViewLocker.h
//  Sketch
//
//  Created by Nate Parrott on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKScrollViewLocker : UIView {
    UIButton* _button;
}

@property(assign)IBOutlet UIScrollView* scrollView;

@end
