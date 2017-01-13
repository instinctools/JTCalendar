//
//  JTCalendarDataCache.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import <UIKit/UIKit.h>

@class JTCalendar;

@interface JTCalendarDataCache : NSObject

@property (weak, nonatomic) JTCalendar *calendarManager;

- (void)reloadData;
- (BOOL)haveEvent:(NSDate *)date;

- (BOOL)startDate:(NSDate *)date;
- (BOOL)endDate:(NSDate *)date;

@end
