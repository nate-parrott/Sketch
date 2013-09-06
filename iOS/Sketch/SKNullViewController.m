//
//  SKNullViewController.m
//  Sketch
//
//  Created by Nate Parrott on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKNullViewController.h"

@interface SKNullViewController ()

@end

@implementation SKNullViewController
@synthesize message=_message;

-(void)setMessage:(NSString *)message {
    _message = message;
    _label.text = message;
    self.title = message;
}
-(void)loadView {
    self.view = [UIView new];
    _label = [[UILabel alloc] initWithFrame:self.view.bounds];
    _label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _label.textColor = LIGHT_BACKGROUND;
    _label.shadowColor = [UIColor blackColor];
    _label.shadowOffset = CGSizeMake(0, -1);
    _label.font = [UIFont boldSystemFontOfSize:36];
    _label.minimumFontSize = 12;
    [self.view addSubview:_label];
    _label.text = self.message;
    self.view.backgroundColor = BACKGROUND_COLOR;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
