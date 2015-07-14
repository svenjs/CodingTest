//
//  LocationFetcher.h
//  wpweather
//
//  Created by Sven-Jesko Strala on 13/07/15 W29.
//  Copyright (c) 2015 Westpac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreLocation/CoreLocation.h"

typedef void (^LocationBlock)(CLLocation* thisLocation);
typedef void (^ErrorBlock) (NSError* error);

@interface LocationFetcher : NSObject <CLLocationManagerDelegate>

@property (nonatomic) NSError* testOverrideError;
@property (nonatomic) CLLocation* testOverrideLocation;
@property (nonatomic, assign) int testLookupDelay;

- (id) initWithSuccessBlock:(LocationBlock) successBlock
               andFailBlock:(ErrorBlock) failureBlock;
- (void) startLookup;

+ (BOOL) isGPSRestrictedOrDenied;

@end
