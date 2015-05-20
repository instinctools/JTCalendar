//
//  JTCalendarWeekView.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import <UIKit/UIKit.h>

#import "JTCalendar.h"

@class JTCalendarWeekView;
@class JTCalendarDayView;

@protocol JTCalendarWeekViewDelegate <NSObject>

- (void)calendarWeekView:(JTCalendarWeekView *)calendarWeekView didBeginTouchCalendarDayView:(JTCalendarDayView *)calendarDayView;
- (void)calendarWeekView:(JTCalendarWeekView *)calendarWeekView didEndTouchCalendarDayView:(JTCalendarDayView *)calendarDayView;

@end
@interface JTCalendarWeekView : UIView

@property (weak, nonatomic) JTCalendar *calendarManager;
@property (nonatomic, weak) id <JTCalendarWeekViewDelegate> delegate;
@property (assign, nonatomic) NSUInteger currentMonthIndex;
@property (nonatomic) BOOL isSelected;

- (void)setBeginningOfWeek:(NSDate *)date;
- (void)reloadData;
- (void)reloadAppearance;
- (NSArray *)dates;
@end
