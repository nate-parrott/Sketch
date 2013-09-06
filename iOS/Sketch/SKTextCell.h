//
//  SKTextCell.h
//  Sketch
//
//  Created by Nate Parrott on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKPropertyCell.h"

@interface SKTextCell : SKPropertyCell <UITextViewDelegate> {
    UITextView* _textView;
}

@end
