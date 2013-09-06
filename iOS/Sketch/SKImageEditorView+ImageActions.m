//
//  SKImageEditorView+ImageActions.m
//  Sketch
//
//  Created by Nate Parrott on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKImageEditorView+ImageActions.h"
#import "NSData+Base64.h"
#import "SKImagePrintRenderer.h"
#import "SKPopoverPresenter.h"

@implementation SKImageEditorView (ImageActions)

-(void)showImageActions:(UIBarButtonItem*)sender {
    [self willSave];
    if (NSClassFromString(@"UIActivityViewController")) {
        UIImage* thumbnail = [self.image thumbnailWithMaxDimension:1400];
        UIActivityViewController* activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[thumbnail] applicationActivities:@[]];
        [SKPopoverPresenter presentViewController:activityVC fromViewController:self fromBarButtonItem:sender];
    } else {
        // save, email, print, tweet
        SKActionPrompt* prompt = [[SKActionPrompt alloc] initWithTitle:nil];
        [prompt addButtonWithTitle:@"Save to Photos" callback:^{
            [self saveImage];
        }];
        if ([MFMailComposeViewController canSendMail]) {
            [prompt addButtonWithTitle:@"Email" callback:^{
                [self emailImage];
            }];
        }
        if ([UIPrintInteractionController isPrintingAvailable]) {
            [prompt addButtonWithTitle:@"Print" callback:^{
                [self printImage];
            }];
        }
        /*if ([TWTweetComposeViewController canSendTweet]) {
         [prompt addButtonWithTitle:@"Tweet" callback:^{
         [self tweetImage];
         }];
         }*/
        [prompt presentFromBarButtonItem:sender];
    }
}
-(UIImage*)largeThumbnail {
    return [self.image thumbnailWithMaxDimension:2048];
}
-(UIImage*)smallThumbnail {
    return [self.image thumbnailWithMaxDimension:768];
}
-(void)saveImage {
    UIImageWriteToSavedPhotosAlbum([self largeThumbnail], nil, nil, nil);
}
-(void)emailImage {
    MFMailComposeViewController* compose = [[MFMailComposeViewController alloc] init];
    compose.mailComposeDelegate = self;
    //NSString* thumbnailData = [UIImagePNGRepresentation([self smallThumbnail]) base64EncodedString];
    //NSString* body = [NSString stringWithFormat:@"<img src='data:image/png;base64,%@'/> <p>Made with <strong>???</strong></p>", thumbnailData];
    NSString* body = @"<p>Made with <strong>???</strong> </p>";
    [compose setMessageBody:body isHTML:YES];
    [compose addAttachmentData:UIImagePNGRepresentation([self largeThumbnail]) mimeType:@"image/png" fileName:@"image.png"];
    [self presentModalViewController:compose animated:YES];
}
-(void)printImage {
    //[[self.image PDFThumbnailWithMaxDimension:2048] writeToFile:@"/Users/nateparrott/Desktop/img.pdf" atomically:YES];
    UIPrintInteractionController* printController = [UIPrintInteractionController sharedPrintController];
    
    UIPrintInfo* printInfo = [UIPrintInfo printInfo];
    if (self.image.size.width > self.image.size.height) {
        printInfo.orientation = UIPrintInfoOrientationLandscape;
    }
    printInfo.outputType = UIPrintInfoOutputPhoto;
    printController.printInfo = printInfo;
    SKImagePrintRenderer* renderer = [SKImagePrintRenderer new];
    renderer.image = self.image;
    printController.printPageRenderer = renderer;
    [printController presentFromBarButtonItem:self.actionButtonItem animated:YES completionHandler:^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error) {
        
    }];
}
-(void)tweetImage {
    
}
#pragma mark Mail compose VC delegate
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
}

@end
