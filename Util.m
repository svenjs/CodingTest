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

@end
