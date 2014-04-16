//
//  ASViewController.h
//  ASWeekSelectorView
//
//  Created by Adrian Schoenig on 16/04/2014.
//  Copyright (c) 2014 Adrian Schoenig. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASWeekSelectorView.h"

@interface ASViewController : UIViewController <ASWeekSelectorViewDelegate>

@property (weak, nonatomic) IBOutlet ASWeekSelectorView *weekSelector;
@property (weak, nonatomic) IBOutlet UILabel *label;

- (IBAction)todayButtonPressed:(id)sender;

@end
