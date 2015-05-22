//
//  JTCalendarDayView.h
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import <UIKit/UIKit.h>

#import "JTCalendar.h"

@class JTCalendarDayView;

@protocol JTCalendarDayViewDelegate <NSObject>
- (void)calendarDayViewDidBeginTouch:(JTCalendarDayView *)calendarDayView;
- (void)calendarDayViewDidEndTouch:(JTCalendarDayView *)calendarDayView;
@end
@interface JTCalendarDayView : UIView

@property (weak, nonatomic) JTCalendar *calendarManager;
@property (nonatomic, weak) id <JTCalendarDayViewDelegate> delegate;
@property (nonatomic) NSDate *date;
@property (assign, nonatomic) BOOL isOtherMonth;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIColor *textColor;

- (void)reloadData;
- (void)reloadAppearance;

@end
