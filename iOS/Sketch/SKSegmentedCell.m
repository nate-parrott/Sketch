//
//  SKSegmentedCell.m
//  Sketch
//
//  Created by Nate Parrott on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKSegmentedCell.h"

@implementation SKSegmentedCell

-(void)setup {
    _segmentedControl = [UISegmentedControl new];
    [self addSubview:_segmentedControl];
    [_segmentedControl addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
    NSArray* options = [[self propertyInfo] objectForKey:@"options"];
    int i=0;
    for (NSDictionary* option in options) {
        NSString* value = [option objectForKey:@"value"];
        NSString* text = [option objectForKey:@"text"];
        NSString* imageName = [option objectForKey:@"image"];
        if (imageName) {
            [_segmentedControl insertSegmentWithImage:[UIImage imageNamed:imageName] atIndex:_segmentedControl.numberOfSegments animated:NO];
        } else {
            [_segmentedControl insertSegmentWithTitle:text atIndex:_segmentedControl.numberOfSegments animated:NO];
        }
        if ([self.value isEqualToString:value]) {
            _segmentedControl.selectedSegmentIndex = i;
        }
        i++;
    }
}
-(void)changed:(id)sender {
    NSArray* options = [[self propertyInfo] objectForKey:@"options"];
    NSDictionary* selectedOption = [options objectAtIndex:_segmentedControl.selectedSegmentIndex];
    NSString* value = [selectedOption objectForKey:@"value"];
    [self setValue:value];
}
-(void)layoutSubviews {
    [super layoutSubviews];
    _segmentedControl.frame = CGRectMake(10, 0, self.bounds.size.width-20, self.bounds.size.height);
}

@end
