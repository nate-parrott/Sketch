//
//  SKPropertyEditor.h
//  Sketch
//
//  Created by Nate Parrott on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKElement.h"

@class SKImageEditorView;
@interface SKPropertyEditor : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSArray* _sectionTitles;
    NSArray* _sections;
    IBOutlet UILabel* _noSelectionLabel;
}

@property(weak)IBOutlet UITableView* tableView;
//@property(strong,readonly)SKElement* element;
@property(strong)NSArray* elements;
@property(assign)SKImageEditorView* associatedImageEditor;
-(void)setElement:(SKElement*)element;
-(void)clickProperty:(NSString*)property;
-(NSArray*)sections;

-(id)getSharedValueForProperty:(NSString*)property;

@end
