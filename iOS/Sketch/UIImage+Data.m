//
//  UIImage+Data.m
//  iOSplusOpenCV
//
//  Created by Nate Parrott on 9/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Data.h"

@implementation UIImage (Data)

-(IGImageData*)toImageData {
    return [self imageDataForSubImage:CGRectMake(0, 0, self.size.width, self.size.height)];
}
-(IGImageData*)imageDataForSubImage:(CGRect)rect {
    IGImageData* data = malloc(sizeof(IGImageData));
    data->w = rect.size.width;
    data->h = rect.size.height;
    data->data = malloc(4 * data->w * data->h);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmap = CGBitmapContextCreate(data->data, data->w, data->h, 8, data->w*4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    UIGraphicsPushContext(bitmap);
    
    CGAffineTransform flipVertical = CGAffineTransformMake(
                                                           1, 0, 0, -1, 0, rect.size.height
                                                           );
    CGContextConcatCTM(bitmap, flipVertical);
    
    [self drawInRect:CGRectMake(-rect.origin.x, -rect.origin.y, self.size.width, self.size.height)];
    UIGraphicsPopContext();
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(bitmap);
    return data;
}
+(UIImage*)imageFromImageData:(IGImageData*)data {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmap = CGBitmapContextCreate(data->data, data->w, data->h, 8, data->w*4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmap);
    UIImage* image = [UIImage imageWithCGImage:cgImage];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(bitmap);
    CGImageRelease(cgImage);
    
    return image;
}

@end
