//
//  LocationFetcher.m
//  wpweather
//
//  Created by Sven-Jesko Strala on 13/07/15 W29.
//  Copyright (c) 2015 Westpac. All rights reserved.
//

#import "LocationFetcher.h"
#import "Util.h"

@implementation LocationFetcher
{
  CLLocationManager* _locationManager;
  LocationBlock _successBlock;
  ErrorBlock _failureBlock;
  BOOL isTestModeEnabled;
}

- (id) initWithSuccessBlock:(LocationBlock) successBlock
               andFailBlock:(ErrorBlock) failureBlock
{
  if (self = [super init])
  {
    NSAssert(successBlock != nil, @"Success block is required");
    NSAssert(failureBlock != nil, @"Failure block is required");

    self.testLookupDelay = 2; // default to 2 seconds

    _successBlock = successBlock;
    _failureBlock = failureBlock;
  }
  return self;
}

+ (BOOL) isGPSRestrictedOrDenied
{
  CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
  return status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied;
}

- (void) startLookup
{
  if (self.testOverrideError || self.testOverrideLocation)
  {
    [Util runInBG:^()
     {
       sleep(self.testLookupDelay);
     } thenRunInFG:^()
     {
       if (self.testOverrideError)
       {
         _failureBlock(self.testOverrideError);
       }
       else
       {
         _successBlock(self.testOverrideLocation);
       }
     }];
  }
  else
  {
    if (_locationManager != nil)
    {
      NSLog(@"Error: Location manager still running");
      return;
    }
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;

    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
      [_locationManager requestWhenInUseAuthorization];
    }
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
  }
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError*) error
{
  [_locationManager stopUpdatingLocation];
  _locationManager = nil;
  _failureBlock(error);
}

- (void) locationManager:(CLLocationManager*) manager
     didUpdateToLocation:(CLLocation*) newLocation
            fromLocation:(CLLocation*) oldLocation
{
  if (newLocation != nil)
  {
    [_locationManager stopUpdatingLocation];
    _locationManager = nil;
    _successBlock(newLocation);
  }
}

@end
