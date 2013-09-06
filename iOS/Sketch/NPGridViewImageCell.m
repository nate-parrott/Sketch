//
//  NPGridViewImageCell.m
//  UIGridView
//
//  Created by Nate Parrott on 1/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NPGridViewImageCell.h"
#import "NPGridViewCell.h"


@implementation NPGridViewImageCell
@synthesize imageView;

-(id)initWithReuseIdentifier:(NSString *)reuseID {
	[super initWithReuseIdentifier:reuseID];
	imageView = [[UIImageView new] autorelease];
	[self addSubview:imageView];
	[self.imageView setContentMode:UIViewContentModeScaleAspectFit];
	return self;
}
-(void)layoutSubviews {
	[super layoutSubviews];
	[imageView setFrame:self.bounds];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
