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
{
  BOOL isWeatherQueryRunning;
}

- (void) viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  isWeatherQueryRunning = NO;
  [self retrieveAndPopulateForCurrentLocation];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(retrieveAndPopulateForCurrentLocation)
                                               name:UIApplicationWillEnterForegroundNotification
                                             object:nil];
}

- (IBAction)refreshButtonPressed:(id)sender
{
  [self retrieveAndPopulateForCurrentLocation];
}

- (void) didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void) startWaiting
{
  // flag
  isWeatherQueryRunning = YES;
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
  // flag
  isWeatherQueryRunning = NO;
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

- (void) retrieveAndPopulateForCurrentLocation
{
  [self retrieveAndPopulateForCurrentLocationWithReturnBlock:self.blkFinishedLoadingWeather
                                                andInitBlock:self.blkInitLocationFetcher];
}

- (void) retrieveAndPopulateForCurrentLocationWithReturnBlock:(void (^)()) finishBlock
                                                 andInitBlock:(void (^) (LocationFetcher* lf)) initBlock
{
  if (isWeatherQueryRunning)
  {
    [Util showMessage:@"Query in process"];
    return;
  }
  [self startWaiting];

  self.lf = [[LocationFetcher alloc] initWithSuccessBlock:^(CLLocation* myLocation)
  {
    NSLog(@"GOT LOCATION: %@", myLocation);
    [self retrieveAndPopulateForLocation:myLocation onFinish:finishBlock];
  } andFailBlock:^(NSError* error)
  {
    NSLog(@"FAILED TO GET LOCATION WITH ERROR: %@", [error localizedDescription]);
    
    [self stopWaitingWithSummary:@"Error" andlocation:@"Error"];
    
    if ([LocationFetcher isGPSRestrictedOrDenied])
    {
      [Util showMessage:@"Please enable location services for this app"];
    }
    
    if (finishBlock)
    {
      finishBlock();
    }
  }];

  if (initBlock)
  {
    initBlock(self.lf);
  }

  [self.lf startLookup];
}

@end
