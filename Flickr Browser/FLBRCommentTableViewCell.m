//
//  FLBRCommentTableViewCell.m
//  Flickr Browser
//
//  Created by Jake Spencer on 7/18/14.
//  Copyright (c) 2014 Uncarbonated Software LLC. All rights reserved.
//

#import "FLBRCommentTableViewCell.h"
@interface FLBRCommentTableViewCell ()
@property UITextView *textView;
@property UILabel *authorLabel;
@end

@implementation FLBRCommentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
    }
    return self;
}

- (void)setComment:(NSString *)comment
{
    _comment = comment;
    
    if (!self.textView)
    {
        self.textView = [[UITextView alloc] init];
        self.textView.scrollEnabled = NO;
        self.textView.editable = NO;
        [self.contentView addSubview:self.textView];
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.font = [self.textView.font fontWithSize:12.0];
    }
//    [self.textView removeFromSuperview];
    self.textView.attributedText = [[NSAttributedString alloc] initWithData:[comment dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    self.textView.frame = self.contentView.frame;
    self.textView.frame = CGRectMake(20.0, 18.0, self.contentView.frame.size.width-21.0, self.contentView.frame.size.height-18.0);
    [self.textView sizeToFit];
//    self.detailTextLabel.text = comment;
}

- (void)setAuthor:(NSString *)author
{
    _author = author;
    
    if(!self.authorLabel)
    {
        self.authorLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.authorLabel];
    }
 
    self.authorLabel.frame = CGRectMake(5.0, 5.0, self.contentView.frame.size.width, 0.0);
    self.authorLabel.textColor = [UIColor purpleColor];
    self.authorLabel.text = author;
    self.authorLabel.font = [self.textLabel.font fontWithSize:14.0];
    [self.authorLabel sizeToFit];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
