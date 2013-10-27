//
//  MasterViewController.h
//  habanero
//
//  Created by Jay Vana on 22/6/13.
//  Copyright (c) 2013 Jay Vana. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "User.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController {
    @private
    NSMutableDictionary *comics;
    NSMutableArray *subscriptionData;
    NSString *csrfHam;
    User *user;
}

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
