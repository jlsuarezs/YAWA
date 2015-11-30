//
//  DetailViewController.m
//  YAWA
//
//  Created by Juan Luis Suarez on 23/11/15.
//  Copyright © 2015 playwhile. All rights reserved.
//

#import "DetailViewController.h"
#import "UIImageView+PINRemoteImage.h"
#import "SVProgressHUD.h"

@interface DetailViewController ()

@property (nonatomic, assign) NSInteger index;

@property (nonatomic) NSString *city;
@property (strong) NSMutableArray *weather;

@property (strong, nonatomic) IBOutlet UILabel *lblDay;
@property (strong, nonatomic) IBOutlet UIImageView *imgWeather;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;
@property (strong, nonatomic) IBOutlet UILabel *lblMinMax;
@property (strong, nonatomic) IBOutlet UILabel *lblTemp;


@end

@implementation DetailViewController

//////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Custom

// Selected row
- (void) loadData:(NSString *) cty withWeather:(NSMutableArray *) weathr andIndex:(NSInteger) indx
{
    self.city = cty;
    self.weather = weathr;
    self.index = indx;
}

//////////////////////////////////////////////////////////////////////////////////////

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
   
    if (!self.city || !self.weather || [self.weather count] < 1 ) {
        [SVProgressHUD showErrorWithStatus:@"Error"];
        return;
    }
    
    // Set title and back button title
    self.title = @"Weather";

    /////////////////////////////////////////////
    
    // Weather icon
    [self.imgWeather setPin_updateWithProgress:YES];
    NSString *sUrl = [NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png",
                      self.weather[self.index][@"weather"][0][@"icon"]];
    [self.imgWeather pin_setImageFromURL: [NSURL URLWithString: sUrl] ];
    
    /////////////////////////////////////////////
    
    // Day of week
    NSTimeInterval _interval=[self.weather[self.index][@"dt"] doubleValue];
    NSDate *dateSince1970 = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setDateFormat:@"EEEE"];
    
    NSString *date = [_formatter stringFromDate:dateSince1970];
    
    self.lblDay.text = date;
    
    /////////////////////////////////////////////
    
    // Description
    self.lblDescription.text = [self.weather[self.index][@"weather"][0][@"description"] capitalizedString];
    
    /////////////////////////////////////////////
    
    // Temp
    self.lblTemp.text = [NSString stringWithFormat:@"%d º", [self.weather[self.index][@"temp"][@"day"] intValue] ];
    
    /////////////////////////////////////////////
    
    // Min/Max
    self.lblMinMax.text = [NSString stringWithFormat:@"Min %d º Max %d º", [self.weather[self.index][@"temp"][@"min"] intValue], [self.weather[self.index][@"temp"][@"max"] intValue] ];
    
    /////////////////////////////////////////////
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//////////////////////////////////////////////////////////////////////////////////////

@end
