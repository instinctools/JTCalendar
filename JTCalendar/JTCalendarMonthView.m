//
//  JTCalendarMonthView.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarMonthView.h"

#import "JTCalendarMonthWeekDaysView.h"
#import "JTCalendarWeekView.h"

#define WEEKS_TO_DISPLAY 8

@interface JTCalendarMonthView () <JTCalendarWeekViewDelegate> {
	JTCalendarMonthWeekDaysView *weekdaysView;
	NSArray *weeksViews;

	NSUInteger currentMonthIndex;
	BOOL cacheLastWeekMode; // Avoid some operations
};
@property (nonatomic, strong) NSDate *firstDayDate;
@end

@implementation JTCalendarMonthView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (!self) {
		return nil;
	}

	[self commonInit];

	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (!self) {
		return nil;
	}

	[self commonInit];

	return self;
}

- (void)setFirstDayDate:(NSDate *)firstDayDate {
	_firstDayDate = firstDayDate;
//	[self commonInit];
	[self reloadData];
}

- (NSUInteger)weeksCount {
	NSDate *date = self.firstDayDate;
	if (date == nil) {
		return 0;
	}
	NSCalendar *calender = self.calendarManager.calendarAppearance.calendar;
	NSRange days = [calender rangeOfUnit:NSDayCalendarUnit
	                              inUnit:NSMonthCalendarUnit
	                             forDate:date];
	NSDateComponents *comps = [calender components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit fromDate:date];
    //Not sure why, but setDay: for 31 create 30th day, so I just make this hack
	[comps setDay:days.length + 1];
	NSDate *lastDay = [calender dateFromComponents:comps];
	NSRange weekRange = [calender rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:lastDay];
	NSInteger weeksCount = weekRange.length;
	return weeksCount;
}

- (void)commonInit {
	for (UIView *subview in self.subviews) {
		[subview removeFromSuperview];
	}
	NSMutableArray *views = [NSMutableArray new];

	{
		weekdaysView = [JTCalendarMonthWeekDaysView new];
		[self addSubview:weekdaysView];
	}

	for (int i = 0; i < WEEKS_TO_DISPLAY; ++i) {
		JTCalendarWeekView *view = [JTCalendarWeekView new];
		view.delegate = self;
		[views addObject:view];
		[self addSubview:view];
	}

	weeksViews = views;

	cacheLastWeekMode = self.calendarManager.calendarAppearance.isWeekMode;
}

- (void)layoutSubviews {
	[self configureConstraintsForSubviews];

	[super layoutSubviews];
}

- (void)configureConstraintsForSubviews {
	CGFloat weeksToDisplay;

	if (cacheLastWeekMode) {
		weeksToDisplay = 2.;
	}
	else {
		weeksToDisplay = (CGFloat)([weeksViews count] + 1); // + 1 for weekDays
	}

	CGFloat y = 0;
	CGFloat width = self.frame.size.width;
	CGFloat height = self.frame.size.height / weeksToDisplay;

	for (int i = 0; i < self.subviews.count; ++i) {
		UIView *view = self.subviews[i];

		view.frame = CGRectMake(0, y, width, height);
		y = CGRectGetMaxY(view.frame);

		if (cacheLastWeekMode && i == weeksToDisplay - 1) {
			height = 0.;
		}
	}
}

- (void)setBeginningOfMonth:(NSDate *)date {
	NSDate *currentDate = date;
	self.firstDayDate = date;

	NSCalendar *calendar = self.calendarManager.calendarAppearance.calendar;

	{
		NSDateComponents *comps = [calendar components:NSCalendarUnitMonth | NSCalendarUnitDay fromDate:currentDate];

		currentMonthIndex = comps.month;

		// Hack
		if (comps.day > 7) {
			currentMonthIndex = (currentMonthIndex % 12) + 1;
		}
	}

    //for display previous week
    NSDateComponents *dayComponent = [NSDateComponents new];
    dayComponent.day = -7;
    currentDate = [calendar dateByAddingComponents:dayComponent toDate:currentDate options:0];
    
	for (NSUInteger i = 0; i < [weeksViews count]; i++) {
        JTCalendarWeekView *view = weeksViews[i];
        //hide if this week is not in current month
//		[view setHidden:i >= [self weeksCount]];
        
        view.currentMonthIndex = currentMonthIndex;
        [view setBeginningOfWeek:currentDate];
        
        NSDateComponents *dayComponent = [NSDateComponents new];
        dayComponent.day = 7;
        
        currentDate = [calendar dateByAddingComponents:dayComponent toDate:currentDate options:0];
        
        // Doesn't need to do other weeks
        if (self.calendarManager.calendarAppearance.isWeekMode) {
            break;
        }
	}
}

#pragma mark - JTCalendarManager

- (void)setCalendarManager:(JTCalendar *)calendarManager {
	self->_calendarManager = calendarManager;

	[weekdaysView setCalendarManager:calendarManager];
	for (JTCalendarWeekView *view in weeksViews) {
		[view setCalendarManager:calendarManager];
	}
}

- (void)reloadData {
	for (JTCalendarWeekView *view in weeksViews) {
		[view reloadData];
		if (self.calendarManager.selectedDate != nil) {
			unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
			NSCalendar *calendar = [NSCalendar currentCalendar];
			NSDateComponents *components = [calendar components:flags fromDate:self.calendarManager.selectedDate];
			NSDate *dateOnly = [calendar dateFromComponents:components];
			view.isSelected = [view.dates containsObject:dateOnly];
		}

		// Doesn't need to do other weeks
		if (self.calendarManager.calendarAppearance.isWeekMode) {
			break;
		}
	}
}

- (void)reloadAppearance {
	if (cacheLastWeekMode != self.calendarManager.calendarAppearance.isWeekMode) {
		cacheLastWeekMode = self.calendarManager.calendarAppearance.isWeekMode;
		[self configureConstraintsForSubviews];
	}

	[JTCalendarMonthWeekDaysView beforeReloadAppearance];
	[weekdaysView reloadAppearance];

	for (JTCalendarWeekView *view in weeksViews) {
		[view reloadAppearance];
	}
}

- (void)calendarWeekView:(JTCalendarWeekView *)calendarWeekView didBeginTouchCalendarDayView:(JTCalendarDayView *)calendarDayView {
	[self.delegate calendarMonthView:self didBeginTouchCalendarMonthView:calendarWeekView withCalendarDayView:calendarDayView];
}

- (void)calendarWeekView:(JTCalendarWeekView *)calendarWeekView didEndTouchCalendarDayView:(JTCalendarDayView *)calendarDayView {
	[self.delegate calendarMonthView:self didEndTouchCalendarMonthView:calendarWeekView withCalendarDayView:calendarDayView];
}

@end
