//
//  User.m
//  habanero
//
//  Created by Jay Vana on 22/6/13.
//  Copyright (c) 2013 Jay Vana. All rights reserved.
//

#import "User.h"

@implementation User

- (User *)initWithName:(NSString *)name {
    self.name = name;
    self.subscriptions = [[NSMutableArray alloc] init];
    return self;
}

- (void)addSubscription:(id)subscription {
    [self.subscriptions addObject:subscription];
}

@end
