//
//  ComicTableCell.h
//  habanero
//
//  Created by Jay Vana on 23/6/13.
//  Copyright (c) 2013 Jay Vana. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComicTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *comicTitle;
@property (nonatomic, weak) IBOutlet UILabel *unread;

@end
