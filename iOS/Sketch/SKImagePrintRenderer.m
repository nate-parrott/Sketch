//
//  SKImagePrintRenderer.m
//  Sketch
//
//  Created by Nate Parrott on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKImagePrintRenderer.h"

@implementation SKImagePrintRenderer
@synthesize image=_image;
-(int)numberOfPages {
    return 1;
}
-(void)drawContentForPageAtIndex:(NSInteger)pageIndex inRect:(CGRect)rect {
    CGSize imageSize = self.image.size;
    CGFloat scale = MIN(rect.size.width/imageSize.width, rect.size.height/imageSize.height);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGSize size = CGSizeMake(imageSize.width*scale, imageSize.height*scale);
    CGContextConcatCTM(ctx, CGAffineTransformMakeTranslation((rect.size.width-size.width)/2, (rect.size.height-size.height)/2));
    CGContextConcatCTM(ctx, CGAffineTransformMakeScale(scale, scale));
    [self.image drawRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
}

@end
