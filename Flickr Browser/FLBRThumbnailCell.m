//
//  FLBRThumbnailCell.m
//  Flickr Browser
//
//  Created by Jake Spencer on 7/17/14.
//  Copyright (c) 2014 Uncarbonated Software LLC. All rights reserved.
//

#import "FLBRThumbnailCell.h"

@implementation FLBRThumbnailCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.backgroundColor = [UIColor lightGrayColor];
        self.thumbnailView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.thumbnailView];
    }
    return self;
}

- (void) setThumbnail:(UIImage *)thumbnail
{
    _thumbnail = thumbnail;
    
    [self.thumbnailView setImage:thumbnail];
    [self.thumbnailView sizeToFit];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
