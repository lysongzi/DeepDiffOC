//
//  UITableView+DeepDiff.h
//  DeepDiffOC
//
//  Created by bingolin on 2018/1/24.
//  Copyright © 2018年 bingolin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LCDiffChange, UITableViewChangeAnimation;

@interface UITableView (DeepDiff)

/**
 reload tableview

 @param changes colletion of changes
 @param animations <#animations description#>
 @param completion invoked when reload tableview finish
 */
- (void)reloadDataWithChanges:(NSArray<LCDiffChange *> *)changes
            withRowAnimations:(UITableViewChangeAnimation *)animations
                   completion:(void(^)(BOOL finished))completion;

/**
 reload tableview

 @param changes colletion of changes
 @param section <#section description#>
 @param startIndex <#startIndex description#>
 @param animations <#animations description#>
 @param completion invoked when reload tableview finish
 */
- (void)reloadDataWithChanges:(NSArray<LCDiffChange *> *)changes
                      section:(NSUInteger)section
                   startIndex:(NSUInteger)startIndex
            withRowAnimations:(UITableViewChangeAnimation *)animations
                   completion:(void(^)(BOOL finished))completion;

@end

