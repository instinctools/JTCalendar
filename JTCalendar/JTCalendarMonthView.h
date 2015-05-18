//
//  JTCalendarMonthView.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import <UIKit/UIKit.h>

#import "JTCalendar.h"

@class JTCalendarMonthView;
@class JTCalendarWeekView;
@class JTCalendarDayView;

@protocol JTCalendarMonthViewDelegate <NSObject>
- (void)         calendarMonthView:(JTCalendarMonthView *)calendarMonthView
    didBeginTouchCalendarMonthView:(JTCalendarWeekView *)calendarWeekView
               withCalendarDayView:(JTCalendarDayView *)calendarDayView;
- (void)         calendarMonthView:(JTCalendarMonthView *)calendarMonthView
    didEndTouchCalendarMonthView:(JTCalendarWeekView *)calendarWeekView
               withCalendarDayView:(JTCalendarDayView *)calendarDayView;
@end
@interface JTCalendarMonthView : UIView

@property (weak, nonatomic) JTCalendar *calendarManager;
@property (nonatomic, weak) id <JTCalendarMonthViewDelegate> delegate;

- (void)setBeginningOfMonth:(NSDate *)date;
- (void)reloadData;
- (void)reloadAppearance;

@end
