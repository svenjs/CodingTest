//
//  ViewController.h
//  wpweather
//
//  Created by Sven-Jesko Strala on 13/07/15 W29.
//  Copyright (c) 2015 Westpac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocation/CoreLocation.h"
#import "LocationFetcher.h"

@interface ViewController : UIViewController

@property (nonatomic, assign) IBOutlet UILabel *lblWeatherSummary;
@property (nonatomic, assign) IBOutlet UILabel *lblLocation;
@property (nonatomic, assign) IBOutlet UILabel *lblLastTimeChecked;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *aivSpinner;
@property (nonatomic, assign) IBOutlet UIButton *btnRefresh;

@property (nonatomic, strong) LocationFetcher* lf;

// for testing

@property (copy) void (^blkInitLocationFetcher) (LocationFetcher* lf);
@property (copy) void (^blkFinishedLoadingWeather) (void);

// methods

- (void) startWaiting;
- (void) stopWaitingWithSummary:(NSString*) summaryString
                    andlocation:(NSString*) locationString;
- (void) retrieveAndPopulateForLocation:(CLLocation*) myLocation
                               onFinish:(void (^)()) returnBlock;
- (void) retrieveAndPopulateForCurrentLocationWithReturnBlock:(void (^)()) finishBlock
                                                 andInitBlock:(void (^) (LocationFetcher* lf)) initBlock;
- (void) retrieveAndPopulateForCurrentLocation;

- (IBAction)refreshButtonPressed:(id)sender;

@end

