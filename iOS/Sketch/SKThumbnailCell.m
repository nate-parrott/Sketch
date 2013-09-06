//
//  SKThumbnailCell.m
//  Sketch
//
//  Created by Nate Parrott on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKThumbnailCell.h"

const UINib* _SKThumbnailCellNib = nil;

@implementation SKThumbnailCell
@synthesize thumbnailView=_thumbnailView;

-(id)initWithReuseIdentifier:(NSString*)reuseID {
    self = [super initWithReuseIdentifier:reuseID];
    if (!_SKThumbnailCellNib) {
        _SKThumbnailCellNib = [UINib nibWithNibName:@"SKThumbnailCellContent" bundle:nil];
    }
    [_SKThumbnailCellNib instantiateWithOwner:self options:nil];
    [self addSubview:_content];
    return self;
}
-(void)layoutSubviews {
    [super layoutSubviews];
    _content.frame = CGRectMake(_padding.left, _padding.top, self.bounds.size.width-_padding.left-_padding.right, self.bounds.size.height-_padding.top-_padding.bottom);
}
@synthesize padding=_padding;
-(void)setPadding:(UIEdgeInsets)padding {
    _padding = padding;
    [self setNeedsLayout];
}

@end
