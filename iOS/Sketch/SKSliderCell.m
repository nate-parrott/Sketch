//
//  SKSliderCell.m
//  Sketch
//
//  Created by Nate Parrott on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKSliderCell.h"
#import "CGPointExtras.h"

@implementation SKSliderCell

-(void)setup {
    _slider = [UISlider new];
    [self addSubview:_slider];
    _slider.minimumValue = [[self.propertyInfo objectForKey:@"min"] floatValue];
    _slider.maximumValue = [[self.propertyInfo objectForKey:@"max"] floatValue];
    _slider.value = [self.value floatValue];
    [_slider addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
    _slider.continuous = YES;
}
-(void)changed:(id)sender {
    CGFloat val = _slider.value;
    CGFloat pos = (val-_slider.minimumValue)/(_slider.maximumValue-_slider.minimumValue)*self.bounds.size.width;
    CGFloat snapRadius = [self.propertyInfo objectForKey:@"snapRadius"]? [[self.propertyInfo objectForKey:@"snapRadius"] floatValue] : CGPointStandardSnappingThreshold; 
    val = CGSnapWithThreshold(pos, self.bounds.size.width, snapRadius)/self.bounds.size.width*(_slider.maximumValue-_slider.minimumValue)+_slider.minimumValue;
    _slider.value = val;
    [self setValue:[NSNumber numberWithFloat:val]];
}
-(void)layoutSubviews {
    [super layoutSubviews];
    _slider.frame = CGRectInset(self.bounds, 20, 4);
}
-(void)setDisabled:(BOOL)disabled {
    [super setDisabled:disabled];
    _slider.enabled = !disabled;
}

@end
