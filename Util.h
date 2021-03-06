//
//  Util.h
//  wpweather
//
//  Created by Sven-Jesko Strala on 13/07/15 W29.
//  Copyright (c) 2015 Westpac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Util : NSObject

+ (BOOL) isThisDateBeforeNow:(NSDate*) thisDate;
+ (NSString*) randomStringWithLength:(int) len;
+ (NSString*) stringFromURL:(NSURL*) thisUrlString;
+ (NSDictionary*) dictFromJSONString:(NSString*) jsonString;
+ (void) runInBG:(void (^)()) bgBlock
     thenRunInFG:(void (^)()) fgBlock;
+(void) showMessage:(NSString*) msg withTitle:(NSString*) title;
+(void) showMessage:(NSString*) msg;
@end
