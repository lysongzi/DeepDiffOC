//
//  UICollectionView+DeepDiff.h
//  DeepDiffOC
//
//  Created by bingolin on 2018/1/25.
//  Copyright © 2018年 bingolin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LCDiffChange, UITableViewChangeAnimation;

@interface UICollectionView (DeepDiff)

/**
 reload tableview
 
 @param changes colletion of change
 @param section section of changes
 @param startIndex
 @param animations
 @param completion invoked when reload tableview finish
 */
- (void)reloadDataWithChanges:(NSArray<LCDiffChange *> *)changes
                      section:(NSUInteger)section
                   startIndex:(NSUInteger)startIndex
            withRowAnimations:(UITableViewChangeAnimation *)animations
                   completion:(void(^)(BOOL finish))completion;

@end

