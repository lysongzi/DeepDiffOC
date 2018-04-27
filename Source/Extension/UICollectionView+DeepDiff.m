//
//  UICollectionView+DeepDiff.m
//  DeepDiffOC
//
//  Created by bingolin on 2018/1/25.
//  Copyright © 2018年 bingolin. All rights reserved.
//

#if !__has_feature(objc_arc)
#error  does not support Objective-C Automatic Reference Counting (ARC)
#endif

#import "UICollectionView+DeepDiff.h"

#import <objc/runtime.h>
#import "LCDiffChange.h"

@implementation UICollectionView (DeepDiff)

- (void)setIndexPathConvertor:(LCDiffIndexPathConvertor *)indexPathConvertor
{
    objc_setAssociatedObject(self, @selector(indexPathConvertor), indexPathConvertor, OBJC_ASSOCIATION_RETAIN);
}

- (LCDiffIndexPathConvertor *)indexPathConvertor
{
    LCDiffIndexPathConvertor *convertor = objc_getAssociatedObject(self, @selector(indexPathConvertor));
    if (!convertor) {
        convertor = [LCDiffIndexPathConvertor new];
        objc_setAssociatedObject(self, @selector(indexPathConvertor), convertor, OBJC_ASSOCIATION_RETAIN);
    }
    return convertor;
}

- (void)reloadDataWithChanges:(NSArray<LCDiffChange *> *)changes
                      section:(NSUInteger)section
                   startIndex:(NSUInteger)startIndex
            withRowAnimations:(UITableViewChangeAnimation *)animations
                   completion:(void (^)(BOOL))completion
{
    if (changes.count == 0) {
        completion(YES);
        return;
    }
    
    LCDiffIndexPathsColletion *indexPaths = [self.indexPathConvertor convert:changes section:section startIndex:startIndex];
    
    [self performBatchUpdates:^{
        [self internalBatchUpdate:indexPaths withRowAnimations:animations];
    } completion:completion];
    
    [self reloadItemsAtIndexPaths:indexPaths.replaces];
}

- (void)internalBatchUpdate:(LCDiffIndexPathsColletion *)indexPaths withRowAnimations:(UITableViewChangeAnimation *)animations
{
    [self deleteItemsAtIndexPaths:indexPaths.deletes];
    [self insertItemsAtIndexPaths:indexPaths.inserts];
    
    for (int idx = 0; idx < indexPaths.moves.count; idx++) {
        LCDiffMoveIndexPath * obj = indexPaths.moves[idx];
        [self moveItemAtIndexPath:obj.fromIndexPath toIndexPath:obj.toIndexPath];
    }
}

@end

