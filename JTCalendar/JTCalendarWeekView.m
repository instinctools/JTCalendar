//
//  JTCalendarWeekView.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarWeekView.h"

#import "JTCalendarDayView.h"

@interface JTCalendarWeekView () <JTCalendarDayViewDelegate> {
	NSArray *daysViews;
};

@end

@implementation JTCalendarWeekView

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

- (void)commonInit {
	NSMutableArray *views = [NSMutableArray new];

	for (int i = 0; i < 7; ++i) {
		JTCalendarDayView *view = [JTCalendarDayView new];
		view.delegate = self;
		[views addObject:view];
		[self addSubview:view];
	}

	daysViews = views;
}

- (void)layoutSubviews {
	CGFloat x = 0;
	CGFloat width = self.frame.size.width / 7.;
	CGFloat height = self.frame.size.height;

	if (self.calendarManager.calendarAppearance.readFromRightToLeft) {
		for (UIView *view in[[self.subviews reverseObjectEnumerator] allObjects]) {
			view.frame = CGRectMake(x, 0, width, height);
			x = CGRectGetMaxX(view.frame);
		}
	}
	else {
		for (UIView *view in self.subviews) {
			view.frame = CGRectMake(x, 0, width, height);
			x = CGRectGetMaxX(view.frame);
		}
	}

	[super layoutSubviews];
}

- (void)setBeginningOfWeek:(NSDate *)date {
	NSDate *currentDate = date;

	NSCalendar *calendar = self.calendarManager.calendarAppearance.calendar;

	for (JTCalendarDayView *view in daysViews) {
		if (!self.calendarManager.calendarAppearance.isWeekMode) {
			NSDateComponents *comps = [calendar components:NSCalendarUnitMonth fromDate:currentDate];
			NSInteger monthIndex = comps.month;

			[view setIsOtherMonth:monthIndex != self.currentMonthIndex];
		}
		else {
			[view setIsOtherMonth:NO];
		}

		[view setDate:currentDate];

		NSDateComponents *dayComponent = [NSDateComponents new];
		dayComponent.day = 1;

		currentDate = [calendar dateByAddingComponents:dayComponent toDate:currentDate options:0];
	}
}

- (NSArray *)dates {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (JTCalendarDayView *view in daysViews) {
        [array addObject:view.date];
    }
    return array;
}
#pragma mark - JTCalendarManager

- (void)setCalendarManager:(JTCalendar *)calendarManager {
	self->_calendarManager = calendarManager;
	for (JTCalendarDayView *view in daysViews) {
		[view setCalendarManager:calendarManager];
	}
}

- (void)reloadData {
    self.isSelected = NO;
	for (JTCalendarDayView *view in daysViews) {
		[view reloadData];
	}
}

-(void)setIsSelected:(BOOL)isSelected
{
    self.backgroundColor = isSelected == YES ? self.calendarManager.calendarAppearance.highlightWeekColor : self.calendarManager.calendarAppearance.unhighlightWeekColor;
}

- (void)reloadAppearance {
	for (JTCalendarDayView *view in daysViews) {
		[view reloadAppearance];
	}
}

- (void)calendarDayViewDidBeginTouch:(JTCalendarDayView *)calendarDayView {
	[self.delegate calendarWeekView:self didBeginTouchCalendarDayView:calendarDayView];
}

-(void)calendarDayViewDidEndTouch:(JTCalendarDayView *)calendarDayView
{
    [self.delegate calendarWeekView:self didEndTouchCalendarDayView:calendarDayView];
}

@end
