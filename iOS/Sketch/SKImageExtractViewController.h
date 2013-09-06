//
//  SKImageExtractViewController.h
//  Sketch
//
//  Created by Nate Parrott on 9/23/12.
//
//

#import <UIKit/UIKit.h>
#import "SKImageExtractView.h"
#import "SKImageFill.h"

@interface SKImageExtractViewController : UIViewController <SKImageExtractViewDelegate> {
    IBOutlet SKImageExtractView *_extractView;
    IBOutlet UIImageView *_imageView;
    UIImage* _extracted;
}
@property(strong)SKImageFill* imageFill;
@property(strong)void (^updateCallback)();

@end
