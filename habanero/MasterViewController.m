//
//  MasterViewController.m
//  habanero
//
//  Created by Jay Vana on 22/6/13.
//  Copyright (c) 2013 Jay Vana. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "ComicTableCell.h"

#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "User.h"
#import "Comic.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    NSURL *url = [NSURL URLWithString:@"http://piperka.net"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"jsvana", @"user",
                            @"linked", @"passwd_clear",
                            nil];
    [httpClient postPath:@"/updates.html" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"http://piperka.net/updates.html"]];
        for (NSHTTPCookie *cookie in cookies) {
            if ([cookie.name isEqualToString:@"p_session"]) {
                csrfHam = cookie.value;
                break;
            }
        }
        [self fetchComicsInformation];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
}

- (void)fetchComicsInformation {
    NSURL *url = [NSURL URLWithString:@"http://piperka.net/d/comics_ordered.json"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    [httpClient postPath:@"/d/comics_ordered.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *jsonParsingError = nil;
        NSArray *comicsData = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                  options:0 error:&jsonParsingError];
        comics = [[NSMutableDictionary alloc] initWithCapacity:[comicsData count]];
        
        for (id comic in comicsData) {
            [comics setObject:[comic objectAtIndex:1] forKey:[comic objectAtIndex:0]];
        }
        
        [self fetchUserData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
}

- (void)fetchUserData {
    NSURL *url = [NSURL URLWithString:@"http://piperka.net/s/uprefs"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        user = [[User alloc] initWithName: [JSON valueForKeyPath:@"name"]];
        NSArray *subscriptions = [JSON valueForKeyPath:@"subscriptions"];
        subscriptionData = [[NSMutableArray alloc] initWithCapacity:[subscriptions count]];
        
        for (id sub in subscriptions) {
            [user addSubscription:sub];
            
            Comic *comic = [[Comic alloc] initWithName:[comics objectForKey:[sub objectAtIndex:0]] id:[[sub objectAtIndex:0] integerValue] latest:[[sub objectAtIndex:1] integerValue] total:[[sub objectAtIndex:2] integerValue] andUnread:[[sub objectAtIndex:4] integerValue]];
            
            if (comic.unread > 0) {
                [subscriptionData addObject:comic];
            }
        }
        
        [self.tableView reloadData];
    } failure:nil];
    
    [operation start];
}

- (void)clearUpdates:(Comic *)comic {
    NSString *update = [NSString stringWithFormat:@"updates.html?redir=%d&csrf_ham=%@", comic.id, csrfHam];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://piperka.net"]];
    
    [httpClient postPath:update parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        comic.unread = 0;
        
        NSIndexPath *ipath = [self.tableView indexPathForSelectedRow];
        [self.tableView reloadData];
        [self.tableView selectRowAtIndexPath:ipath animated:NO scrollPosition:UITableViewScrollPositionNone];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return subscriptionData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ComicTableCell *cell = (ComicTableCell *)[tableView dequeueReusableCellWithIdentifier:@"ComicTableCell" forIndexPath:indexPath];

    if (cell == nil) {
        cell = [[ComicTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ComicTableCell"];
    }
    
    Comic *comic = subscriptionData[indexPath.row];
    cell.comicTitle.text = comic.name;
    cell.unread.text = [NSString stringWithFormat:@"%d", comic.unread];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [subscriptionData removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        Comic *comic = subscriptionData[indexPath.row];
        self.detailViewController.detailItem = comic;
        
        [self clearReadComics];
        [self clearUpdates:comic];
    }
}

- (void)clearReadComics {
    NSMutableArray *itemsToKeep = [NSMutableArray arrayWithCapacity:[subscriptionData count]];
    for (Comic *comic in subscriptionData) {
        if (comic.unread > 0) {
            [itemsToKeep addObject:comic];
        }
    }
    [subscriptionData setArray:itemsToKeep];
    
    NSIndexPath *ipath = [self.tableView indexPathForSelectedRow];
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:ipath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Comic *object = subscriptionData[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
