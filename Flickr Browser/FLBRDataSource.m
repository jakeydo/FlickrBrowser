//
//  FLBRDataSource.m
//  Flickr Browser
//
//  Created by Jake Spencer on 7/16/14.
//  Copyright (c) 2014 Uncarbonated Software LLC. All rights reserved.
//

#import "FLBRDataSource.h"

@implementation FLBRDataSource

+(instancetype) sharedDataSource
{
    static FLBRDataSource *sharedMyDataSource;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedMyDataSource = [[self alloc] init];
    });
    
    return sharedMyDataSource;
}

-(instancetype)init
{
    self = [super init];
    
    if(self)
    {
        self.session = [NSURLSession sharedSession];
        self.thumbnailDictionary = [[NSMutableDictionary alloc] init];
        self.interestingPhotoDictionaries = [[NSMutableArray alloc] initWithCapacity:500];
        self.commentsDictionary = [[NSMutableDictionary alloc] init];
        self.largePhotosDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(void) requestInterestingPhotoDictionaries
{
    for (int i=1; i < 6; i++)
    {
        [self requestInterestingPhotoDictionaries:i];
    }
}

-(void) requestInterestingPhotoDictionaries:(NSInteger)page
{
    NSString *requestURLString = [NSString stringWithFormat:@"%@?method=flickr.interestingness.getList&api_key=%@&extras=owner_name&page=%d&format=json&nojsoncallback=1",FLBRflickrAPIBaseURL,FLBRflickrAPIKey,(int)page];
    //NSLog(requestURLString);
    NSURL *requestURL = [NSURL URLWithString:requestURLString];
    self.intestingTask = [self.session dataTaskWithURL:requestURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *resultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSDictionary *photosDictionary = [resultsDictionary objectForKey:@"photos"];
        [self.interestingPhotoDictionaries addObjectsFromArray:[photosDictionary objectForKey:@"photo"]];
        //        self.interestingPhotoDictionaries = [photosDictionary objectForKey:@"photo"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"net.jakespencer.FLBRDidReceiveInterestingPhotosDictionary" object:nil];
    }];
    [self.intestingTask resume];
}

-(void) requestAllThumbnails
{
    for (NSDictionary *info in self.interestingPhotoDictionaries)
    {
        NSString *photoid = [info objectForKey:@"id"];
        if(![self.thumbnailDictionary objectForKey:photoid])
        {
            [self requestThumbnail:info];
        }
    }
}

-(void) requestThumbnail:(NSDictionary*)infoDictionary
{
    NSString *farm = [infoDictionary objectForKey:@"farm"];
    NSString *photoid = [infoDictionary objectForKey:@"id"];
    NSString *secret = [infoDictionary objectForKey:@"secret"];
    NSString *server = [infoDictionary objectForKey:@"server"];
    
    NSString *requestURLString = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@_t.jpg", farm, server, photoid, secret];
    NSURL *requestURL = [NSURL URLWithString:requestURLString];
    
    NSURLSessionTask *thumbnailTask = [self.session dataTaskWithURL:requestURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        UIImage *thumbnail = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
                [self.thumbnailDictionary setObject:thumbnail forKey:photoid];
        });


        [[NSNotificationCenter defaultCenter] postNotificationName:@"net.jakespencer.FLBRDidReceiveThumbnail" object:nil userInfo:infoDictionary];
        
    }];
    [thumbnailTask resume];
}

-(NSInteger) numberOfThumbnails
{
    return [self.interestingPhotoDictionaries count];
}

-(CGSize) sizeForThumbnail:(NSInteger)i
{
    UIImage *thumbnail = [self thumbnail:i];
    
    if (thumbnail)
    {
        return thumbnail.size;
    }
    else
    {
        return CGSizeMake(100.0, 70.0);
    }
}

-(UIImage*) thumbnail:(NSInteger)i
{
    NSDictionary *info = [self.interestingPhotoDictionaries objectAtIndex:i];
    NSString *photoid = [info objectForKey:@"id"];
    if (photoid && self.thumbnailDictionary)
    {
        if ([self.thumbnailDictionary objectForKey:photoid])
        {
            UIImage *thumbnail = [self.thumbnailDictionary objectForKey:photoid];
            return thumbnail;
        }
        else
        {
            return nil;
        }

    }
    else
    {
        return nil;
    }
    
}

-(NSInteger) indexForPhotoWithID:(NSString*)photoid
{
    for (int i=0; i< [self.interestingPhotoDictionaries count]; i++)
    {
        NSDictionary *info = [self.interestingPhotoDictionaries objectAtIndex:i];
        NSString *thisid = [info objectForKey:@"id"];
        
        if([photoid isEqualToString:thisid])
        {
            return i;
        }
    }
    return -1;
}

-(void) loadNextPageofThumbnailsforIndex:(NSInteger)index
{
    long pageToLoad = index / 100 + 2;
    //the next line is an ugly hack because even though flickr said pages have 100 photos, sometiems they don't
    long numberOfPagesLoaded = ([self.interestingPhotoDictionaries count] - 1) / 100 + 1;
    if (pageToLoad < 6 && pageToLoad > numberOfPagesLoaded)
    {
        [self requestInterestingPhotoDictionaries:pageToLoad];
    }
}

#pragma mark -
#pragma mark PhotoVC stuff

-(NSString*) authorForPhotoWithID:(NSString*)photoid
{
    NSInteger index = [self indexForPhotoWithID:photoid];
    NSDictionary *photoDictionary = [self.interestingPhotoDictionaries objectAtIndex:index];
    
    return [photoDictionary objectForKey:@"ownername"];
}

-(NSString*) titleForPhotoWithID:(NSString*)photoid
{
    NSInteger index = [self indexForPhotoWithID:photoid];
    NSDictionary *photoDictionary = [self.interestingPhotoDictionaries objectAtIndex:index];
    
    return [photoDictionary objectForKey:@"title"];
}

-(void) requestCommentsForPhotoWithID:(NSString*)photoid
{
    if (![self.commentsDictionary objectForKey:photoid]) {
        NSString *requestURLString = [NSString stringWithFormat:@"%@?method=flickr.photos.comments.getList&api_key=%@&photo_id=%@&format=json&nojsoncallback=1",FLBRflickrAPIBaseURL,FLBRflickrAPIKey,photoid];
        NSURL *requestURL = [NSURL URLWithString:requestURLString];
        self.intestingTask = [self.session dataTaskWithURL:requestURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *resultsDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSDictionary *commentsDictionary = [resultsDictionary objectForKey:@"comments"];
            NSArray *commentsArray = [commentsDictionary objectForKey:@"comment"];
            [self.commentsDictionary setObject:commentsArray forKey:photoid];
            NSDictionary *idDictionary = @{@"id": photoid};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"net.jakespencer.FLBRDidReceiveComments" object:nil userInfo:idDictionary];
        }];
        [self.intestingTask resume];
    }
}

-(NSArray*) commentsForPhotoWithID:(NSString*)photoid
{
    NSArray *commentsDictionary = [self.commentsDictionary objectForKey:photoid];
    
    if(commentsDictionary)
    {
        return commentsDictionary;
    }
    else
    {
        [self requestCommentsForPhotoWithID:photoid];
        return nil;
    }
}

-(NSString*) photoidForPhotoAtIndex:(NSInteger)index
{
    NSDictionary *infoDictionary = [self.interestingPhotoDictionaries objectAtIndex:index];
    NSString *photoid = [infoDictionary objectForKey:@"id"];
    return photoid;
}

- (UIImage*) largePhotoForID:(NSString*)photoid
{
    UIImage *photo = [self.largePhotosDictionary objectForKey:photoid];
    
    if(photo)
    {
        return photo;
    }
    else
    {
        NSInteger index = [self indexForPhotoWithID:photoid];
        NSDictionary *photoDictionary = [self.interestingPhotoDictionaries objectAtIndex:index];
        [self requestLargePhoto:photoDictionary];
        UIImage *blankImage = [[UIImage alloc] init];
        [self.largePhotosDictionary setObject:blankImage forKey:photoid];
        return blankImage;
    }
}

-(void) requestLargePhoto:(NSDictionary*)infoDictionary
{
    NSString *farm = [infoDictionary objectForKey:@"farm"];
    NSString *photoid = [infoDictionary objectForKey:@"id"];
    NSString *secret = [infoDictionary objectForKey:@"secret"];
    NSString *server = [infoDictionary objectForKey:@"server"];
    
    NSString *requestURLString = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@_b.jpg", farm, server, photoid, secret];
    NSURL *requestURL = [NSURL URLWithString:requestURLString];
    
    NSURLSessionTask *thumbnailTask = [self.session dataTaskWithURL:requestURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        UIImage *photo = [UIImage imageWithData:data];
        [self.largePhotosDictionary setObject:photo forKey:photoid];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"net.jakespencer.FLBRDidReceiveLargePhoto" object:nil userInfo:infoDictionary];
        
    }];
    [thumbnailTask resume];
}

@end