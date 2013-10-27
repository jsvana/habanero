//
//  Comic.h
//  habanero
//
//  Created by Jay Vana on 22/6/13.
//  Copyright (c) 2013 Jay Vana. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comic : NSObject

@property (strong, nonatomic) NSString *name;
@property (nonatomic) int id;
@property (nonatomic) int latest;
@property (nonatomic) int total;
@property (nonatomic) int unread;
@property (nonatomic) NSString *urlBase;
@property (nonatomic) NSString *urlTail;

- (Comic *)initWithName:(NSString *)name id:(int)id latest:(int)latest total:(int)total andUnread:(int)unread;

- (void)addBase:(NSString *)urlBase andTail:(NSString *)urlTail;

@end
