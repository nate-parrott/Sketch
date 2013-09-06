//
//  SKImageExtractViewController.m
//  Sketch
//
//  Created by Nate Parrott on 9/23/12.
//
//

#import "SKImageExtractViewController.h"
#import "SKImageFill.h"

@interface SKImageExtractViewController ()

@end

@implementation SKImageExtractViewController
@synthesize imageFill=_imageFill;
@synthesize updateCallback=_updateCallback;

-(id)init {
    self = [super initWithNibName:@"SKImageExtractViewController" bundle:nil];
    self.navigationItem.prompt = NSLocalizedString(@"Draw outline around the portion of the image you want to keep", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    return self;
}
-(void)viewDidLoad {
    [super viewDidLoad];
    [_extractView setImage:self.imageFill.image];
    _imageView.alpha = 0;
}
-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat xScale = self.view.bounds.size.width/self.imageFill.image.size.width;
    CGFloat yScale = self.view.bounds.size.height/self.imageFill.image.size.height;
    CGSize size = self.imageFill.image.size;
    size.width *= MIN(xScale, yScale);
    size.height *= MIN(xScale, yScale);
    _extractView.frame = CGRectMake(0, 0, size.width, size.height);
    _extractView.center = self.view.center;
}
-(void)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
-(void)imageExtractView:(SKImageExtractView *)extractView didExtractImage:(UIImage *)extracted {
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)], [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reset", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(reset:)]];
    _extractView.userInteractionEnabled = NO;
    _extracted = extracted;
    _imageView.image = extracted;
    [UIView animateWithDuration:0.3 animations:^{
        _imageView.alpha = 1;
    }];
}
-(void)reset:(id)sender {
    [_extractView reset];
    self.navigationItem.rightBarButtonItems = @[];
    [UIView animateWithDuration:0.3 animations:^{
        _imageView.alpha = 0;
    }];
    _extractView.userInteractionEnabled = YES;
}
-(void)done:(id)sender {
    self.imageFill.image = _extracted;
    if (self.updateCallback) self.updateCallback();
    [self dismissModalViewControllerAnimated:YES];
}

@end
