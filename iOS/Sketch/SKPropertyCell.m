//
//  SKPropertyCell.m
//  Sketch
//
//  Created by Nate Parrott on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKPropertyCell.h"

@implementation SKPropertyCell
@synthesize propertyEditor=_propertyEditor;
@synthesize propertyInfo=_propertyInfo;
@synthesize disabled=_disabled;

-(id)initWithPropertyInfo:(NSDictionary*)info inPropertyEditor:(SKPropertyEditor*)editor {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    self.propertyInfo = info;
    self.propertyEditor = editor;
    if ([self class]==[SKPropertyCell class]) {
        self.textLabel.text = [NSString stringWithFormat:@"No subclass '%@'", [info objectForKey:@"class"]];
    }
    [self setup];
    return self;
}
-(void)setDisabled:(BOOL)disabled {
    _disabled = disabled;
    if (disabled)
        self.textLabel.textColor = [UIColor grayColor];
    else
        self.textLabel.textColor = [UIColor blackColor];
    self.userInteractionEnabled = !disabled;
}
-(void)setup {
    
}
-(BOOL)clicked {
    return NO;
}
-(id)value {
    id val = [self.propertyEditor getSharedValueForProperty:[self.propertyInfo objectForKey:@"property"]];//[self.propertyEditor.element.properties objectForKey:[self.propertyInfo objectForKey:@"property"]];
    /*if (!val && [self.propertyInfo objectForKey:@"default"]) {
        val = [self.propertyInfo objectForKey:@"default"];
    }*/
    return val;
}
-(void)setValue:(id)val {
    /*BOOL changed = ![[self value] isEqual:val];
    if (!changed)
        return;*/
    for (SKElement* element in self.propertyEditor.elements) {
        if (val) {
            [element setProperty:val forKey:[self.propertyInfo objectForKey:@"property"]];
        } else {
            [element setProperty:nil forKey:[self.propertyInfo objectForKey:@"property"]];
        }
        [element didUpdate];
    }
    NSMutableArray* indexPathsToReload = [NSMutableArray new];
    for (UITableViewCell* cell in self.propertyEditor.tableView.visibleCells) {
        NSIndexPath* indexPath = [self.propertyEditor.tableView indexPathForCell:cell];
        NSDictionary* propertyInfo = [[[self.propertyEditor sections] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        if ([[propertyInfo objectForKey:@"dependsOn"] isEqualToString:[self.propertyInfo objectForKey:@"property"]]) {
            [indexPathsToReload addObject:[self.propertyEditor.tableView indexPathForCell:cell]];
            //cell.disabled = ![val boolValue];
        }
    }
    if (indexPathsToReload.count>0) {
        [self.propertyEditor.tableView reloadRowsAtIndexPaths:indexPathsToReload withRowAnimation:UITableViewRowAnimationTop];
    }
}
@end
