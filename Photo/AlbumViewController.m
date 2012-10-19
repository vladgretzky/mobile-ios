//
//  AlbumViewController.m
//  Photo
//
//  Created by Patrick Santana on 09/10/12.
//  Copyright 2012 Photo
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "AlbumViewController.h"

@interface AlbumViewController ()
- (void) loadAlbums;

// to avoid multiples loading
@property (nonatomic) BOOL isLoading;

@end

@implementation AlbumViewController

@synthesize albums = _albums;
@synthesize isLoading = _isLoading;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.tableView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Background.png"]];
        
        // initialize the object albums
        self.albums = [NSMutableArray array];
        
        // color separator
        self.tableView.separatorColor = UIColorFromRGB(0xC8BEA0);
        
        // is loading albums
        self.isLoading = NO;
    }
    return self;
}
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleLeftView)];
    
    if ([self.navigationItem respondsToSelector:@selector(rightBarButtonItems)]) {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:
                                                   [[UIBarButtonItem alloc] initWithTitle:@"Sync" style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleRightView)],
                                                   nil];
    }
    else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sync" style:UIBarButtonItemStyleBordered target:self.viewDeckController action:@selector(toggleRightView)];
    }
    
    // title
    self.navigationItem.title = NSLocalizedString(@"Albums", @"Menu - title for Albums");
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // load all albums
    [self loadAlbums];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.albums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    NSUInteger row = [indexPath row];
    
    Album *album = [self.albums objectAtIndex:row];
    cell.textLabel.text=album.name;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%d", album.quantity];
    cell.detailTextLabel.textColor = UIColorFromRGB(0xE6501E);
    
    return cell;
}



#pragma mark
#pragma mark - Methods to get albums via json
- (void) loadAlbums
{
    
    if (self.isLoading == NO){
        self.isLoading = YES;
        // if there isn't netwok
        /*
         if ( [AppDelegate internetActive] == NO ){
         // problem with internet, show message to user
         PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:@"Failed! Check your internet connection" duration:5000];
         [alert showAlert];
         
         self.isLoading = NO;
         }else {
         */
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.viewDeckController.view animated:YES];
        hud.labelText = @"Loading";
        
        dispatch_queue_t loadAlbums = dispatch_queue_create("loadAlbums", NULL);
        dispatch_async(loadAlbums, ^{
            // call the method and get the details
            @try {
                // get factory for OpenPhoto Service
                OpenPhotoService *service = [OpenPhotoServiceFactory createOpenPhotoService];
                NSArray *result = [service loadAlbums:25];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.albums removeAllObjects];
                    if ([result class] != [NSNull class]) {
                        // Loop through each entry in the dictionary and create an array Albums
                        for (NSDictionary *albumDetails in result){
                            // tag name
                            NSString *name = [albumDetails objectForKey:@"name"];
                            name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            
                            // how many images
                            NSString *qtd = [albumDetails objectForKey:@"count"];
                            
                            // create an album and add to the list
                            Album *album = [[Album alloc]initWithAlbumName:name Quantity:[qtd integerValue]];
                            [self.albums addObject:album];
                        }}
                    
                    [self.tableView reloadData];
                    [MBProgressHUD hideHUDForView:self.viewDeckController.view animated:YES];
                    self.isLoading = NO;
                    
                });
            }@catch (NSException *exception) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    PhotoAlertView *alert = [[PhotoAlertView alloc] initWithMessage:exception.description duration:5000];
                    [alert showAlert];
                    self.isLoading = NO;
                });
            }
        });
        dispatch_release(loadAlbums);
        //}
    }
    
}
@end