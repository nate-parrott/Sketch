//
//  SKImageEditorView+EditingMenu.m
//  Sketch
//
//  Created by Nate Parrott on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKImageEditorView+EditingMenu.h"
#import "SKSavedElementStore.h"
#import "SKGroupElement.h"
#import "UIBarButtonItem+Position.h"
#import "SKPathElement.h"
#import "SKTextElement.h"

@implementation SKImageEditorView (EditingMenu)

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action==@selector(paste:)) {
        return (
                [[UIPasteboard generalPasteboard] containsPasteboardTypes:[NSArray arrayWithObject:@"SKGroupElementArchive"]] ||
                [[UIPasteboard generalPasteboard] image] ||
                [[UIPasteboard generalPasteboard] string]
        );
        //return [[UIPasteboard generalPasteboard] containsPasteboardTypes:[NSArray arrayWithObject:@"SKElementArray"]];
    } else if (action==@selector(copy:) ||
               action==@selector(delete:) ||
               action==@selector(duplicate:) ||
               action==@selector(bringToFront:) ||
               action==@selector(sendToBack:)) {
        return self.selected!=nil;
    } else if (action==@selector(saveAsTemplate:)) {
        return self.selectedElements.count==1;
    } else if (action==@selector(group:)) {
        return self.selectedElements.count>1;
    } else if (action==@selector(ungroup:)) {
        return self.selectedElements.count == 1 && [[self.selectedElements objectAtIndex:0] isKindOfClass:[SKGroupElement class]];
    } else if (action==@selector(expandProperties:)) {
        return [UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone;
    }
    return NO;
}
-(void)expandProperties:(id)sender {
    [self setPropertyEditorExpanded:YES];
}
-(NSArray*)selectedElementsSortedByOrderInImage {
    return [self.selectedElements sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int idx1 = [self.image.elements indexOfObject:obj1];
        int idx2 = [self.image.elements indexOfObject:obj2];
        if (idx1<idx2)
            return NSOrderedAscending;
        else if (idx1==idx2)
            return NSOrderedSame;
        else
            return NSOrderedDescending;
    }];
}
-(void)bringToFront:(id)sender {
    for (SKElement* element in [self selectedElementsSortedByOrderInImage]) {
        [self.image bringElementToFront:element];
        SKElementView* ed = [self viewForElement:element];
        [ed.superview bringSubviewToFront:ed];
    }
    [self.scrollView bringSubviewToFront:self.selectedElementHandleEditor];
}
-(void)sendToBack:(id)sender {
    for (SKElement* element in [[self selectedElementsSortedByOrderInImage] reverseObjectEnumerator]) {
        [self.image sendElementToBack:element];
        SKElementView* ed = [self viewForElement:element];
        [ed.superview sendSubviewToBack:ed];
    }
}
-(void)paste:(id)sender {
    /*NSArray* elements = [NSKeyedUnarchiver unarchiveObjectWithData:[[UIPasteboard generalPasteboard] dataForPasteboardType:@"SKElementArray"]];
    for (SKElement* el in elements) {
        [self addShape:el withPreferredPosition:self.lastTouchPoint canResize:YES animated:YES];
    }*/
    NSArray* pasted = nil;
    if ([[UIPasteboard generalPasteboard] containsPasteboardTypes:@[@"SKGroupElementArchive"]]) {
        SKGroupElement* groupElement = [NSKeyedUnarchiver unarchiveObjectWithData:[[UIPasteboard generalPasteboard] dataForPasteboardType:@"SKGroupElementArchive"]];
        [self addShape:groupElement withPreferredPosition:self.lastTouchPoint canResize:YES animated:NO];
        pasted = [groupElement ungroupAndRemove];
    } else if ([[UIPasteboard generalPasteboard] image]) {
        SKPathElement* element = [SKPathElement elementForImage:[[UIPasteboard generalPasteboard] image]];
        [self addShape:element];
        pasted = @[element];
    } else if ([[UIPasteboard generalPasteboard] string]) {
        SKTextElement* textEl = [[SKTextElement alloc] init];
        textEl.frame = CGRectMake(0, 0, 100, 100);
        [textEl setProperty:[NSNumber numberWithBool:YES] forKey:@"fillShape"];
        [textEl setProperty:[NSNumber numberWithBool:NO] forKey:@"strokeShape"];
        [textEl setProperty:[[UIPasteboard generalPasteboard] string] forKey:@"text"];
        [self addShape:textEl];
        pasted = @[textEl];
    }
    [self setSelectedElements:pasted];
}
-(void)copy:(id)sender {
    SKGroupElement* groupCopy = [SKGroupElement groupElements:[self selectedElementsSortedByOrderInImage] fromImage:self.image asDetatchedCopy:YES];
    [[UIPasteboard generalPasteboard] setData:[NSKeyedArchiver archivedDataWithRootObject:groupCopy] forPasteboardType:@"SKGroupElementArchive"];
    /*NSMutableArray* elements = [NSMutableArray new];
    for (SKElement* el in self.selectedElements) {
        [elements addObject:[el detatchedCopy]];
    }
    [[UIPasteboard generalPasteboard] setData:[NSKeyedArchiver archivedDataWithRootObject:elements] forPasteboardType:@"SKElementArray"];*/
    
}
-(void)delete:(id)sender {
    NSArray* toDeleteElements = self.selectedElements;
    self.selected = nil;
    [UIView animateWithDuration:0.3 animations:^{
        for (SKElement* toDelete in toDeleteElements) {
            SKElementView* rectEditor = [self viewForElement:toDelete];
            rectEditor.transform = CGAffineTransformMakeScale(0.01, 0.01);
            rectEditor.alpha = 0;
        }
    } completion:^(BOOL finished) {
        for (SKElement* toDelete in toDeleteElements) {
            [self.image removeElement:toDelete];
        }
    }];
}
-(void)saveAsTemplate:(id)sender {
    
    SKElement* copy = [self.selected detatchedCopy];
    copy.frame = CGRectMake(copy.frame.origin.x+20, copy.frame.origin.y+20, copy.frame.size.width, copy.frame.size.height);
    [[SKSavedElementStore shared] storeElement:copy];
    
    // animate the shape going into the "Add shape..." button
    
    UIImage* image = [self.selected thumbnailWithMaxDimension:MAX(self.selected.frame.size.width, self.selected.frame.size.height)];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    UIView* animationContainer = self.parentViewController.view;
    [animationContainer addSubview:imageView];
    SKElementView* rectEditor = [self viewForElement:self.selected];
    imageView.frame = [animationContainer convertRect:rectEditor.bounds fromView:rectEditor];
    
    CGPoint targetPointInToolbar = CGPointMake(self.navigationController.navigationBar.bounds.size.width-self.savedElementsButtonItem.width/2, self.navigationController.navigationBar.bounds.size.height/2);
    CGPoint targetPoint = [animationContainer convertPoint:targetPointInToolbar fromView:self.navigationController.navigationBar];
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.duration = 0.7;
    
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, imageView.center.x, imageView.center.y);
    CGPathAddQuadCurveToPoint(curvedPath, NULL, imageView.center.x, targetPoint.y, targetPoint.x, targetPoint.y);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    [imageView.layer addAnimation:pathAnimation forKey:@"curveAnimation"];
    
    [UIView animateWithDuration:0.7 animations:^{
        imageView.alpha = 0;
        imageView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
    }];
}
-(void)duplicate:(id)sender {
    NSMutableArray* copies = [NSMutableArray new];
    for (SKElement* selected in [self selectedElementsSortedByOrderInImage]) {
        SKElement* copy = [selected detatchedCopy];
        [self addShape:copy withPreferredPosition:CGPointMake(copy.frame.origin.x+copy.frame.size.width/2+20, copy.frame.origin.y+copy.frame.size.height/2+20) canResize:NO animated:NO];
        SKElementView* rectEditor = [self viewForElement:copy];
        CGRect newFrame = rectEditor.frame;
        rectEditor.frame = selected.frame;
        [UIView animateWithDuration:0.3 animations:^{
            rectEditor.frame = newFrame;
        }];
        [copies addObject:copy];
    }
    [self setSelectedElements:copies];
}
-(void)group:(id)sender {
    NSArray* selected = [self selectedElementsSortedByOrderInImage];
    self.selected = nil;
    SKGroupElement* group = [SKGroupElement groupElements:selected fromImage:self.image];
    self.selected = group;
}
-(void)ungroup:(id)sender {
    [(SKGroupElement*)self.selected ungroupAndRemove];
    self.selected = nil;
}

@end
