//
//  ComicTableCell.m
//  habanero
//
//  Created by Jay Vana on 23/6/13.
//  Copyright (c) 2013 Jay Vana. All rights reserved.
//

#import "ComicTableCell.h"

@implementation ComicTableCell

@synthesize comicTitle = _comicTitle;
@synthesize unread = _unread;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
