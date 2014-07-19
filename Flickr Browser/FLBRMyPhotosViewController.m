//
//  FLBRMyPhotosViewController.m
//  Flickr Browser
//
//  Created by Jake Spencer on 7/16/14.
//  Copyright (c) 2014 Uncarbonated Software LLC. All rights reserved.
//

#import "FLBRMyPhotosViewController.h"

@interface FLBRMyPhotosViewController ()

@end

@implementation FLBRMyPhotosViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//        self.title = @"My Photos";
//        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"My Photos" image:nil selectedImage:nil];
//
//    }
//    return self;
//}

- (instancetype) initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.title = @"My Photos";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"My Photos" image:nil selectedImage:nil];
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
