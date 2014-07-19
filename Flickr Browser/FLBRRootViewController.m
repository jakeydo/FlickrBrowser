//
//  FLBRRootViewController.m
//  Flickr Browser
//
//  Created by Jake Spencer on 7/16/14.
//  Copyright (c) 2014 Uncarbonated Software LLC. All rights reserved.
//

#import "FLBRRootViewController.h"

@interface FLBRRootViewController ()

@property FLBRExploreViewController *exploreVC;
@property FLBRMyPhotosViewController *myPhotosVC;

@end

@implementation FLBRRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.exploreVC = [[FLBRExploreViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc]init]];
        self.myPhotosVC = [[FLBRMyPhotosViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc]init]];
        
        UINavigationController *exploreNavVC = [[UINavigationController alloc] initWithRootViewController:self.exploreVC];
        exploreNavVC.title = @"Explore";
        exploreNavVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Explore" image:nil tag:0];

        UINavigationController *myPhotosNavVC = [[UINavigationController alloc] initWithRootViewController:self.myPhotosVC];
        myPhotosNavVC.title = @"My Photos";
        myPhotosNavVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"My Photos" image:nil tag:1];
        
        self.viewControllers = @[exploreNavVC, myPhotosNavVC];
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
