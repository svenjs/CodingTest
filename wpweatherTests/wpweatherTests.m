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

@interface wpweatherTests : XCTestCase
@property (nonatomic, strong) ViewController *vc;
@end

@implementation wpweatherTests

- (void)setUp {
    [super setUp];
  
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.vc = [storyboard instantiateViewControllerWithIdentifier:@"WeatherReportVC"];
    [self.vc performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
  
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.vc = nil;
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

#pragma mark - View loading tests
-(void)testThatViewLoads
{
  XCTAssertNotNil(self.vc.view, @"View not initiated properly");
}

- (void)testWeatherReportHasAllUIElements
{
  NSArray *subviews = self.vc.view.subviews;
  XCTAssertTrue([subviews containsObject:self.vc.lblWeatherSummary], @"View does not have summary label");
  XCTAssertTrue([subviews containsObject:self.vc.lblLastTimeChecked], @"View does not have last-time label");
  XCTAssertTrue([subviews containsObject:self.vc.lblLocation], @"View does not have location label");
  XCTAssertTrue([subviews containsObject:self.vc.lblLocation], @"View does not have location label");
  XCTAssertTrue([subviews containsObject:self.vc.lblLocation], @"View does not have location label");
  XCTAssertTrue([subviews containsObject:self.vc.btnRefresh], @"View does not have refresh button");
}

-(void)testWeatherReportUIElementsDidLoad
{
  XCTAssertNotNil(self.vc.btnRefresh, @"Refresh button not initiated");
  XCTAssertNotNil(self.vc.lblWeatherSummary, @"Weather Summary label not initiated");
  XCTAssertNotNil(self.vc.lblLastTimeChecked, @"Last-time label not initiated");
  XCTAssertNotNil(self.vc.lblLocation, @"Location label not initiated");
  XCTAssertNotNil(self.vc.aivSpinner, @"Spinner not initiated");
}

-(void) testStartWaiting
{
  [self.vc performSelectorOnMainThread:@selector(startWaiting) withObject:nil waitUntilDone:YES];
  XCTAssertTrue(self.vc.aivSpinner.isAnimating);
  XCTAssertFalse(self.vc.btnRefresh.enabled);
  XCTAssertEqualObjects(self.vc.lblLastTimeChecked.text, @"--loading--");
  XCTAssertEqualObjects(self.vc.lblLocation.text, @"--loading--");
  XCTAssertEqualObjects(self.vc.lblWeatherSummary.text, @"--loading--");
}

-(void) finishWithDummyData:(NSArray*) parameters
{
  if (parameters.count != 2)
  {
    XCTFail(@"Two Parameters expected");
    return;
  }
  [self.vc stopWaitingWithSummary:[parameters objectAtIndex:0] andlocation:[parameters objectAtIndex:1]];
}

-(void) testStopWaitingWithDummyResult
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

@end
