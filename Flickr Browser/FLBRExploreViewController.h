//
//  FLBRExploreViewController.h
//  Flickr Browser
//
//  Created by Jake Spencer on 7/16/14.
//  Copyright (c) 2014 Uncarbonated Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLBRDataSource.h"
#import "FLBRThumbnailCell.h"
#import "FLBRPhotoViewController.h"

@interface FLBRExploreViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@end
