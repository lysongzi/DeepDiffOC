//
//  LCDiffStratege.m
//  QQ
//
//  Created by bingolin on 2018/1/22.
//

#if !__has_feature(objc_arc)
#error  does not support Objective-C Automatic Reference Counting (ARC)
#endif

#import "LCDiffStratege.h"

#import "LCDiffChange.h"
#import "NSObject+DeepDiff.h"

/**
 Diff策略基类对象
 */
@implementation LCDiffBaseStratege

- (NSArray<LCDiffChange *> *)oneDimensionDiffForOldItems:(NSArray *)oldItems newItems:(NSArray *)newItems
{
    // 由子类扩展实现
    return nil;
}

- (NSArray<LCDiffChange *> *)twoDimensionDiffForOldItems:(NSArray *)oldItems newItems:(NSArray *)newItems
{
    // 由子类扩展实现
    return nil;
}

- (NSArray<LCDiffChange *> *)preprogress:(NSArray *)oldItems newItems:(NSArray *)newItems
{
    BOOL isOldItemsEmpty = oldItems.count == 0;
    BOOL isNewItemsEmpty = newItems.count == 0;
    
    // no change
    if (isOldItemsEmpty && isNewItemsEmpty) {
        return @[];
    }
    // all new item, add all.
    else if (isOldItemsEmpty && !isNewItemsEmpty) {
        NSMutableArray *changes = [NSMutableArray new];
        BOOL isTwoDimension = [[newItems firstObject] isTwoDimensionDataSource];
        
        if (isTwoDimension) {
            for (int idx = 0; idx < newItems.count; idx++) {
                NSArray *subDatalist = [newItems[idx] dataList];
                for (int subIdx = 0; subIdx < subDatalist.count; subIdx++) {
                    [changes addObject:[self insertChange:subDatalist[subIdx] row:subIdx section:idx]];
                }
            }
        }
        else {
            for (int idx = 0; idx < newItems.count; idx++) {
                [changes addObject:[self insertChange:newItems[idx] row:idx section:0]];
            }
        }
        return changes;
    }
    // all old item, delete all.
    else if (!isOldItemsEmpty && isNewItemsEmpty) {
        NSMutableArray *changes = [NSMutableArray new];
        BOOL isTwoDimension = [[oldItems firstObject] isTwoDimensionDataSource];
        
        if (isTwoDimension) {
            for (int idx = 0; idx < oldItems.count; idx++) {
                NSArray *subDatalist = [oldItems[idx] dataList];
                for (int subIdx = 0; subIdx < subDatalist.count; subIdx++) {
                    [changes addObject:[self deleteChange:subDatalist[subIdx] row:subIdx section:idx]];
                }
            }
        }
        else {
            for (int idx = 0; idx < oldItems.count; idx++) {
                [changes addObject:[self deleteChange:oldItems[idx] row:idx section:0]];
            }
        }
        return changes;
    }
    // 新旧集合都不为空则后续进行diff处理
    else {
        return nil;
    }
}

- (LCDiffChange *)insertChange:(id)obj row:(NSUInteger)row section:(NSUInteger)section
{
    NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
    LCDiffInsert *insert = [[LCDiffInsert alloc] initWithItem:obj indexPath:insertIndexPath];
    LCDiffChange *change = [[LCDiffChange alloc] initWithInsert:insert];
    return change;
}

- (LCDiffChange *)deleteChange:(id)obj row:(NSUInteger)row section:(NSUInteger)section
{
    NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
    LCDiffDelete *delete = [[LCDiffDelete alloc] initWithItem:obj indexPath:deleteIndexPath];
    LCDiffChange *change = [[LCDiffChange alloc] initWithDelete:delete];
    return change;
}

@end

