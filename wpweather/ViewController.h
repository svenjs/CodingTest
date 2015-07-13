//
//  ViewController.h
//  wpweather
//
//  Created by Sven-Jesko Strala on 13/07/15 W29.
//  Copyright (c) 2015 Westpac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, assign) IBOutlet UILabel *lblWeatherSummary;
@property (nonatomic, assign) IBOutlet UILabel *lblLocation;
@property (nonatomic, assign) IBOutlet UILabel *lblLastTimeChecked;
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView *aivSpinner;
@property (nonatomic, assign) IBOutlet UIButton *btnRefresh;

- (void) startWaiting;
- (void) stopWaitingWithSummary:(NSString*) summaryString
                    andlocation:(NSString*) locationString;

@end

