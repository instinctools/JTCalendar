//
//  JTCalendarDayView.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarDayView.h"

#import "JTCircleView.h"

@interface JTCalendarDayView () {
	UIView *backgroundView;
	JTCircleView *circleView;
	UILabel *textLabel;
	JTCircleView *dotView;

    UIImageView *startMonthView;
    UIImageView *endMonthView;
    
	BOOL isSelected;

	int cacheIsToday;
	NSString *cacheCurrentDateText;
}
@end

static NSString *const kJTCalendarDaySelected = @"kJTCalendarDaySelected";

@implementation JTCalendarDayView

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

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)commonInit {
	isSelected = NO;
	self.isOtherMonth = NO;

	{
		backgroundView = [UIView new];
		[self addSubview:backgroundView];
	}

    {
        startMonthView = [UIImageView new];
        [startMonthView setImage:[UIImage imageNamed:@"start_month_calendar"]];
        [self addSubview:startMonthView];
        startMonthView.hidden = YES;
    }
    
    {
        endMonthView = [UIImageView new];
        [endMonthView setImage:[UIImage imageNamed:@"end_month_calendar"]];
        [self addSubview:endMonthView];
        endMonthView.hidden = YES;
    }
    
	{
		circleView = [JTCircleView new];
		[self addSubview:circleView];
	}

	{
		textLabel = [UILabel new];
		[self addSubview:textLabel];
	}

	{
		dotView = [JTCircleView new];
		[self addSubview:dotView];
		dotView.hidden = YES;
	}

	{
		UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouch:)];

		self.userInteractionEnabled = YES;
		[self addGestureRecognizer:gesture];
	}

	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDaySelected:) name:kJTCalendarDaySelected object:nil];
	}
}

- (void)setTextColor:(UIColor *)textColor {
	textLabel.textColor = textColor;
}

-(void)setTextFont:(UIFont *)textFont
{
    textLabel.font = textFont;
}

- (void)layoutSubviews {
	[self configureConstraintsForSubviews];

	// No need to call [super layoutSubviews]
}

// Avoid to calcul constraints (very expensive)
- (void)configureConstraintsForSubviews {
	textLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	backgroundView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);


	CGFloat sizeCircle = MIN(self.frame.size.width, self.frame.size.height);
	CGFloat sizeDot = sizeCircle;

	sizeCircle = sizeCircle * self.calendarManager.calendarAppearance.dayCircleRatio;
	sizeDot = sizeDot * self.calendarManager.calendarAppearance.dayDotRatio;

	sizeCircle = roundf(sizeCircle);
	sizeDot = roundf(sizeDot);

	circleView.frame = CGRectMake(0, 0, sizeCircle, sizeCircle);
	circleView.center = CGPointMake(self.frame.size.width / 2., self.frame.size.height / 2.);
	circleView.layer.cornerRadius = sizeCircle / 2.;

    startMonthView.frame = circleView.frame;
    endMonthView.frame = circleView.frame;
    
    startMonthView.center = circleView.center;
    endMonthView.center = circleView.center;
    
	dotView.frame = CGRectMake(0, 0, sizeDot, sizeDot);
	dotView.center = CGPointMake(self.frame.size.width / 2., (self.frame.size.height / 2.) + sizeDot * 2.5);
	dotView.layer.cornerRadius = sizeDot / 2.;
}

- (void)setDate:(NSDate *)date {
	static NSDateFormatter *dateFormatter;
	if (!dateFormatter) {
		dateFormatter = [NSDateFormatter new];
		dateFormatter.timeZone = self.calendarManager.calendarAppearance.calendar.timeZone;
		[dateFormatter setDateFormat:self.calendarManager.calendarAppearance.dayFormat];
	}

	self->_date = date;

	textLabel.text = [dateFormatter stringFromDate:date];

	cacheIsToday = -1;
	cacheCurrentDateText = nil;
}

- (void)didTouch:(UITapGestureRecognizer *)recognizer {
	[self.delegate calendarDayViewDidBeginTouch:self];
	if ([self.calendarManager.dataSource respondsToSelector:@selector(calendar:canSelectDate:)]) {
		if (![self.calendarManager.dataSource calendar:self.calendarManager canSelectDate:self.date]) {
			return;
		}
	}

	[self setSelected:YES animated:YES];
	[self.calendarManager setCurrentDateSelected:self.date];

	[[NSNotificationCenter defaultCenter] postNotificationName:kJTCalendarDaySelected object:self.date];

	[self.calendarManager.dataSource calendarDidDateSelected:self.calendarManager date:self.date];

    if ([self.calendarManager.dataSource respondsToSelector:@selector(calendar:needsToNavigateToNextMonth:)] &&
        [self.calendarManager.dataSource respondsToSelector:@selector(calendar:needsToNavigateToPreviousMonth:)])
    {
        if ([self.calendarManager.dataSource calendar:self.calendarManager needsToNavigateToNextMonth:self.date]) {
            [self.calendarManager loadNextPage];
        } else if ([self.calendarManager.dataSource calendar:self.calendarManager needsToNavigateToPreviousMonth:self.date]) {
            [self.calendarManager loadPreviousPage];
        }
    } else {
        if (!self.isOtherMonth || !self.calendarManager.calendarAppearance.autoChangeMonth) {
            return;
        }
        
        NSInteger currentMonthIndex = [self monthIndexForDate:self.date];
        NSInteger calendarMonthIndex = [self monthIndexForDate:self.calendarManager.currentDate];
        
        currentMonthIndex = currentMonthIndex % 12;
        
        if (currentMonthIndex == (calendarMonthIndex + 1) % 12) {
            [self.calendarManager loadNextPage];
        } else if (currentMonthIndex == (calendarMonthIndex + 12 - 1) % 12) {
            [self.calendarManager loadPreviousPage];
        }
    }
}

- (void)didDaySelected:(NSNotification *)notification {
	NSDate *dateSelected = [notification object];

	if ([self isSameDate:dateSelected]) {
		if (!isSelected) {
			[self setSelected:YES animated:YES];
		}
	}
	else if (isSelected) {
		[self setSelected:NO animated:YES];
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	if (isSelected == selected) {
		animated = NO;
	}

	isSelected = selected;

	circleView.transform = CGAffineTransformIdentity;
	CGAffineTransform tr = CGAffineTransformIdentity;
	CGFloat opacity = 1.;

	if (selected) {
		if (!self.isOtherMonth) {
			circleView.color = [self.calendarManager.calendarAppearance dayCircleColorSelected];
			textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorSelected];
			dotView.color = [self.calendarManager.calendarAppearance dayDotColorSelected];
		}
		else {
			circleView.color = [self.calendarManager.calendarAppearance dayCircleColorSelectedOtherMonth];
			textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorSelectedOtherMonth];
			dotView.color = [self.calendarManager.calendarAppearance dayDotColorSelectedOtherMonth];
		}
		circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
		tr = CGAffineTransformIdentity;
	}
	else if ([self isToday]) {
		if (!self.isOtherMonth) {
			circleView.color = [self.calendarManager.calendarAppearance dayCircleColorToday];
			textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorToday];
			dotView.color = [self.calendarManager.calendarAppearance dayDotColorToday];
		}
		else {
			circleView.color = [self.calendarManager.calendarAppearance dayCircleColorTodayOtherMonth];
			textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorTodayOtherMonth];
			dotView.color = [self.calendarManager.calendarAppearance dayDotColorTodayOtherMonth];
		}
	}
	else {
		if (!self.isOtherMonth) {
			textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColor];
			dotView.color = [self.calendarManager.calendarAppearance dayDotColor];
		}
		else {
			textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorOtherMonth];
			dotView.color = [self.calendarManager.calendarAppearance dayDotColorOtherMonth];
		}

		opacity = 0.;
	}

	if (animated) {
		[UIView animateWithDuration:.3 animations: ^{
		    circleView.layer.opacity = opacity;
		    circleView.transform = tr;
		}];
	}
	else {
		circleView.layer.opacity = opacity;
		circleView.transform = tr;
	}

    textLabel.font = self.calendarManager.calendarAppearance.dayTextFont;
	if (self.calendarManager.calendarAppearance.isSelectableFutureDays == NO && [self.date timeIntervalSinceNow] > 0) {
		textLabel.textColor = [UIColor lightGrayColor];
		self.userInteractionEnabled = NO;
	}
	else {
		self.userInteractionEnabled = YES;
	}
}

- (void)setIsOtherMonth:(BOOL)isOtherMonth {
	self->_isOtherMonth = isOtherMonth;
	[self setSelected:isSelected animated:NO];
}

- (void)reloadData {
	BOOL selected = [self isSameDate:[self.calendarManager currentDateSelected]];
	[self setSelected:selected animated:NO];
	dotView.hidden = ![self.calendarManager.dataCache haveEvent:self.date];
    startMonthView.hidden = ![self.calendarManager.dataCache startDate:self.date];
    endMonthView.hidden = ![self.calendarManager.dataCache endDate:self.date];
}

- (BOOL)isToday {
	if (cacheIsToday == 0) {
		return NO;
	}
	else if (cacheIsToday == 1) {
		return YES;
	}
	else {
		if ([self isSameDate:[NSDate date]]) {
			cacheIsToday = 1;
			return YES;
		}
		else {
			cacheIsToday = 0;
			return NO;
		}
	}
}

- (BOOL)isSameDate:(NSDate *)date {
	static NSDateFormatter *dateFormatter;
	if (!dateFormatter) {
		dateFormatter = [NSDateFormatter new];
		dateFormatter.timeZone = self.calendarManager.calendarAppearance.calendar.timeZone;
		[dateFormatter setDateFormat:@"dd-MM-yyyy"];
	}

	if (!cacheCurrentDateText) {
		cacheCurrentDateText = [dateFormatter stringFromDate:self.date];
	}

	NSString *dateText2 = [dateFormatter stringFromDate:date];

	if ([cacheCurrentDateText isEqualToString:dateText2]) {
		return YES;
	}

	return NO;
}

- (NSInteger)monthIndexForDate:(NSDate *)date {
	NSCalendar *calendar = self.calendarManager.calendarAppearance.calendar;
	NSDateComponents *comps = [calendar components:NSCalendarUnitMonth fromDate:date];
	return comps.month;
}

- (void)reloadAppearance {
	textLabel.textAlignment = NSTextAlignmentCenter;
	textLabel.font = self.calendarManager.calendarAppearance.dayTextFont;
	backgroundView.backgroundColor = self.calendarManager.calendarAppearance.dayBackgroundColor;
	backgroundView.layer.borderWidth = self.calendarManager.calendarAppearance.dayBorderWidth;
	backgroundView.layer.borderColor = self.calendarManager.calendarAppearance.dayBorderColor.CGColor;

	[self configureConstraintsForSubviews];
	[self setSelected:isSelected animated:NO];
}

@end
