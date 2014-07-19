//
//  FLBRPhotoViewController.h
//  Flickr Browser
//
//  Created by Jake Spencer on 7/18/14.
//  Copyright (c) 2014 Uncarbonated Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLBRDataSource.h"
#import "FLBRCommentTableViewCell.h"

@interface FLBRPhotoViewController : UITableViewController
@property (strong, nonatomic) NSString *photoid;

@end
