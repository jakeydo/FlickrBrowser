//
//  FLBRExploreViewController.m
//  Flickr Browser
//
//  Created by Jake Spencer on 7/16/14.
//  Copyright (c) 2014 Uncarbonated Software LLC. All rights reserved.
//

#import "FLBRExploreViewController.h"

@interface FLBRExploreViewController ()
@property FLBRDataSource *dataSource;
@property NSMutableArray *reloadBatchArray;
@property FLBRPhotoViewController *photoVC;

@end

@implementation FLBRExploreViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//        self.title = @"Explore";
//        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Explore" image:nil selectedImage:nil];
//    }
//    return self;
//}

- (instancetype) initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.title = @"Explore";
//        self.navigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Explore" image:nil selectedImage:nil];
        [self.collectionView registerClass:[FLBRThumbnailCell class] forCellWithReuseIdentifier:@"thumbCell"];
        [self startObservingNotifications];
//        self.collectionView.backgroundColor = [UIColor whiteColor];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
//        self.edgesForExtendedLayout = UIRectEdgeAll;
//        self.collectionView.contentInset = UIEdgeInsetsMake([UIApplication sharedApplication].statusBarFrame.size.height, 0, self.tabBarController.tabBar.frame.size.height, 0);
        self.dataSource = [FLBRDataSource sharedDataSource];
        
//        [self.dataSource requestInterestingPhotoDictionaries:1];
        [self.dataSource requestInterestingPhotoDictionaries];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark CollectionView stuff
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataSource numberOfThumbnails];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataSource sizeForThumbnail:indexPath.row];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FLBRThumbnailCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"thumbCell" forIndexPath:indexPath];
    cell.thumbnail = [self.dataSource thumbnail:indexPath.row];
    
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.photoVC)
    {
        self.photoVC = [[FLBRPhotoViewController alloc] init];
    }
    
    self.photoVC.photoid = [self.dataSource photoidForPhotoAtIndex:indexPath.row];

    [self.navigationController pushViewController:self.photoVC animated:YES];
}

//-(CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
//{
//    return [UIApplication sharedApplication].statusBarFrame.size;
//}
//
//-(CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
//{
//    float height = self.tabBarController.tabBar.frame.size.height;
//    float width = self.tabBarController.tabBar.frame.size.width;
//    return CGSizeMake(width, height);
//}

#pragma mark -
#pragma mark Notification stuff
- (void) handleNSNotification:(NSNotification*)notification
{
    if ([notification.name isEqualToString:@"net.jakespencer.FLBRDidReceiveInterestingPhotosDictionary"])
    {
//        NSLog(@"got some interesting photos");
//        [self didReceiveInterestingPhotosDictionary];
        [self performSelectorOnMainThread:@selector(didReceiveInterestingPhotosDictionary) withObject:nil waitUntilDone:YES];
    }
    else if ([notification.name isEqualToString:@"net.jakespencer.FLBRDidReceiveThumbnail"])
    {
//        NSLog(@"got a thumbnail");
        NSDictionary *info = notification.userInfo;
        [self performSelectorOnMainThread:@selector(didReceiveThumbnail:) withObject:info waitUntilDone:YES];
//        [self didReceiveThumbnail:info];
    }
}

- (void) startObservingNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNSNotification:) name:@"net.jakespencer.FLBRDidReceiveInterestingPhotosDictionary" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNSNotification:) name:@"net.jakespencer.FLBRDidReceiveThumbnail" object:nil];
}

- (void) didReceiveInterestingPhotosDictionary
{
    [self.collectionView reloadData];
    [self.dataSource requestAllThumbnails];
}

- (void) didReceiveThumbnail:(NSDictionary*)info
{
    NSString *photoid = [info objectForKey:@"id"];
    NSInteger photoIndex = [self.dataSource indexForPhotoWithID:photoid];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:photoIndex inSection:0];
    if (photoIndex > -1 && photoIndex < 500 && indexPath)
    {
//        NSLog(@"indexPath.row: %d",indexPath.row);
        //batching the reloads of thumbnails appears to fix a problem with having too many animations on the iPad
        if (!self.reloadBatchArray)
        {
            self.reloadBatchArray = [[NSMutableArray alloc] init];
        }
        
        [self.reloadBatchArray addObject:indexPath];
        
        if ([self.reloadBatchArray count] >9)
        {
            [self.collectionView reloadItemsAtIndexPaths:self.reloadBatchArray];
            self.reloadBatchArray = nil;
        }
    }
    
//    [self.collectionView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
