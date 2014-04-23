//
//  ASWeekSelectorView.m
//  TripGo
//
//  Created by Adrian Schoenig on 15/04/2014.
//
//

#import "ASWeekSelectorView.h"

#import "ASSingleWeekView.h"
#import "ASDaySelectionView.h"

#define WEEKS 3

@interface ASWeekSelectorView () <ASSingleWeekViewDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *singleWeekViews;
@property (nonatomic, weak) ASDaySelectionView *selectionView;
@property (nonatomic, weak) UILabel *selectionLabel;
@property (nonatomic, weak) UIView *lineView;

@property (nonatomic, strong) NSDateFormatter *dayNameDateFormatter;
@property (nonatomic, strong) NSDateFormatter *dayNumberDateFormatter;
@property (nonatomic, strong) NSCalendar *gregorian;

// formatting
@property (nonatomic, strong) UIColor *selectorLetterTextColor;
@property (nonatomic, strong) UIColor *selectorBackgroundColor;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIColor *numberTextColor;
@property (nonatomic, strong) UIColor *letterTextColor;

@end

@implementation ASWeekSelectorView

#pragma mark - Public methods

- (void)setFirstWeekday:(NSUInteger)firstWeekday
{
  _firstWeekday = firstWeekday;
  
  [self rebuildWeeks];
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
  [self setSelectedDate:selectedDate animated:NO];
}


- (void)setSelectedDate:(NSDate *)selectedDate animated:(BOOL)animated
{
  if (! [self date:selectedDate matchesDateComponentsOfDate:_selectedDate]) {
    _selectedDate = selectedDate;

    [UIView animateWithDuration:animated ? 0.25f : 0
                     animations:
     ^{
       [self rebuildWeeks];
     }];
  }
}

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self didInit];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self didInit];
  }
  return self;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  self.selectionLabel.alpha = 1;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  if (scrollView.isTracking) {
    self.selectionLabel.alpha = 0;
  }
  
  CGPoint offset = scrollView.contentOffset;
  BOOL updatedOffset = NO;

  // prevent horizontal scrolling
  if (offset.y != 0) {
    offset.y = 0;
    updatedOffset = YES;
  }
  
  CGFloat width = CGRectGetWidth(scrollView.frame);
  if (offset.x >= width * 2 || offset.x <= 0) {
    // swap things around
    ASSingleWeekView *week0 = self.singleWeekViews[0];
    ASSingleWeekView *week1 = self.singleWeekViews[1];
    ASSingleWeekView *week2 = self.singleWeekViews[2];
    CGRect leftFrame    = week0.frame;
    CGRect middleFrame  = week1.frame;
    CGRect rightFrame   = week2.frame;
    
    if (offset.x <= 0) {
      // 0 and 1 move right
      week0.frame = middleFrame;
      week1.frame = rightFrame;
      self.singleWeekViews[1] = week0;
      self.singleWeekViews[2] = week1;
      
      // 2 get's updated to -1
      week2.startDate = [self dateByAddingDays:-7 toDate:week0.startDate];
      week2.frame = leftFrame;
      self.singleWeekViews[0] = week2;
      
      // update selected date
      [self userSelectedDate:[self dateByAddingDays:-7 toDate:self.selectedDate]];
      
    } else {
      // 1 and 2 move to the left
      week1.frame = leftFrame;
      week2.frame = middleFrame;
      self.singleWeekViews[0] = week1;
      self.singleWeekViews[1] = week2;

      // 0 get's updated to 3
      week0.startDate = [self dateByAddingDays:7 toDate:week2.startDate];
      week0.frame = rightFrame;
      self.singleWeekViews[2] = week0;

      // update selected date
      [self userSelectedDate:[self dateByAddingDays:7 toDate:self.selectedDate]];
    }
    
    // reset offset
    offset.x = width;
    updatedOffset = YES;
  }
  
  if (updatedOffset) {
    scrollView.contentOffset = offset;
  }
}

#pragma mark - ASSingleWeekViewDelegate

- (UIView *)singleWeekView:(ASSingleWeekView *)singleWeekView viewForDate:(NSDate *)date withFrame:(CGRect)frame
{
  BOOL isSelection = [self date:date matchesDateComponentsOfDate:self.selectedDate];
  if (isSelection) {
    self.selectionView.frame = frame;
  }
  
  UIView *wrapper = [[UIView alloc] initWithFrame:frame];
  CGFloat width = CGRectGetWidth(frame);

  CGFloat nameHeight = 20;
  CGFloat topPadding = 10;
  CGRect nameFrame = CGRectMake(0, topPadding, width, nameHeight - topPadding);
  UILabel *letterLabel = [[UILabel alloc] initWithFrame:nameFrame];
  letterLabel.textAlignment = NSTextAlignmentCenter;
  letterLabel.font = [UIFont systemFontOfSize:9];
  letterLabel.textColor = self.letterTextColor;
  letterLabel.text = [[self.dayNameDateFormatter stringFromDate:date] uppercaseString];
  [wrapper addSubview:letterLabel];

  CGRect numberFrame = CGRectMake(0, nameHeight, width, CGRectGetHeight(frame) - nameHeight);
  UILabel *numberLabel = [[UILabel alloc] initWithFrame:numberFrame];
  numberLabel.textAlignment = NSTextAlignmentCenter;
  numberLabel.font = [UIFont systemFontOfSize:18];
  numberLabel.textColor = self.numberTextColor;
  numberLabel.text = [self.dayNumberDateFormatter stringFromDate:date];
  if (isSelection) {
    CGRect selectionLabelFrame = numberFrame;
    selectionLabelFrame.origin.x = frame.origin.x;
    self.selectionLabel.frame = selectionLabelFrame;
    self.selectionLabel.text = numberLabel.text;
  }
  [wrapper addSubview:numberLabel];
  
  UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(frame) - 1, 0, 1, CGRectGetHeight(frame))];
  lineView.backgroundColor = self.lineColor;
  [wrapper addSubview:lineView];
  
  return wrapper;
}

- (void)singleWeekView:(ASSingleWeekView *)singleWeekView didSelectDate:(NSDate *)date atFrame:(CGRect)frame
{
  self.selectionLabel.alpha = 0;
  CGRect selectionLabelFrame = self.selectionLabel.frame;
  selectionLabelFrame.origin.x = frame.origin.x;
  self.selectionLabel.frame = selectionLabelFrame;

  
  [UIView animateWithDuration:0.25f
                   animations:
   ^{
     self.selectionView.frame = frame;
   }
                   completion:
   ^(BOOL finished) {
     [self userSelectedDate:date];
   }];
}

#pragma mark - Private helpers

- (void)didInit
{
  // default styles
  _letterTextColor = [UIColor colorWithWhite:204.f/255 alpha:1];
  _numberTextColor = [UIColor colorWithWhite:77.f/255 alpha:1];
  _lineColor = [UIColor colorWithWhite:245.f/255 alpha:1];
  _selectorBackgroundColor = [UIColor whiteColor];
  _selectorLetterTextColor = [UIColor whiteColor];
  
  // this is using variables directly to not trigger setter methods
  _singleWeekViews = [NSMutableArray arrayWithCapacity:WEEKS];
  _firstWeekday = 1; // sunday
  _gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  
  CGFloat width = CGRectGetWidth(self.frame);
  CGFloat height = CGRectGetHeight(self.frame);
  CGRect scrollViewFrame = CGRectMake(0, 0, width, height - 1);
  UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
  scrollView.contentSize = CGSizeMake(WEEKS * width, height);
  scrollView.contentOffset = CGPointMake(width, 0);
  scrollView.pagingEnabled = YES;
  scrollView.delegate = self;
  scrollView.showsVerticalScrollIndicator = NO;
  [self addSubview:scrollView];
  self.scrollView = scrollView;
  
  UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(scrollViewFrame), width, 1)];
  lineView.backgroundColor = self.lineColor;
  [self insertSubview:lineView atIndex:0];
  self.lineView = lineView;

  NSLocale *locale = [NSLocale systemLocale];
  self.dayNumberDateFormatter = [[NSDateFormatter alloc] init];
  self.dayNumberDateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"d"
                                                                           options:0
                                                                            locale:locale];
  self.dayNameDateFormatter = [[NSDateFormatter alloc] init];
  self.dayNameDateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E"
                                                                         options:0
                                                                          locale:locale];
  
  [self rebuildWeeks];
}

- (void)rebuildWeeks
{
  if (! self.selectedDate) {
    return;
  }
  
  if (self.singleWeekViews.count > 0) {
    for (UIView *view in self.singleWeekViews) {
      [view removeFromSuperview];
    }
    [self.singleWeekViews removeAllObjects];
  }
  
  // determine where the start of the previews week was as that'll be our start date
  NSDateComponents *component = [self.gregorian components:NSWeekdayCalendarUnit fromDate:self.selectedDate];
  NSInteger weekday = [component weekday];
  NSInteger daysToSubtract;
  if (weekday == self.firstWeekday) {
    daysToSubtract = 0;
  } else if (weekday > self.firstWeekday) {
    daysToSubtract = weekday - self.firstWeekday;
  } else {
    daysToSubtract = (weekday + 7) - self.firstWeekday;
  }
  daysToSubtract += 7;

  NSDate *date = [self dateByAddingDays:- daysToSubtract toDate:self.selectedDate];

  CGFloat width = CGRectGetWidth(self.frame);
  CGFloat height = CGRectGetHeight(self.frame);

  // now we can build the #WEEKS subvies
  for (NSUInteger index = 0; index < WEEKS; index++) {
    CGRect frame = CGRectMake(index * width, 0, width, height);
    ASSingleWeekView *singleView = [[ASSingleWeekView alloc] initWithFrame:frame];
    singleView.delegate = self;
    singleView.startDate = date; // needs to be set AFTER delegate
    
    [self.scrollView addSubview:singleView];
    [self.singleWeekViews addObject:singleView];
    
    // next week
    date = [self dateByAddingDays:7 toDate:date];
  }
}

- (NSDate *)dateByAddingDays:(NSInteger)days toDate:(NSDate *)date
{
  NSDateComponents *diff = [[NSDateComponents alloc] init];
  diff.day = days;
  return [self.gregorian dateByAddingComponents:diff toDate:date options:0];
}

- (BOOL)date:(NSDate *)date matchesDateComponentsOfDate:(NSDate *)otherDate
{
  if (date == otherDate) {
    return YES;
  }
  if (! date || ! otherDate) {
    return NO;
  }
  
  NSUInteger unitFlags = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
  
  NSDateComponents *components = [self.gregorian components:unitFlags fromDate:date];
  NSDateComponents *otherComponents = [self.gregorian components:unitFlags fromDate:otherDate];
  return [components isEqual:otherComponents];
}

- (void)userSelectedDate:(NSDate *)date
{
  _selectedDate = date;
  
  self.selectionLabel.alpha = 1;
  self.selectionLabel.text = [self.dayNumberDateFormatter stringFromDate:date];
  
  [self.delegate weekSelector:self selectedDate:self.selectedDate];
}

#pragma mark - Lazy accessors

- (ASDaySelectionView *)selectionView
{
  if (! _selectionView) {
    CGFloat width = CGRectGetWidth(self.frame) / 7;
    CGFloat height = CGRectGetHeight(self.frame);
    
    ASDaySelectionView *view = [[ASDaySelectionView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    view.backgroundColor = self.selectorBackgroundColor;
    view.circleCenter = CGPointMake(width / 2, 20 + (height - 20) / 2);
    view.circleColor = self.tintColor;
    view.userInteractionEnabled = NO;
    [self insertSubview:view aboveSubview:self.lineView];
    _selectionView = view;
  }
  return _selectionView;
}

- (UILabel *)selectionLabel
{
  if (! _selectionLabel) {
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectNull];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    numberLabel.font = [UIFont systemFontOfSize:18];
    numberLabel.textColor = self.selectorLetterTextColor;
    [self insertSubview:numberLabel aboveSubview:self.scrollView];
    _selectionLabel = numberLabel;
  }
  return _selectionLabel;
}

@end
