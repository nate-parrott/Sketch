//
//  SKThumbnailCell.h
//  Sketch
//
//  Created by Nate Parrott on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SKGridViewCell.h"

@interface SKThumbnailCell : SKGridViewCell {
    IBOutlet UIView* _content;
}
@property(strong)IBOutlet UIImageView* thumbnailView;
@property(nonatomic)UIEdgeInsets padding;

@end
