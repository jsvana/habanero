//
//  Comic.m
//  habanero
//
//  Created by Jay Vana on 22/6/13.
//  Copyright (c) 2013 Jay Vana. All rights reserved.
//

#import "Comic.h"

@implementation Comic

- (Comic *)initWithName:(NSString *)name id:(int)id latest:(int)latest total:(int)total andUnread:(int)unread {
    self.name = name;
    self.id = id;
    self.latest = latest;
    self.total = total;
    self.unread = unread;
    return self;
}

- (void)addBase:(NSString *)urlBase andTail:(NSString *)urlTail {
    self.urlBase = urlBase;
    self.urlTail = urlTail;
}

@end
