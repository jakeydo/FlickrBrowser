//
//  FLBRPhotoViewController.m
//  Flickr Browser
//
//  Created by Jake Spencer on 7/18/14.
//  Copyright (c) 2014 Uncarbonated Software LLC. All rights reserved.
//

#import "FLBRPhotoViewController.h"

@interface FLBRPhotoViewController ()
@property FLBRDataSource *dataSource;
@property NSArray *commentsArray;
@property UITextView *calculationTextView;
@property UIImageView *photoView;
@property CGFloat scaleFactor;

@end

@implementation FLBRPhotoViewController

-(void)setPhotoid:(NSString *)photoid
{
    _photoid = photoid;
    
    self.commentsArray = [self.dataSource commentsForPhotoWithID:photoid];
    [self.tableView reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.dataSource = [FLBRDataSource sharedDataSource];
        [self.tableView registerClass:[FLBRCommentTableViewCell class] forCellReuseIdentifier:@"tableCell"];
        [self startObservingNotifications];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.commentsArray count] + 2;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -
#pragma mark Notification stuff
- (void) startObservingNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNSNotification:) name:@"net.jakespencer.FLBRDidReceiveComments" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNSNotification:) name:@"net.jakespencer.FLBRDidReceiveLargePhoto" object:nil];
}

- (void) handleNSNotification:(NSNotification*)notification
{
    if ([notification.name isEqualToString:@"net.jakespencer.FLBRDidReceiveComments"])
    {
        //        NSLog(@"got some interesting photos");
        //        [self didReceiveInterestingPhotosDictionary];
        NSDictionary *notificationDictionary = notification.userInfo;
        NSString *commentedPhotoid = [notificationDictionary objectForKey:@"id"];
        if ([commentedPhotoid isEqualToString:self.photoid])
        {
            [self performSelectorOnMainThread:@selector(didReceiveComments) withObject:nil waitUntilDone:YES];
        }
        
    }
    else if ([notification.name isEqualToString:@"net.jakespencer.FLBRDidReceiveLargePhoto"])
    {
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }
}

-(void) didReceiveComments
{
    self.commentsArray = [self.dataSource commentsForPhotoWithID:self.photoid];
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0 )
    {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"photoCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"photoCell"];
        }
        
        if (!self.photoView)
        {
            self.photoView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 100.0)];
            [cell addSubview:self.photoView];
            [self.photoView setContentMode:UIViewContentModeScaleAspectFill];
        }
        
        self.photoView.image = [self.dataSource largePhotoForID:self.photoid];
        [self.photoView sizeToFit];
        
//        self.scaleFactor = 1.0;
//        if (self.photoView.frame.size.width > 0.0)
//        {
//            self.scaleFactor = self.view.frame.size.width / self.photoView.frame.size.width;
//        }

        
        self.photoView.frame = CGRectMake(0.0, 0.0, self.scaleFactor * self.photoView.frame.size.width, self.scaleFactor * self.photoView.frame.size.height);

        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];        
        return cell;
    }
    else if (indexPath.row == 1)
    {        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"titleCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"titleCell"];
        }
        
        cell.textLabel.text = [self.dataSource titleForPhotoWithID:self.photoid];
        NSString *author = [self.dataSource authorForPhotoWithID:self.photoid];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"by: %@",author];

        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;
    }
    else
    {
        FLBRCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableCell" forIndexPath:indexPath];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary *commentDictionary = [self.commentsArray objectAtIndex:(indexPath.row - 2)];
        cell.author = [commentDictionary objectForKey:@"authorname"];
        NSString *commentString = [commentDictionary objectForKey:@"_content"];
        
        cell.comment = commentString;
        
        return cell;

    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
//        return 1000.0;
        UIImage *image = [self.dataSource largePhotoForID:self.photoid];
        if (image.size.width > 0.0)
        {
            self.scaleFactor = self.view.frame.size.width / image.size.width;
        }
        else
        {
            self.scaleFactor = 1.0;
        }

        return self.scaleFactor * image.size.height;
    }
    else if (indexPath.row == 1)
    {
        return 45.0;
    }
    else
    {
        
        CGRect baseRect = CGRectMake(0.0, 0.0, self.view.frame.size.width-21.0, 0.0);
        if(!self.calculationTextView)
        {
            self.calculationTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        }
        
        self.calculationTextView.frame = baseRect;
        NSDictionary *commentDictionary = [self.commentsArray objectAtIndex:(indexPath.row - 2)];
        //    cell.textLabel.text = [commentDictionary objectForKey:@"authorname"];
        NSString *commentString = [commentDictionary objectForKey:@"_content"];
        self.calculationTextView.attributedText = [[NSAttributedString alloc] initWithData:[commentString dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        [self.calculationTextView sizeToFit];
        
        return (self.calculationTextView.frame.size.height + 18.0);
        
    }
    
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
