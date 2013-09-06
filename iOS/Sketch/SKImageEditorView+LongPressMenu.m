//
//  SKImageEditorView+LongPressMenu.m
//  Sketch
//
//  Created by Nate Parrott on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKImageEditorView+LongPressMenu.h"

const NSString* SKElementPasteboardType = @"SKElement";

@implementation SKImageEditorView (LongPressMenu)

-(void)longPressed:(UILongPressGestureRecognizer*)gestureRec {
    if (gestureRec.state==UIGestureRecognizerStateBegan) {
        CGPoint point = [gestureRec locationInView:self.imageView];
        SKElement* element = [self elementAtPoint:point];
        self.selected = element;
        UIActionSheet* sheet = [UIActionSheet new];
        sheet.delegate = self;
        if (element) {
            [sheet addButtonWithTitle:@"Delete"];
            sheet.destructiveButtonIndex = [sheet numberOfButtons]-1;
            [sheet addButtonWithTitle:@"Copy"];
        } else {
            if ([[UIPasteboard generalPasteboard] containsPasteboardTypes:[NSArray arrayWithObject:SKElementPasteboardType]]) {
                [sheet addButtonWithTitle:@"Paste"];
            }
        }
        [sheet addButtonWithTitle:@"Cancel"];
        sheet.cancelButtonIndex = [sheet numberOfButtons]-1;
        [sheet showFromRect:CGRectMake(point.x, point.y, 1, 1) inView:self.imageView animated:YES];
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (self.selected) {
        if (buttonIndex==0) { // delete
            [self.image.elements removeObject:self.selected];
            self.selected = nil;
            [self.image didUpdate];
        } else if (buttonIndex==1) { // copy
            //[[UIPasteboard generalPasteboard] addItems:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:data forKey:SKElementPasteboardType]]];
            [[UIPasteboard generalPasteboard] setData:[self.selected toData] forPasteboardType:SKElementPasteboardType];
        }
    } else {
        if (buttonIndex==0) { // paste
            SKElement* pasted = [SKElement fromData:[[UIPasteboard generalPasteboard] dataForPasteboardType:SKElementPasteboardType]];
            pasted.parentImage = self.image;
            [self.image.elements addObject:pasted];
            [pasted didUpdate];
        }
    }
}

@end
