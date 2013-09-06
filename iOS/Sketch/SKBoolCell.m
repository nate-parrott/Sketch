//
//  SKBoolCell.m
//  Sketch
//
//  Created by Nate Parrott on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKBoolCell.h"

@implementation SKBoolCell

-(void)setup {
    _switch = [UISwitch new];
    [self addSubview:_switch];
    _switch.on = [[self value] boolValue];
    [_switch addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
    
    self.textLabel.text = [self.propertyInfo objectForKey:@"title"];
}
-(void)changed:(id)sender {
    [self setValue:[NSNumber numberWithBool:_switch.on]];
}
-(void)layoutSubviews {
    [super layoutSubviews];
    _switch.center = CGPointMake(self.bounds.size.width-_switch.frame.size.width*0.75, self.bounds.size.height/2);
}
-(void)setDisabled:(BOOL)disabled {
    [super setDisabled:disabled];
    _switch.enabled = !disabled;
}

@end
