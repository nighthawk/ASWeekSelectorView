//
//  ASWeekSelectorView.m
//  TripGo
//
//  Created by Adrian Schoenig on 15/04/2014.
//
//

#import "ASWeekSelectorView.h"

#import "ASSingleWeekView.h"

#define WEEKS 3

@interface ASWeekSelectorView () <ASSingleWeekViewDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *singleWeekViews;
@property (nonatomic, weak) UIView *selectionView;

@property (nonatomic, strong) NSDateFormatter *dayNameDateFormatter;
@property (nonatomic, strong) NSDateFormatter *dayNumberDateFormatter;
@property (nonatomic, strong) NSCalendar *gregorian;

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
  _selectedDate = selectedDate;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
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
      self.selectedDate = [self dateByAddingDays:-7 toDate:self.selectedDate];
      [self.delegate weekSelector:self selectedDate:self.selectedDate];
      
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
      self.selectedDate = [self dateByAddingDays:7 toDate:self.selectedDate];
      [self.delegate weekSelector:self selectedDate:self.selectedDate];
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
  if ([self date:date matchesDateComponentsOfDate:self.selectedDate]) {
    self.selectionView.frame = frame;
  }
  
  UIView *wrapper = [[UIView alloc] initWithFrame:frame];
  CGFloat width = CGRectGetWidth(frame);

  CGFloat nameHeight = 15;
  CGRect nameFrame = CGRectMake(0, 0, width, nameHeight);
  UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameFrame];
  nameLabel.textAlignment = NSTextAlignmentCenter;
  nameLabel.font = [UIFont systemFontOfSize:12];
  nameLabel.textColor = [UIColor blackColor];
  nameLabel.text = [self.dayNameDateFormatter stringFromDate:date];
  [wrapper addSubview:nameLabel];

  CGRect numberFrame = CGRectMake(0, nameHeight, width, CGRectGetHeight(frame) - nameHeight);
  UILabel *numberLabel = [[UILabel alloc] initWithFrame:numberFrame];
  numberLabel.textAlignment = NSTextAlignmentCenter;
  numberLabel.font = [UIFont systemFontOfSize:12];
  numberLabel.textColor = [UIColor blackColor];
  numberLabel.text = [self.dayNumberDateFormatter stringFromDate:date];
  [wrapper addSubview:numberLabel];
  return wrapper;
}


- (void)singleWeekView:(ASSingleWeekView *)singleWeekView didSelectDate:(NSDate *)date atFrame:(CGRect)frame
{
  self.selectedDate = date;
  self.selectionView.frame = frame;
  [self.delegate weekSelector:self selectedDate:date];
}

#pragma mark - Private helpers

- (void)didInit
{
  // this is using variables directly to not trigger setter methods
  _singleWeekViews = [NSMutableArray arrayWithCapacity:WEEKS];
  _selectedDate = [NSDate date];
  _firstWeekday = 1; // sunday
  _gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  
  CGFloat width = CGRectGetWidth(self.frame);
  CGFloat height = CGRectGetHeight(self.frame);
  UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
  scrollView.contentSize = CGSizeMake(WEEKS * width, height);
  scrollView.contentOffset = CGPointMake(width, 0);
  scrollView.pagingEnabled = YES;
  scrollView.delegate = self;
  scrollView.showsVerticalScrollIndicator = NO;
  [self addSubview:scrollView];
  self.scrollView = scrollView;

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
    // nothing to do
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
  NSUInteger unitFlags = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
  
  NSDateComponents *components = [self.gregorian components:unitFlags fromDate:date];
  NSDateComponents *otherComponents = [self.gregorian components:unitFlags fromDate:otherDate];
  return [components isEqual:otherComponents];
}

#pragma mark - Lazy accessors

- (UIView *)selectionView
{
  if (! _selectionView) {
    UIView *view = [[UIView alloc] initWithFrame:CGRectNull];
    view.alpha = 0.2;
    view.backgroundColor = [UIColor blackColor];
    [self addSubview:view];
    _selectionView = view;
  }
  return _selectionView;
}

@end
