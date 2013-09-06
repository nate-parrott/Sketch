//
//  SKPropertyCell.h
//  Sketch
//
//  Created by Nate Parrott on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKPropertyEditor.h"
#import "SKElement.h"

@interface SKPropertyCell : UITableViewCell

@property(assign)SKPropertyEditor* propertyEditor;
@property(strong)NSDictionary* propertyInfo;
-(id)initWithPropertyInfo:(NSDictionary*)info inPropertyEditor:(SKPropertyEditor*)editor;
-(void)setup;
-(BOOL)clicked; // return YES if the highlight should stay
-(id)value;
-(void)setValue:(id)val;

@property(nonatomic)BOOL disabled;

@end
