//
//  SKActionCell.h
//  Sketch
//
//  Created by Nate Parrott on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKPropertyCell.h"

// when an action cell is called, we try to perform the selector specified by the 'selection' key first on the actual element, and then on the property editor's delegate

@interface SKActionCell : SKPropertyCell

@end
