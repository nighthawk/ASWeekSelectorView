
//
//  ASViewController.m
//  ASWeekSelectorView
//
//  Created by Adrian Schoenig on 16/04/2014.
//  Copyright (c) 2014 Adrian Schoenig. All rights reserved.
//

#import "ASViewController.h"

@interface ASViewController ()

@end

@implementation ASViewController

- (IBAction)todayButtonPressed:(id)sender
{
  NSDate *now = [NSDate date];
  [self.weekSelector setSelectedDate:now animated:YES];
  [self updateLabelForDate:now];
}

- (void)updateLabelForDate:(NSDate *)date
{
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.timeStyle = NSDateFormatterNoStyle;
  dateFormatter.dateStyle = NSDateFormatterFullStyle;
  
  self.label.text = [dateFormatter stringFromDate:date];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  NSDate *now = [NSDate date];
  [self updateLabelForDate:now];

  self.weekSelector.firstWeekday = 2; // monday
  self.weekSelector.letterTextColor = [UIColor colorWithWhite:.5 alpha:1];
  self.weekSelector.delegate = self;
  self.weekSelector.selectedDate = now;
}

#pragma mark - ASWeekSelectorViewDelegate

- (void)weekSelector:(ASWeekSelectorView *)weekSelector willSelectDate:(NSDate *)date
{
  [self updateLabelForDate:date];
}

- (UIColor *)weekSelector:(ASWeekSelectorView *)weekSelector numberColorForDate:(NSDate *)date
{
  NSCalendar *gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
  NSInteger weekday = [gregorian component:NSCalendarUnitWeekday fromDate:date];
  if (weekday == 1 || weekday == 7) { // Sat or Sun
    return [UIColor lightGrayColor];
  } else {
    return nil;
  }
}

- (UIColor *)weekSelector:(ASWeekSelectorView *)weekSelector circleColorForDate:(NSDate *)date
{
  NSCalendar *gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
  NSInteger weekday = [gregorian component:NSCalendarUnitWeekday fromDate:date];
  if (weekday == 2) { // Mo
    return [UIColor greenColor];
  } else {
    return nil;
  }
}

- (BOOL)weekSelector:(ASWeekSelectorView *)weekSelector showIndicatorForDate:(NSDate *)date
{
  NSCalendar *gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
  NSInteger weekday = [gregorian component:NSCalendarUnitDay fromDate:date];
  return weekday % 2 == 1;
}

@end
