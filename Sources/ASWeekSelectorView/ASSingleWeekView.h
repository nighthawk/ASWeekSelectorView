//
//  ASSingleWeekView.h
//  ASWeekSelectorView
//
//  Created by Adrian Schoenig on 16/04/2014.
//  Copyright (c) 2014 Adrian Schoenig. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ASSingleWeekViewDelegate;

@interface ASSingleWeekView : UIView

@property (nonatomic, weak, nullable) id<ASSingleWeekViewDelegate> delegate;

/**
 The first date to be shown.
 */
@property (nonatomic, strong, null_resettable) NSDate *startDate;

@end

@protocol ASSingleWeekViewDelegate <NSObject>

- (void)singleWeekView:(ASSingleWeekView *)singleWeekView didSelectDate:(NSDate *)date atFrame:(CGRect)frame;

- (UIView *)singleWeekView:(ASSingleWeekView *)singleWeekView viewForDate:(NSDate *)date withFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
