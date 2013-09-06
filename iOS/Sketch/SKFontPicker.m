//
//  SKFontPicker.m
//  Sketch
//
//  Created by Nate Parrott on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKFontPicker.h"

@interface SKFontPicker ()

@end

@implementation SKFontPicker
@synthesize fontName=_fontName;
@synthesize callback=_callback;

#pragma mark Data
-(void)setFontName:(NSString *)fontName {
    _fontName = fontName;
    [self.tableView reloadData];
}
-(NSArray*)fontsForFamily:(NSString*)family {
    if (![_fontsForFamily objectForKey:family]) {
        NSArray* fonts = [[UIFont fontNamesForFamilyName:family] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if ([obj1 length] < [obj2 length]) {
                return NSOrderedAscending;
            } else if ([obj1 length] == [obj2 length]) {
                return NSOrderedSame;
            } else {
                return NSOrderedDescending;
            }
        }];
        [_fontsForFamily setObject:fonts forKey:family];
    }
    return [_fontsForFamily objectForKey:family];
}
-(NSString*)defaultFontForFamily:(NSString*)family {
    return [[self fontsForFamily:family] objectAtIndex:0];
}
#pragma mark TableView source
-(int)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!_families) {
        _families = [[UIFont familyNames] sortedArrayUsingSelector:@selector(compare:)];
        _fontsForFamily = [NSMutableDictionary new];
        _expandedFamilies = [NSMutableSet new];
    }
    return [_families count];
}
-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_expandedFamilies containsObject:[NSNumber numberWithInt:section]]) {
        return [[self fontsForFamily:[_families objectAtIndex:section]] count]+1;
    } else {
        return 1;
    }
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* family = [_families objectAtIndex:indexPath.section];
    NSString* fontName;
    if (indexPath.row==0) {
        fontName = [self defaultFontForFamily:family];
    } else {
        fontName = [[self fontsForFamily:family] objectAtIndex:indexPath.row-1];
    }
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    if (indexPath.row==0) {
        cell.textLabel.text = family;
        cell.textLabel.textColor = [UIColor blackColor];
    } else {
        cell.textLabel.text = fontName;
        cell.textLabel.textColor = [UIColor grayColor];
    }
    cell.textLabel.font = [UIFont fontWithName:fontName size:[UIFont systemFontSize]];
    if (indexPath.row==0 && [[self fontsForFamily:family] count]>1) {
        UIButton* disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [disclosureButton addTarget:self action:@selector(toggleDisclosure:) forControlEvents:UIControlEventTouchUpInside];
        if ([_expandedFamilies containsObject:[NSNumber numberWithInt:indexPath.section]]) {
            disclosureButton.transform = CGAffineTransformMakeRotation(M_PI*-0.5);
        } else {
            disclosureButton.transform = CGAffineTransformMakeRotation(M_PI*0.5);
        }
        cell.accessoryView = disclosureButton;
    } else {
        cell.accessoryView = nil;
    }
    return cell;
}
-(void)toggleDisclosure:(UIButton*)sender {
    // first, find the index path corresponding to the button pressed
    NSIndexPath* indexPath = nil;
    for (UITableViewCell* cell in self.tableView.visibleCells) {
        if ([cell.accessoryView isEqual:sender]) {
            indexPath = [self.tableView indexPathForCell:cell];
            break;
        }
    }
    if (indexPath) {
        NSMutableArray* affectedRows = [NSMutableArray new];
        int i=1;
        for (NSString* font in [self fontsForFamily:[_families objectAtIndex:indexPath.section]]) {
            [affectedRows addObject:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
            i++;
        }
        if ([_expandedFamilies containsObject:[NSNumber numberWithInt:indexPath.section]]) {
            // already disclosed; let's close it
            [_expandedFamilies removeObject:[NSNumber numberWithInt:indexPath.section]];
            [self.tableView deleteRowsAtIndexPaths:affectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            // we should disclose it
            [_expandedFamilies addObject:[NSNumber numberWithInt:indexPath.section]];
            [self.tableView insertRowsAtIndexPaths:affectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    [UIView animateWithDuration:0.3 animations:^{
        [sender setTransform:CGAffineTransformRotate([sender transform], M_PI)];
    }];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* family = [_families objectAtIndex:indexPath.section];
    NSString* fontName;
    if (indexPath.row==0) {
        fontName = [self defaultFontForFamily:family];
    } else {
        fontName = [[self fontsForFamily:family] objectAtIndex:indexPath.row-1];
    }
    _fontName = fontName;
    self.callback(fontName);
}

@end
