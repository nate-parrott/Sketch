//
//  SKGradientEditor.m
//  Sketch
//
//  Created by Nate Parrott on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKGradientEditor.h"

@interface SKGradientEditor ()

@end

@implementation SKGradientEditor
@synthesize callback=_callback;

-(id)init {
    self = [super init];
    self.title = @"Gradient";
    self.gradient = nil;
    return self;
}
-(void)viewDidLoad {
    self.view.backgroundColor = BACKGROUND_COLOR;
    _pointEditor.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"checker.png"]];
    [self setGradient:_gradient];
}
-(void)updatedGradient {
    [_colorStopEditor setNeedsDisplay];
    [_pointEditor setNeedsDisplay];
    if (self.callback) {
        self.callback(self.gradient);
    }
}
-(IBAction)pickedType:(id)sender {
    self.gradient.type = _typePicker.selectedSegmentIndex;
    [self updatedGradient];
}
@synthesize gradient=_gradient;
-(void)setGradient:(SKGradient *)gradient {
    if (!gradient) {
        gradient = [SKGradient new];
        gradient.colors = [NSArray arrayWithObjects:[UIColor colorWithRed:0 green:0 blue:1 alpha:1], [UIColor colorWithRed:0 green:0 blue:0.6 alpha:1], nil];
        gradient.positions = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0], [NSNumber numberWithFloat:1], nil];
        gradient.type = SKGradientTypeLinear;
        gradient.startPoint = CGPointMake(0.5, 0);
        gradient.endPoint = CGPointMake(0.5, 1);
    }
    _gradient = gradient;
    _typePicker.selectedSegmentIndex = gradient.type;
    _colorStopEditor.gradient = gradient;
    _pointEditor.gradient = gradient;
    [self updatedGradient];
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end
