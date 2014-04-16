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

@property (nonatomic, strong) NSDateFormatter *dayNameDateFormatter;
@property (nonatomic, strong) NSDateFormatter *dayNumberDateFormatter;

@end

@implementation ASWeekSelectorView

#pragma mark - Public methods

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
  if (scrollView.contentOffset.y != 0) {
    CGPoint offset = scrollView.contentOffset;
    offset.y = 0;
    scrollView.contentOffset = offset;
  }
}

#pragma mark - ASSingleWeekViewDelegate

- (UIView *)singleWeekView:(ASSingleWeekView *)singleWeekView viewForDate:(NSDate *)date withFrame:(CGRect)frame
{
  UIView *wrapper = [[UIView alloc] initWithFrame:frame];
  CGFloat width = CGRectGetWidth(frame);

  CGFloat nameHeight = 15;
  CGRect nameFrame = CGRectMake(0, 0, width, nameHeight);
  UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameFrame];
  nameLabel.textAlignment = NSTextAlignmentCenter;
  nameLabel.font = [UIFont systemFontOfSize:12];
  nameLabel.textColor = [UIColor blueColor];
  nameLabel.text = [self.dayNameDateFormatter stringFromDate:date];
  [wrapper addSubview:nameLabel];

  CGRect numberFrame = CGRectMake(0, nameHeight, width, CGRectGetHeight(frame) - nameHeight);
  UILabel *numberLabel = [[UILabel alloc] initWithFrame:numberFrame];
  numberLabel.textAlignment = NSTextAlignmentCenter;
  numberLabel.font = [UIFont systemFontOfSize:12];
  numberLabel.textColor = [UIColor blueColor];
  numberLabel.text = [self.dayNumberDateFormatter stringFromDate:date];
  [wrapper addSubview:numberLabel];
  return wrapper;
}


- (void)singleWeekView:(ASSingleWeekView *)singleWeekView didSelectDate:(NSDate *)date
{
  for (ASSingleWeekView *aSingle in self.singleWeekViews) {
    if (singleWeekView != aSingle) {
      aSingle.selectedDate = nil;
    }
  }
  [self.delegate weekSelector:self selectedDate:date];
}

#pragma mark - Private helpers

- (void)didInit
{
  self.singleWeekViews = [NSMutableArray arrayWithCapacity:WEEKS];
  self.selectedDate = [NSDate date];
  self.firstWeekday = 1; // sunday
  
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
  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateComponents *component = [gregorian components:NSWeekdayCalendarUnit
                                             fromDate:self.selectedDate];
  NSInteger weekday = [component weekday];
  NSInteger daysToSubtract;
  if (weekday == self.firstWeekday) {
    // nothing to do
  } else if (weekday > self.firstWeekday) {
    daysToSubtract = weekday - self.firstWeekday;
  } else {
    daysToSubtract = (weekday + 7) - self.firstWeekday;
  }
  NSDateComponents *diffToStartOfPrevious = [[NSDateComponents alloc] init];
  diffToStartOfPrevious.day = - (daysToSubtract + 7);

  NSDate *date = [gregorian dateByAddingComponents:diffToStartOfPrevious toDate:self.selectedDate options:0];
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
    NSDateComponents *diffToNext = [[NSDateComponents alloc] init];
    diffToNext.day = 7;
    date = [gregorian dateByAddingComponents:diffToNext toDate:date options:0];
  }
}

@end
