//
//  UITableView+DeepDiff.m
//  DeepDiffOC
//
//  Created by bingolin on 2018/1/24.
//  Copyright © 2018年 bingolin. All rights reserved.
//

#if !__has_feature(objc_arc)
#error  does not support Objective-C Automatic Reference Counting (ARC)
#endif

#import "UITableView+DeepDiff.h"

#import <objc/runtime.h>
#import "LCDiffChange.h"

@implementation UITableView (DeepDiff)

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
            withRowAnimations:(UITableViewChangeAnimation *)animations
                   completion:(void (^)(BOOL))completion
{
    [self reloadDataWithChanges:changes section:0 startIndex:0 withRowAnimations:animations completion:completion];
}

- (void)reloadDataWithChanges:(NSArray<LCDiffChange *> *)changes
                      section:(NSUInteger)section
                   startIndex:(NSUInteger)startIndex
            withRowAnimations:(UITableViewChangeAnimation *)animations
                   completion:(void (^)(BOOL))completion
{
    LCDiffIndexPathsColletion *indexPaths = [self.indexPathConvertor convert:changes section:section startIndex:startIndex];
    
    if (@available(iOS 11.0, *)) {
        [self performBatchUpdates:^{
            [self internalBatchUpdate:indexPaths withRowAnimations:animations];
        } completion:completion];
        
        // replace operation
        [self reloadRowsAtIndexPaths:indexPaths.replaces withRowAnimation:animations.replaceAnimation];
    }
    else {
        [self beginUpdates];
        [self internalBatchUpdate:indexPaths withRowAnimations:animations];
        [self endUpdates];
        
        // replace operation
        [self reloadRowsAtIndexPaths:indexPaths.replaces withRowAnimation:animations.replaceAnimation];
    }
}

- (void)internalBatchUpdate:(LCDiffIndexPathsColletion *)indexPaths withRowAnimations:(UITableViewChangeAnimation *)animations
{
    [self deleteRowsAtIndexPaths:indexPaths.deletes withRowAnimation:animations.deleteAnimation];
    [self insertRowsAtIndexPaths:indexPaths.inserts withRowAnimation:animations.insertAnimation];
    
    for (int idx = 0; idx < indexPaths.moves.count; idx++) {
        LCDiffMoveIndexPath * obj = indexPaths.moves[idx];
        [self moveRowAtIndexPath:obj.fromIndexPath toIndexPath:obj.toIndexPath];
    }
}

@end

