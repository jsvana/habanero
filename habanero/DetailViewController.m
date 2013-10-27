//
//  DetailViewController.m
//  habanero
//
//  Created by Jay Vana on 22/6/13.
//  Copyright (c) 2013 Jay Vana. All rights reserved.
//

#import "DetailViewController.h"
#import "Comic.h"
#import "AFJSONRequestOperation.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        Comic *comic = self.detailItem;
        self.navigationItem.title = comic.name;
        [self fetchComicData:comic];
    }
}

- (void)fetchComicData:(Comic *)comic {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://piperka.net/s/archive/%d", comic.id]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        Comic *comic = self.detailItem;
        [comic addBase:[JSON valueForKey:@"url_base"] andTail:[JSON valueForKey:@"url_tail"]];
        NSString *comicID = [[[JSON valueForKey:@"pages"] objectAtIndex:comic.latest ] objectAtIndex:0];
        
        if (comicID == (id)[NSNull null] || comicID.length == 0) {
            comicID = @"";
        }
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", comic.urlBase, comicID, comic.urlTail]];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Unable to load data, %@", error);
    }];
    
    [operation start];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Comics", @"Comics");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
