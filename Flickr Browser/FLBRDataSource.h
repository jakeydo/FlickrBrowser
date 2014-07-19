//
//  FLBRDataSource.h
//  Flickr Browser
//
//  Created by Jake Spencer on 7/16/14.
//  Copyright (c) 2014 Uncarbonated Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLBRDataSource : NSObject

@property NSURLSession *session;
@property NSURLSessionTask *intestingTask;
@property NSMutableArray *interestingPhotoDictionaries;
@property NSMutableDictionary *thumbnailDictionary;
@property NSInteger lastLoadedPage;
@property NSMutableDictionary *commentsDictionary;
@property NSMutableDictionary *largePhotosDictionary;

+(instancetype) sharedDataSource;
-(void) requestInterestingPhotoDictionaries;
-(void) requestInterestingPhotoDictionaries:(NSInteger)page;
-(void) requestAllThumbnails;
-(void) requestThumbnail:(NSDictionary*)infoDictionary;
-(NSInteger) numberOfThumbnails;
-(CGSize) sizeForThumbnail:(NSInteger)i;
-(UIImage*) thumbnail:(NSInteger)i;
-(NSInteger) indexForPhotoWithID:(NSString*)photoid;
-(void) loadNextPageofThumbnailsforIndex:(NSInteger)index;
-(NSString*) authorForPhotoWithID:(NSString*)photoid;
-(NSString*) titleForPhotoWithID:(NSString*)photoid;
-(void) requestCommentsForPhotoWithID:(NSString*)photoid;
-(NSArray*) commentsForPhotoWithID:(NSString*)photoid;
-(NSString*) photoidForPhotoAtIndex:(NSInteger)index;
- (UIImage*) largePhotoForID:(NSString*)photoid;
-(void) requestLargePhoto:(NSDictionary*)infoDictionary;

@end
