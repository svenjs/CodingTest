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
  [self startWaiting];

  __block NSString* location;
  __block NSString* summary;

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
    if (location && summary)
    {
      [self stopWaitingWithSummary:summary andlocation:location];
      if (returnBlock)
        returnBlock();
    }
  }];
}

@end
