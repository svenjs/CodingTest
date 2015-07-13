//
//  WeatherReport.h
//  wpweather
//
//  Created by Sven-Jesko Strala on 13/07/15 W29.
//  Copyright (c) 2015 Westpac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreLocation/Corelocation.h"

@interface WeatherReport : NSObject

+(NSURL*) getURLForLocation:(CLLocation*) thisLocation;
+(NSDictionary*) getWeatherSummaryForLocation:(CLLocation*) thisLocation;

@end
