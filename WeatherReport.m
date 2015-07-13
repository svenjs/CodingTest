//
//  WeatherReport.m
//  wpweather
//
//  Created by Sven-Jesko Strala on 13/07/15 W29.
//  Copyright (c) 2015 Westpac. All rights reserved.
//

#import "WeatherReport.h"
#import "Util.h"

#define apiKey @"220d2283e1ce1e0cfa550555557b52fd"

@implementation WeatherReport

+(NSURL*) getURLForLocation:(CLLocation*) thisLocation
{
  return [NSURL URLWithString:
          [NSString stringWithFormat:@"https://api.forecast.io/forecast/%@/%.6f,%.6f",
           apiKey, thisLocation.coordinate.latitude, thisLocation.coordinate.longitude]];
}

// Return Location and Summary from Dictionary returns
+(NSDictionary*) getWeatherSummaryForLocation:(CLLocation*) thisLocation
{
  if (thisLocation == nil)
  {
    NSLog(@"Error: Location is nil");
    return nil;
  }

  NSString* responseString = [Util stringFromURL:[self getURLForLocation:thisLocation]];

  if (responseString == nil)
  {
    NSLog(@"Error: Response is nil");
    return nil;
  }

  NSDictionary *json = [Util dictFromJSONString:responseString];

  if (json == nil)
  {
    NSLog(@"Error: Could not parse JSON");
    return nil;
  }

  NSString* weatherString = @"N/A";
  NSString* locationString = @"N/A";

  NSDictionary* currently = [NSDictionary dictionaryWithDictionary:[json objectForKey:@"currently"]];
  if ([currently respondsToSelector:@selector(objectForKey:)])
  {
    weatherString = [currently objectForKey:@"summary"];
  }

  NSString* location = [json objectForKey:@"timezone"];
  if ([location respondsToSelector:@selector(substringFromIndex:)])
  {
    locationString = location;
  }

  if (weatherString && locationString && [weatherString respondsToSelector:@selector(length)] && [locationString respondsToSelector:@selector(length)] && weatherString.length > 0 && locationString.length > 0)
  {
    return @{@"summary":weatherString, @"location":locationString};
  }

  NSLog(@"Error: %@", json);
  return nil;
}

@end
