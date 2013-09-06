//
//  SKFillPicker.m
//  Sketch
//
//  Created by Nate Parrott on 7/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKFillPicker.h"
#import "SKColorFill.h"
#import "SKGradient.h"

@implementation SKFillPicker
@synthesize callback=_callback;
@synthesize fill=_fill;

-(id)initWithFill:(SKFill*)fill {
    self = [super init];
    if (!fill) {fill = [[SKColorFill alloc] initWithColor:[UIColor blueColor]];}
    
    //_noFill = [[SKNullViewController alloc] init];
    //_noFill.message = @"No fill";
    
    _colorPicker = [CPColorPicker new];
    _colorPicker.callback = ^(UIColor* color) {
        if (self.callback) self.callback([[SKColorFill alloc] initWithColor:color]);
    };
    _colorPicker.tabBarItem.image = [UIImage imageNamed:@"color"];
    
    _gradientPicker = [SKGradientEditor new];
    _gradientPicker.callback = ^(SKGradient* gradient) {
        if (self.callback) self.callback(gradient);
    };
    _gradientPicker.tabBarItem.image = [UIImage imageNamed:@"linearGradient"];
    
    _imagePicker = [SKImagePicker new];
    _imagePicker.callback = ^(SKImageFill* fill) {
        if (self.callback) self.callback(fill);
    };
    _imagePicker.tabBarItem.image = [UIImage imageNamed:@"image"];
    
    self.viewControllers = [NSArray arrayWithObjects:_colorPicker, _gradientPicker, _imagePicker, nil];
    
    self.fill = fill;
    
    return self;
}
-(void)setFill:(SKFill*)fill {
    _fill = fill;
    if ([fill isKindOfClass:[SKColorFill class]]) {
        _colorPicker.color = [(SKColorFill*)fill color];
        [self setSelectedViewController:_colorPicker];
    } else if ([fill isKindOfClass:[SKGradient class]]) {
        _gradientPicker.gradient = (SKGradient*)fill;
        [self setSelectedViewController:_gradientPicker];
    } else if ([fill isKindOfClass:[SKImageFill class]]) {
        _imagePicker.imageFill = (SKImageFill*)fill;
        [self setSelectedViewController:_imagePicker];
    } /*else {
        [self setSelectedViewController:_noFill];
    }*/
}
/*-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if ([[self superclass] instancesRespondToSelector:@selector(tabBar:didSelectItem:)]) {
        [super tabBar:tabBar didSelectItem:item];
    }
    UIViewController* selectedVC = [[self viewControllers] objectAtIndex:[tabBar.items indexOfObject:item]];
    if (selectedVC==_noFill) {
        self.callback(nil);
    }
}*/

@end
