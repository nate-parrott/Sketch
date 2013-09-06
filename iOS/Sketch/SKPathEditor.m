//
//  SKPathEditor.m
//  Sketch
//
//  Created by Nate Parrott on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKPathEditor.h"

@interface SKPathEditor ()

@end

@implementation SKPathEditor
@synthesize element=_element;

#pragma mark View loading
-(void)loadView {
    self.view = [UIView new];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _editView = [[SKPathEditView alloc] initWithPathElement:self.element];
    [self.view addSubview:_editView];
}
-(void)viewWillLayoutSubviews {
    CGFloat size = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
    _editView.frame = CGRectMake(0, 0, size, size);
    _editView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
}
-(void)viewWillDisappear:(BOOL)animated {
    [_editView savePath];
    [super viewWillDisappear:animated];
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}
@end
