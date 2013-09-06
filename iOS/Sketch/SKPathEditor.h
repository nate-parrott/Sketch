//
//  SKPathEditor.h
//  Sketch
//
//  Created by Nate Parrott on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKEditor.h"
#import "SKPathElement.h"
#import "SKPathEditView.h"

@interface SKPathEditor : SKEditor {
    SKPathEditView* _editView;
}

@property(strong)SKPathElement* element; 

@end
