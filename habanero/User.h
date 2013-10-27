//
//  User.h
//  habanero
//
//  Created by Jay Vana on 22/6/13.
//  Copyright (c) 2013 Jay Vana. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *subscriptions;

- (User *)initWithName:(NSString *)name;
- (void)addSubscription:(id)subscription;

@end
