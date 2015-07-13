//
//  Util.m
//  wpweather
//
//  Created by Sven-Jesko Strala on 13/07/15 W29.
//  Copyright (c) 2015 Westpac. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (BOOL)isThisDateBeforeNow:(NSDate *)thisDate
{
  NSDate* enddate = thisDate;
  NSDate* currentdate = [NSDate date];
  NSTimeInterval distanceBetweenDates = [enddate timeIntervalSinceDate:currentdate];
  double secondsInMinute = 60;
  NSInteger secondsBetweenDates = distanceBetweenDates / secondsInMinute;

  if (secondsBetweenDates == 0)
    return YES;
  else if (secondsBetweenDates < 0)
    return YES;
  else
    return NO;
}

+(NSString *) randomStringWithLength:(int) len
{
  NSString *randomString = @"";
  for (int x=0; x < len; x++)
  {
    randomString = [randomString stringByAppendingFormat:@"%c", (char)(65 + (arc4random() % 25))];
  }
  return randomString;
}

+(NSDictionary*) dictFromJSONString:(NSString*) jsonString
{
  NSDictionary* json = nil;
  @try
  {
    NSError *jsonError;
    NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    json = [NSJSONSerialization JSONObjectWithData:objectData
                                           options:NSJSONReadingMutableContainers
                                             error:&jsonError];
  }
  @catch (NSException *exception)
  {
    NSLog(@"CAUGHT EXCEPTION: JSON: %@", [exception description]);
  }
  return json;
}

+ (NSString*) stringFromURL:(NSURL*) url
{
  NSURLRequest* request = [NSURLRequest requestWithURL:url];

  NSURLResponse *response;
  NSError *error;
  NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
  NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

  if(error)
  {
    NSLog(@"Error retrieving data: %@", [error localizedDescription]);
    return nil;
  }

  NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;

  if (httpResponse && [httpResponse respondsToSelector:@selector(statusCode)])
  {
    if (httpResponse.statusCode != 200)
    {
      return nil;
    }
  }

  return responseString;
}

@end
