//
//  SKDocumentPreviewCell.m
//  Sketch
//
//  Created by Nate Parrott on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKDocumentPreviewCell.h"

@implementation SKDocumentPreviewCell

-(id)initWithReuseIdentifier:(NSString*)reuseID {
    self = [super initWithReuseIdentifier:reuseID];
    
    return self;
}
@synthesize bundlePath=_bundlePath;
-(void)setBundlePath:(NSString *)bundlePath {
    if ([_bundlePath isEqualToString:bundlePath]) return;
    _bundlePath = bundlePath;
    self.thumbnailView.image = [UIImage imageWithContentsOfFile:[_bundlePath stringByAppendingPathComponent:@"thumbnail.png"]];
}

@end
