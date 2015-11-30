//
//  ViewController.m
//  YAWA
//
//  Created by Juan Luis Suarez on 22/11/15.
//  Copyright © 2015 playwhile. All rights reserved.
//

#import "MainViewController.h"
#import "DetailViewController.h"
#import "UIImageView+PINRemoteImage.h"
#import "AFNetworking.h"
#import "CGLDefaultsBackedPropertyObserver.h"
#import "MBPlacePickerController.h"
#import "LMGeocoder.h"
#import "SVProgressHUD.h"

//////////////////////////////////////////////////////////////////////////////////////

@interface MainViewController () <MBPlacePickerDelegate>

@property (nonatomic) NSString *city;
@property (strong) NSMutableArray *weather;

@property (strong, nonatomic) IBOutlet UITableView *list;
@property (strong, nonatomic) MBPlacePickerController *locationPickerController;

@property (strong, nonatomic) DetailViewController *detailViewController;

@end

//////////////////////////////////////////////////////////////////////////////////////

@implementation MainViewController

//////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Custom

// Fetch data from OpenWeatherMap API
-(void)loadData {
    
    if (!self.city) {
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Loading…"];
    
    NSString *sUrl = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?q=%@&mode=json&units=metric&cnt=7&APPID=8b7661be7bbdbfb1004eb364dd045ab6", [self.city stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:sUrl parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             /////////////////////////////////////////////
             
             // Set data
             self.city = (NSString*) responseObject[@"city"][@"name"];
             self.weather = [NSMutableArray array];
             
             NSArray *data = [responseObject objectForKey:@"list"];
             for (int i = 0; i < [data count] ;i++) {
                 [ self.weather addObject: (NSDictionary*)responseObject[@"list"][i] ];
             }
             
             /////////////////////////////////////////////
             
             // Reload and dismiss
             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [SVProgressHUD dismiss];
                     [self.list reloadData];
                 });
             });
             
             /////////////////////////////////////////////
            
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"-------------------------------");
             NSLog(@"Error: %@", error);
             NSLog(@"-------------------------------");
         }];
}

// Load location picker view
- (IBAction)doChangeCity:(id)sender {
    [self.locationPickerController display];
}

//////////////////////////////////////////////////////////////////////////////////////

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Prepare location picker view
    self.locationPickerController = [[MBPlacePickerController alloc] init];
    self.locationPickerController.showSearch = YES;
    self.locationPickerController.map.showUserLocation = YES;
    self.locationPickerController.delegate = self;
    
    // Some cities by default, we can add more in the future
    self.locationPickerController.serverURL = @"https://raw.githubusercontent.com/jlsuarezs/MBPlacePickerController/master/server-locations.json";
    [self.locationPickerController enableAutomaticUpdates];
    
    // Cache system, prepare to watch!
    [[CGLDefaultsBackedPropertyObserver sharedObserver] observeProperty: @"city"
                                                                 object: self
                                                                    key: @"CITY"
                                                           defaultValue: nil];
    
    // Set title
    self.title = self.city ? self.city: @"Weather";
    
    // Fetch data
    [self loadData];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    // Set title
    self.navigationController.navigationBar.topItem.title = self.city;
    
    // Call location picker if no previous weather
    if (!self.city) {
        [self.locationPickerController display];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//////////////////////////////////////////////////////////////////////////////////////

#pragma mark - MBPlacePickerController delegate

- (void)placePickerController:(MBPlacePickerController *)placePicker didChangeToPlace:(CLLocation *)place
{
    [[LMGeocoder sharedInstance] reverseGeocodeCoordinate:place.coordinate service:kLMGeocoderGoogleService
    completionHandler:^(NSArray *results, NSError *error) {
        
        if (results.count && !error) {
            LMAddress *address = [results firstObject];
            
            // Set city, automatic saved in cache
            self.city = [NSString stringWithFormat:@"%@, %@", address.locality, address.country];
            self.title = address.locality;
            
            // Fetch weather data
            [self loadData];
            NSLog(@"CITY: %@", self.city);
        }
    }];
}

//////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// [@"list"]
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.weather count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainCell" forIndexPath:indexPath];
    
    /////////////////////////////////////////////
    
    // Weather icon
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:101];
    [imageView setPin_updateWithProgress:YES];
    NSString *sUrl = [NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png",
                      self.weather[indexPath.row][@"weather"][0][@"icon"]];    
    [imageView pin_setImageFromURL: [NSURL URLWithString: sUrl] ];
    
    /////////////////////////////////////////////
    
    // Day of week
    NSTimeInterval _interval=[self.weather[indexPath.row][@"dt"] doubleValue];
    NSDate *dateSince1970 = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setDateFormat:@"EEEE"];
    
    NSString *date = [_formatter stringFromDate:dateSince1970];
    
    UILabel *lblDay = (UILabel *)[cell viewWithTag:102];
    lblDay.text = date;
    
    /////////////////////////////////////////////
    
    // Description
    UILabel *lblDesc = (UILabel *)[cell viewWithTag:103];
    lblDesc.text = [self.weather[indexPath.row][@"weather"][0][@"description"] capitalizedString];
    
    /////////////////////////////////////////////
    
    // Temp
    UILabel *lblTemp = (UILabel *)[cell viewWithTag:104];
    lblTemp.text = [NSString stringWithFormat:@"%d º", [self.weather[indexPath.row][@"temp"][@"day"] intValue] ];
    
    /////////////////////////////////////////////
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    /////////////////////////////////////////////
    
    // Load detail view
    DetailViewController *destViewController = (DetailViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"DetailView"];;

    [destViewController loadData:self.city withWeather:self.weather andIndex:indexPath.row];
        
    [self.navigationController pushViewController:destViewController animated:YES];
    
    
    /////////////////////////////////////////////
}


@end
