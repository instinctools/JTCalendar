//
//  JTCalendarDataSource.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import <Foundation/Foundation.h>

@class JTCalendar;

@protocol JTCalendarDataSource <NSObject>

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date;
- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date;

@optional

- (BOOL)calendar:(JTCalendar *)calendar isBeginMonthDate:(NSDate *)date;
- (BOOL)calendar:(JTCalendar *)calendar isEndMonthDate:(NSDate *)date;

- (BOOL)calendar:(JTCalendar *)calendar canSelectDate:(NSDate *)date;

- (BOOL)calendar:(JTCalendar *)calendar needsToNavigateToNextMonth:(NSDate *)date;
- (BOOL)calendar:(JTCalendar *)calendar needsToNavigateToPreviousMonth:(NSDate *)date;

- (void)calendarDidLoadPreviousPage;
- (void)calendarDidLoadNextPage;

- (void)calendarWillLoadPreviousPage;
- (void)calendarWillLoadNextPage;

@end
