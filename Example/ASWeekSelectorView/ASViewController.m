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

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.weekSelector.selectedDate = [NSDate date];
  self.weekSelector.delegate = self;
  
  [self weekSelector:self.weekSelector selectedDate:self.weekSelector.selectedDate];
}

#pragma mark - ASWeekSelectorViewDelegate

- (void)weekSelector:(ASWeekSelectorView *)weekSelector selectedDate:(NSDate *)date
{
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.timeStyle = NSDateFormatterNoStyle;
  dateFormatter.dateStyle = NSDateFormatterFullStyle;
  
  self.label.text = [dateFormatter stringFromDate:date];
}

@end
