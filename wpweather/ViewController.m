//
//  ViewController.m
//  wpweather
//
//  Created by Sven-Jesko Strala on 13/07/15 W29.
//  Copyright (c) 2015 Westpac. All rights reserved.
//

#import "ViewController.h"
#import "WeatherReport.h"
#import "Util.h"
#import "LocationFetcher.h"

@interface ViewController ()

@end

@implementation ViewController

- (void) viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
}

- (void) didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void) startWaiting
{
  // button and spinner
  self.btnRefresh.enabled = NO;
  self.aivSpinner.hidden = NO;
  [self.aivSpinner startAnimating];

  // labels: display placeholders
  self.lblLocation.text = @"--loading--";
  self.lblWeatherSummary.text = @"--loading--";
  self.lblLastTimeChecked.text = @"--loading--";
}

- (void) stopWaitingWithSummary:(NSString*) summaryString
                    andlocation:(NSString*) locationString
{
  // button and spinner
  self.btnRefresh.enabled = YES;
  self.aivSpinner.hidden = YES;
  [self.aivSpinner stopAnimating];

  // labels: display results
  self.lblLocation.text = locationString;
  self.lblWeatherSummary.text = summaryString;
  NSDate *currDate = [NSDate date];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
  [dateFormatter setDateFormat:@"dd.MM.YY HH:mm:ss"];
  self.lblLastTimeChecked.text = [dateFormatter stringFromDate:currDate];
}

- (void) retrieveAndPopulateForLocation:(CLLocation*) myLocation
                               onFinish:(void (^)()) returnBlock
{
  [self startWaiting]; // idempotent, so can be run again

  __block NSString* location = @"Error";
  __block NSString* summary = @"Error";

  // if anything goes wrong while retrieving the weather
  // result will come back with nil, and location and summary
  // will both remain with value "Error"

  [Util runInBG:^()
  {
    NSDictionary* result = [WeatherReport getWeatherSummaryForLocation:myLocation];
    if (result && [result respondsToSelector:@selector(objectForKey:)])
    {
      location = [result objectForKey:@"location"];
      summary = [result objectForKey:@"summary"];
    }
  } thenRunInFG:^()
  {
    [self stopWaitingWithSummary:summary andlocation:location];
    if (returnBlock)
      returnBlock();
  }];
}

- (void) retrieveAndPopulateForCurrentLocationWithReturnBlock:(void (^)()) finishBlock
                                                 andInitBlock:(void (^) (LocationFetcher* lf)) initBlock
{
  [self startWaiting];

  LocationFetcher* lf = [[LocationFetcher alloc] initWithSuccessBlock:^(CLLocation* myLocation)
  {
    NSLog(@"GOT LOCATION: %@", myLocation);
    [self retrieveAndPopulateForLocation:myLocation onFinish:finishBlock];
  } andFailBlock:^(NSError* error)
  {
    NSLog(@"FAILED TO GET LOCATION WITH ERROR: %@", error);
    NSString* message = @"Failed to Get Your Location";

    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];

    if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied)
    {
      message = @"Please enable location services for this app";
    }

    [self stopWaitingWithSummary:@"Error" andlocation:@"Error"];

    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];

    if (finishBlock)
    {
      finishBlock();
    }
  }];

  if (initBlock)
  {
    initBlock(lf);
  }

  [lf startLookup];
}

@end
