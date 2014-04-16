//
//  ASSingleWeekView.m
//  ASWeekSelectorView
//
//  Created by Adrian Schoenig on 16/04/2014.
//  Copyright (c) 2014 Adrian Schoenig. All rights reserved.
//

#import "ASSingleWeekView.h"

@interface ASSingleWeekView ()

@property (nonatomic, strong) NSCalendar *gregorian;

@end

@implementation ASSingleWeekView

#pragma mark - Public methods

- (void)setStartDate:(NSDate *)startDate
{
  _startDate = startDate;
  
  // rebuild the view
  for (NSInteger index = self.subviews.count - 1; index >= 0; index--) {
    UIView *subview = self.subviews[index];
    [subview removeFromSuperview];
  }
  CGFloat widthPerItem = CGRectGetWidth(self.frame) / 7;
  CGFloat itemHeight = CGRectGetHeight(self.frame);
  for (NSUInteger dayIndex = 0; dayIndex < 7; dayIndex++) {
    NSDate *date = dayIndex == 0 ? startDate : [self dateByAddingDays:dayIndex toDate:startDate];
    CGRect frame = CGRectMake(dayIndex * widthPerItem, 0, widthPerItem, itemHeight);
    UIView *view = [self.delegate singleWeekView:self
                                     viewForDate:date
                                       withFrame:frame];
    [self addSubview:view];
  }
}

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  }
  return self;
}

#pragma mark - Private helpers

- (NSDate *)dateByAddingDays:(NSInteger)days toDate:(NSDate *)date
{
  NSDateComponents *components = [[NSDateComponents alloc] init];
  [components setDay:days];
  return [self.gregorian dateByAddingComponents:components toDate:date options:0];
}

@end
