//
//  SKPropertyEditor.m
//  Sketch
//
//  Created by Nate Parrott on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKPropertyEditor.h"
#import "SKPropertyCell.h"
#import "SKImageEditorView.h"

@interface SKPropertyEditor ()

@end

@implementation SKPropertyEditor
//@synthesize element=_element;
@synthesize associatedImageEditor=_associatedImageEditor;
@synthesize tableView=_tableView;

+(Class)closestAncestorOfClass:(Class)class1 andClass:(Class)class2 {
    Class superclass = class1;
    while (superclass && !([class1 isSubclassOfClass:superclass] && [class2 isSubclassOfClass:superclass])) {
        superclass = [superclass superclass];
    }
    return superclass;
}

@synthesize elements=_elements;
-(void)setElements:(NSArray *)elements {
    _noSelectionLabel.hidden = elements.count>0;
    
    while (self.navigationController.viewControllers.lastObject && 
           self.navigationController.viewControllers.lastObject!=self) {
        [self.navigationController popViewControllerAnimated:NO];
    }
    
    _elements = elements;
    NSMutableArray* sectionTitles = [NSMutableArray new];
    NSMutableArray* sections = [NSMutableArray arrayWithObject:[NSMutableArray new]];
    
    Class closestParentClass = nil;
    if (elements.count>0) {
        closestParentClass = [[elements objectAtIndex:0] class];
    }
    for (int i=1; i<elements.count; i++) {
        closestParentClass = [SKPropertyEditor closestAncestorOfClass:closestParentClass andClass:[[elements objectAtIndex:i] class]];
    }
    
    for (id prop in [SKElement UIExposedPropertiesForClass:closestParentClass]) {
        if ([prop isKindOfClass:[NSString class]]) {
            [sectionTitles addObject:prop];
            if ([[sections lastObject] count]>0) {
                [sections addObject:[NSMutableArray new]];
            }
        } else if ([prop isKindOfClass:[NSDictionary class]]) {
            [[sections lastObject] addObject:prop];
        }
    }
    if ([[sections lastObject] count]==0) {[sections removeLastObject];}
    _sectionTitles = sectionTitles;
    _sections = sections;
    
    [self.tableView reloadData];
}
-(NSArray*)sections {
    return _sections;
}
/*-(void)setElement:(SKElement*)element {
    _noSelectionLabel.hidden = element!=nil;
    
    while (self.navigationController.viewControllers.lastObject && 
           self.navigationController.viewControllers.lastObject!=self) {
        [self.navigationController popViewControllerAnimated:NO];
    }
    
    _element = element;
    NSMutableArray* sectionTitles = [NSMutableArray new];
    NSMutableArray* sections = [NSMutableArray arrayWithObject:[NSMutableArray new]];
    for (id prop in element.UIExposedProperties) {
        if ([prop isKindOfClass:[NSString class]]) {
            [sectionTitles addObject:prop];
            if ([[sections lastObject] count]>0) {
                [sections addObject:[NSMutableArray new]];
            }
        } else if ([prop isKindOfClass:[NSDictionary class]]) {
            [[sections lastObject] addObject:prop];
        }
    }
    if ([[sections lastObject] count]==0) {[sections removeLastObject];}
    _sectionTitles = sectionTitles;
    _sections = sections;
    
    [self.tableView reloadData];
}*/

-(id)init {
    self = [super initWithNibName:@"SKPropertyEditor" bundle:nil];
    
    return self;
}
-(void)viewWillAppear:(BOOL)animated {
    _noSelectionLabel.hidden = self.elements.count>0;
    
    [self.tableView reloadData];
    //[self.associatedImageEditor setPropPaneWidth:250 animated:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:NO];
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}
-(void)viewDidLoad {
    self.view.backgroundColor = BACKGROUND_COLOR;
    self.navigationController.view.clipsToBounds = YES;
}
-(void)clickProperty:(NSString*)property {
    while (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:NO];
    }
    for (SKPropertyCell* cell in self.tableView.visibleCells) {
        if ([[cell.propertyInfo objectForKey:@"property"] isEqualToString:property]) {
            [cell clicked];
            return;
        }
    }
}
-(id)getSharedValueForProperty:(NSString*)property {
    if (self.elements.count==0) {
        return nil;
    }
    id sharedVal = [[self.elements objectAtIndex:0] propertyForKey:property];
    for (SKElement* el in self.elements) {
        id val = [el propertyForKey:property];
        if (![val isEqual:sharedVal]) {
            return nil;
        }
    }
    return sharedVal;
}
#pragma mark TableView datasource/delegate
-(int)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}
-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_sections objectAtIndex:section] count];
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_sectionTitles objectAtIndex:section];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* prop = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([self propertyUIIsDisabled:prop]) {
        return 0;
    } else if ([prop objectForKey:@"height"]) {
        return [[prop objectForKey:@"height"] floatValue];
    } else {
        return 44;
    }
}
-(BOOL)propertyUIIsDisabled:(NSDictionary*)propInfo {
    return [propInfo objectForKey:@"dependsOn"] && [[self getSharedValueForProperty:[propInfo objectForKey:@"dependsOn"]]boolValue]!=YES;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* prop = [[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([self propertyUIIsDisabled:prop]) {
        UITableViewCell* dummy = [tableView dequeueReusableCellWithIdentifier:@"Dummy"];
        if (!dummy)
            dummy = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Dummy"];
        return dummy;
    }
    Class cellClass = NSClassFromString([prop objectForKey:@"class"]);
    if (!cellClass) {
        cellClass = [SKPropertyCell class];
    }
    SKPropertyCell* cell = [[cellClass alloc] initWithPropertyInfo:prop inPropertyEditor:self];
    /*if  ([prop objectForKey:@"dependsOn"] && [[self.element.properties objectForKey:[prop objectForKey:@"dependsOn"]] boolValue]!=YES) {
        cell.disabled = YES;
    }*/
    
    /*if ([prop objectForKey:@"dependsOn"] && [[self getSharedValueForProperty:[prop objectForKey:@"dependsOn"]]boolValue]!=YES) {
        cell.disabled = YES;
    }*/
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([(SKPropertyCell*)[tableView cellForRowAtIndexPath:indexPath] clicked]==NO) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
