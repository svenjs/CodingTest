//
//  wpweatherTests.m
//  wpweatherTests
//
//  Created by Sven-Jesko Strala on 13/07/15 W29.
//  Copyright (c) 2015 Westpac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ViewController.h"
#import "Util.h"
#import "WeatherReport.h"

@interface wpweatherTests : XCTestCase
@property (nonatomic, strong) ViewController *vc;
@end

@implementation wpweatherTests

- (void) setUp
{
    [super setUp];
  
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.vc = [storyboard instantiateViewControllerWithIdentifier:@"WeatherReportVC"];
    [self.vc performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
  
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void) tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.vc = nil;
    [super tearDown];
}

- (void) testExample
{
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void) testPerformanceExample
{
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

#pragma mark - View loading tests
- (void) testThatViewLoads
{
  XCTAssertNotNil(self.vc.view, @"View not initiated properly");
}

- (void) testWeatherReportHasAllUIElements
{
  NSArray *subviews = self.vc.view.subviews;
  XCTAssertTrue([subviews containsObject:self.vc.lblWeatherSummary], @"View does not have summary label");
  XCTAssertTrue([subviews containsObject:self.vc.lblLastTimeChecked], @"View does not have last-time label");
  XCTAssertTrue([subviews containsObject:self.vc.lblLocation], @"View does not have location label");
  XCTAssertTrue([subviews containsObject:self.vc.lblLocation], @"View does not have location label");
  XCTAssertTrue([subviews containsObject:self.vc.lblLocation], @"View does not have location label");
  XCTAssertTrue([subviews containsObject:self.vc.btnRefresh], @"View does not have refresh button");
}

- (void) testWeatherReportUIElementsDidLoad
{
  XCTAssertNotNil(self.vc.btnRefresh, @"Refresh button not initiated");
  XCTAssertNotNil(self.vc.lblWeatherSummary, @"Weather Summary label not initiated");
  XCTAssertNotNil(self.vc.lblLastTimeChecked, @"Last-time label not initiated");
  XCTAssertNotNil(self.vc.lblLocation, @"Location label not initiated");
  XCTAssertNotNil(self.vc.aivSpinner, @"Spinner not initiated");
}

- (void) testStartWaiting
{
  [self.vc performSelectorOnMainThread:@selector(startWaiting) withObject:nil waitUntilDone:YES];
  XCTAssertTrue(self.vc.aivSpinner.isAnimating);
  XCTAssertFalse(self.vc.btnRefresh.enabled);
  XCTAssertEqualObjects(self.vc.lblLastTimeChecked.text, @"--loading--");
  XCTAssertEqualObjects(self.vc.lblLocation.text, @"--loading--");
  XCTAssertEqualObjects(self.vc.lblWeatherSummary.text, @"--loading--");
}

- (void) finishWithDummyData:(NSArray*) parameters
{
  if (parameters.count != 2)
  {
    XCTFail(@"Two Parameters expected");
    return;
  }
  [self.vc stopWaitingWithSummary:[parameters objectAtIndex:0] andlocation:[parameters objectAtIndex:1]];
}

- (void) testStopWaitingWithDummyResult
{
  NSString* dummySummary = [Util randomStringWithLength:10];
  NSString* dummyLocation = [Util randomStringWithLength:10];

  [self performSelectorOnMainThread:@selector(finishWithDummyData:)
                         withObject:@[dummySummary, dummyLocation]
                      waitUntilDone:YES];

  XCTAssertFalse(self.vc.aivSpinner.isAnimating);
  XCTAssertTrue(self.vc.btnRefresh.enabled);
  XCTAssertEqualObjects(self.vc.lblWeatherSummary.text, dummySummary);
  XCTAssertEqualObjects(self.vc.lblLocation.text, dummyLocation);

  // test if last-checked contains a valid date string
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
  [dateFormatter setDateFormat:@"dd.MM.YY HH:mm:ss"];
  NSDate* lastTimeCheckDate = [dateFormatter dateFromString:self.vc.lblLastTimeChecked.text];
  XCTAssertNotNil(lastTimeCheckDate);

  // should be in the past and a valid date
  XCTAssertTrue([Util isThisDateBeforeNow:lastTimeCheckDate]);
}

// utilities
- (void) testStringForURL
{
  NSString* nonNilResult = [Util stringFromURL:[NSURL URLWithString:@"http://www.google.com"]];
  XCTAssertNotNil(nonNilResult);
  XCTAssertTrue([nonNilResult respondsToSelector:@selector(substringFromIndex:)]);
  XCTAssertTrue([nonNilResult respondsToSelector:@selector(length)]);
  XCTAssertGreaterThan(nonNilResult.length, 0);
  XCTAssertNil([Util stringFromURL:[NSURL URLWithString:@"https://css-tricks.com/thispagedoesntexist"]]);
}

- (void) testDictForJSONString
{
  NSString* validJSON = @"{\"TEST\":123, \"TEST2\":\"SOMESTRING\"}";
  NSString* nilJSON = @"{}";
  NSString* brokenJSON = @"{\"TEST\":";
  NSString* brokenJSON2 = @"{\"TEST\":123,@\"TEST2";

  NSDictionary* validJSONDict = [Util dictFromJSONString:validJSON];

  XCTAssertNotNil(validJSONDict);
  XCTAssertEqualObjects([validJSONDict objectForKey:@"TEST"], @123);
  XCTAssertEqualObjects([validJSONDict objectForKey:@"TEST2"], @"SOMESTRING");
  XCTAssertNotNil([Util dictFromJSONString:nilJSON]);
  XCTAssertNil([Util dictFromJSONString:brokenJSON]);
  XCTAssertNil([Util dictFromJSONString:brokenJSON2]);
  XCTAssertNil([Util dictFromJSONString:nil]);
}

// Weather-reporter

- (void) checkWeatherAtLocation:(CLLocation*) thisLocation expectTimezone:(NSString*) timeZone
{
  XCTAssertNotNil(thisLocation);
  NSDictionary* result = [WeatherReport getWeatherSummaryForLocation:thisLocation];
  XCTAssertNotNil(result);
  NSString* location = [result objectForKey:@"location"];
  NSString* summary = [result objectForKey:@"summary"];
  XCTAssertNotNil(location);
  XCTAssertEqualObjects(location, timeZone);
  XCTAssertNotNil(summary);
  XCTAssertGreaterThan(summary.length, 0);
}

- (CLLocation*) testLocationWithName:(NSString*) name
{
  NSDictionary* locs =
  @{@"sydney":[[CLLocation alloc] initWithLatitude:-31 longitude:151],
    @"canberra":[[CLLocation alloc] initWithLatitude:-35.3075 longitude:149.124417],
    @"darwin":[[CLLocation alloc] initWithLatitude:-12.45 longitude:130.833333],
    @"perth":[[CLLocation alloc] initWithLatitude:-31.952222 longitude:115.858889],
    @"center":[[CLLocation alloc] initWithLatitude:0 longitude:0],
    @"invalid":[[CLLocation alloc] initWithLatitude:999 longitude:999]};

  return [locs objectForKey:name];
}

-(void) testWeatherReportHeadless
{
  NSDictionary* locs =
  @{@"sydney":[[CLLocation alloc] initWithLatitude:-31 longitude:151],
    @"canberra":[[CLLocation alloc] initWithLatitude:-35.3075 longitude:149.124417],
    @"darwin":[[CLLocation alloc] initWithLatitude:-12.45 longitude:130.833333],
    @"perth":[[CLLocation alloc] initWithLatitude:-31.952222 longitude:115.858889],
    @"center":[[CLLocation alloc] initWithLatitude:0 longitude:0]};

  [self checkWeatherAtLocation:[locs objectForKey:@"sydney"] expectTimezone:@"Australia/Sydney"];
  [self checkWeatherAtLocation:[locs objectForKey:@"canberra"] expectTimezone:@"Australia/Sydney"];
  [self checkWeatherAtLocation:[locs objectForKey:@"darwin"] expectTimezone:@"Australia/Darwin"];
  [self checkWeatherAtLocation:[locs objectForKey:@"perth"] expectTimezone:@"Australia/Perth"];
  [self checkWeatherAtLocation:[locs objectForKey:@"center"] expectTimezone:@"Etc/GMT"];

  XCTAssertNil([WeatherReport getWeatherSummaryForLocation:[[CLLocation alloc] initWithLatitude:999 longitude:999]]);
  XCTAssertNil([WeatherReport getWeatherSummaryForLocation:nil]);
}

- (void) checkWeatherReportInVCWithLocationAndExpectedTimezone:(NSArray*) locAndTimezone
{
  XCTAssertGreaterThanOrEqual(locAndTimezone.count, 2, @"Expecting two fields: Location and expected timezone");

  NSString* location = [locAndTimezone objectAtIndex:0];
  NSString* expectedTimezone = [locAndTimezone objectAtIndex:1];

  XCTestExpectation *expectation = [self expectationWithDescription:@"Return of weather-lookup"];

  [self.vc retrieveAndPopulateForLocation:[self testLocationWithName:location] onFinish:^()
   {
     XCTAssertFalse(self.vc.aivSpinner.isAnimating);
     XCTAssertTrue(self.vc.btnRefresh.enabled);
     XCTAssertGreaterThan(self.vc.lblWeatherSummary.text.length, 0);
     XCTAssertEqualObjects(self.vc.lblLocation.text, expectedTimezone);

     // test if last-checked contains a valid date string
     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
     [dateFormatter setDateFormat:@"dd.MM.YY HH:mm:ss"];
     NSDate* lastTimeCheckDate = [dateFormatter dateFromString:self.vc.lblLastTimeChecked.text];
     XCTAssertNotNil(lastTimeCheckDate);

     // should be in the past and a valid date
     XCTAssertTrue([Util isThisDateBeforeNow:lastTimeCheckDate]);

     [expectation fulfill];
   }];

  [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error)
  {
    if (error)
    {
      NSLog(@"Timeout Error: %@", error);
    }
  }];
}

- (void) testWeatherReportInVC
{
  [self checkWeatherReportInVCWithLocationAndExpectedTimezone:@[@"sydney",@"Australia/Sydney"]];
  [self checkWeatherReportInVCWithLocationAndExpectedTimezone:@[@"canberra",@"Australia/Sydney"]];
  [self checkWeatherReportInVCWithLocationAndExpectedTimezone:@[@"perth",@"Australia/Perth"]];
  [self checkWeatherReportInVCWithLocationAndExpectedTimezone:@[@"darwin",@"Australia/Darwin"]];
  [self checkWeatherReportInVCWithLocationAndExpectedTimezone:@[@"center",@"Etc/GMT"]];
  [self checkWeatherReportInVCWithLocationAndExpectedTimezone:@[@"invalid",@"Error"]];
  [self checkWeatherReportInVCWithLocationAndExpectedTimezone:@[[NSNull null],@"Error"]];
}

@end
