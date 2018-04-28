//
//  LCDiffHeckle.m
//  DeepDiffOCTests
//
//  Created by bingolin on 2018/1/23.
//  Copyright © 2018年 bingolin. All rights reserved.
//

#if !__has_feature(objc_arc)
#error  does not support Objective-C Automatic Reference Counting (ARC)
#endif

#import "LCDiffHeckle.h"
#import "LCDeepDiff.h"

typedef NS_ENUM(NSUInteger, LCDCounterType)
{
    LCDCounterTypeZero = 0,
    LCDCounterTypeOne  = 1
};

/**
 LCDTableEntry
 */
@interface LCDTableEntry : NSObject

@property (nonatomic, assign) NSUInteger aOldCounter;

@property (nonatomic, assign) NSUInteger aNewCounter;

@property (nonatomic, strong) NSMutableArray *indexesInOldFile;

@end

@implementation LCDTableEntry

- (instancetype)init
{
    if (self == [super init]) {
        _aOldCounter = LCDCounterTypeZero;
        _aNewCounter = LCDCounterTypeZero;
        _indexesInOldFile = [NSMutableArray new];
    }
    return self;
}

@end

/**
 Heckle实现的Diff算法器
 */
@implementation LCDiffHeckle

- (instancetype)initWithReduceFlag:(BOOL)reduceFlag
{
    if (self = [super init]) {
        // TO DO...
    }
    return self;
}

#pragma mark -

- (NSArray<LCDiffChange *> *)diff:(NSArray<LCDiffModel*> *)oldItems newItems:(NSArray<LCDiffModel*> *)newItems
{
    NSMutableDictionary<NSNumber *, LCDTableEntry *> *table = [NSMutableDictionary new];
    
    NSMutableArray *oldArray = [NSMutableArray new];
    NSMutableArray *newArray = [NSMutableArray new];
    
    [self perform1stPassWithNewItems:newItems table:table newArray:newArray];
    [self perform2stPassWithOldItems:oldItems table:table oldArray:oldArray];
    [self perform3stPassWithNewArray:newArray oldArray:oldArray];
    NSMutableArray *changes = [self performFinalPassWithNewItems:newItems oldItems:oldItems newArray:newArray oldArray:oldArray];
    
    return changes;
}

/**
 1.遍历新的数据源，统计新的数据源中每个数据出现的次数，给每个数据创建一个映射表；

 @param newItems <#newItems description#>
 @param table <#table description#>
 @param newArray <#newArray description#>
 */
- (void)perform1stPassWithNewItems:(NSArray *)newItems table:(NSMutableDictionary<NSNumber *, LCDTableEntry *> *)table newArray:(NSMutableArray *)newArray
{
    [newItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *hashValue = @([((NSObject *)obj) hash]);
        LCDTableEntry *tableEntry = table[hashValue] ?: [LCDTableEntry new];
        
        tableEntry.aNewCounter++;
        [newArray addObject:tableEntry];
        table[hashValue] = tableEntry;
    }];
}

/**
 2.遍历旧的数据源，更新每个数据在旧数据源中出现的次数，以及记录其所在索引位置；

 @param oldItems <#oldItems description#>
 @param table <#table description#>
 @param oldArray <#oldArray description#>
 */
- (void)perform2stPassWithOldItems:(NSArray *)oldItems table:(NSMutableDictionary<NSNumber *, LCDTableEntry *> *)table oldArray:(NSMutableArray *)oldArray
{
    [oldItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber *hashValue = @([((NSObject *)obj) hash]);
        LCDTableEntry *tableEntry = table[hashValue] ? table[hashValue] : [LCDTableEntry new];
        
        tableEntry.aOldCounter++;
        [tableEntry.indexesInOldFile addObject:@(idx)];
        [oldArray addObject:tableEntry];
        table[hashValue] = tableEntry;
    }];
}

/**
 3.处理新、旧数据列表中均只出现过一次的元素

 @param newArray <#newArray description#>
 @param oldArray <#oldArray description#>
 */
- (void)perform3stPassWithNewArray:(NSMutableArray *)newArray oldArray:(NSMutableArray *)oldArray
{
    [newArray enumerateObjectsUsingBlock:^(id  _Nonnull newObj, NSUInteger newIdx, BOOL * _Nonnull stop) {
        if (![newObj isKindOfClass:[LCDTableEntry class]]) {
            return;
        }
        
        LCDTableEntry *tableEntry = (LCDTableEntry *)newObj;
        if (tableEntry.aOldCounter != LCDCounterTypeOne
            || tableEntry.aNewCounter != LCDCounterTypeOne) {
            return;
        }
        
        if (tableEntry.indexesInOldFile.count <= 0) {
            return;
        }
        
        NSUInteger oldIndex = [tableEntry.indexesInOldFile.firstObject unsignedIntegerValue];
        [tableEntry.indexesInOldFile removeObjectAtIndex:0];
        newArray[newIdx] = @(oldIndex);
        oldArray[oldIndex] = @(newIdx);
    }];
}

- (NSMutableArray<LCDiffChange*> *)performFinalPassWithNewItems:(NSArray *)newItems oldItems:(NSArray *)oldItems newArray:(NSArray *)newArray oldArray:(NSArray *)oldArray
{
    NSMutableArray<LCDiffChange *> *changes = [NSMutableArray new];
    
    NSMutableDictionary *moves = [NSMutableDictionary new];
    NSMutableDictionary<NSNumber *, LCDiffChange *> *deletes = [NSMutableDictionary new];
    
    // find delete
    __block NSUInteger runningOffset = 0;
    [oldArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[LCDTableEntry class]]) {
            LCDiffModel *model = oldItems[idx];
            LCDiffDelete *aDelete = [[LCDiffDelete alloc] initWithItem:model.item indexPath:model.indexPath];
            LCDiffChange *change = [[LCDiffChange alloc] initWithDelete:aDelete];
            [changes addObject:change];
            deletes[@(idx)] = change;
        }
    }];
    
    // find insert, move
    runningOffset = 0;
    [newArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[LCDTableEntry class]]) {
            LCDTableEntry *tableEntry = (LCDTableEntry *)obj;
            if (tableEntry.indexesInOldFile.count > 0) {
                NSNumber *oldDeleteIndex = tableEntry.indexesInOldFile.firstObject;
                LCDiffChange *deleteChange = deletes[oldDeleteIndex];
                [tableEntry.indexesInOldFile removeObjectAtIndex:0];
                [changes removeObject:deleteChange];
            }
            else {
                // insert
                LCDiffModel *model = newItems[idx];
                LCDiffInsert *aInsert = [[LCDiffInsert alloc] initWithItem:model.item indexPath:model.indexPath];
                LCDiffChange *change = [[LCDiffChange alloc] initWithInsert:aInsert];
                [changes addObject:change];
            }
        }
        else if ([obj isKindOfClass:[NSNumber class]]) {
            NSUInteger oldIndex = [((NSNumber *)obj) unsignedIntegerValue];
            if ([oldItems[oldIndex] isEqual:newItems[idx]]
                && oldIndex != idx)
            {
                moves[@(idx)] = @(oldIndex);
                if (moves[@(oldIndex)] && [moves[@(oldIndex)] unsignedIntValue] == idx) {
                    // move
                    LCDiffModel *toModel = newItems[idx];
                    LCDiffModel *fromModel = oldItems[oldIndex];
                    LCDiffMove *move = [[LCDiffMove alloc] initWithItem:toModel.item fromIndexPath:fromModel.indexPath toIndexPath:toModel.indexPath];
                    LCDiffChange *change = [[LCDiffChange alloc] initWithMove:move];
                    [changes addObject:change];
                }
            }
        }
    }];
    
    return changes;
}

#pragma mark -

- (NSArray<LCDiffChange *> *)oneDimensionDiffForOldItems:(NSArray *)oldItems newItems:(NSArray *)newItems
{
    NSMutableArray *olds = [NSMutableArray new];
    NSMutableArray *news = [NSMutableArray new];
    
    [oldItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LCDiffModel *oldModel = [[LCDiffModel alloc] initWithItem:obj row:idx section:0];
        [olds addObject:oldModel];
    }];
    
    [newItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LCDiffModel *newModel = [[LCDiffModel alloc] initWithItem:obj row:idx section:0];
        [news addObject:newModel];
    }];
    
    return [self diff:olds newItems:news];
}

- (NSArray<LCDiffChange *> *)twoDimensionDiffForOldItems:(NSArray *)oldItems newItems:(NSArray *)newItems
{
    NSMutableArray *olds = [NSMutableArray new];
    NSMutableArray *news = [NSMutableArray new];
    
    [oldItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSObject *oldObj = (NSObject *)obj;
        NSArray *subDatalist = [oldObj dataList];
        [subDatalist enumerateObjectsUsingBlock:^(id  _Nonnull subObj, NSUInteger subIdx, BOOL * _Nonnull stop) {
            LCDiffModel *oldModel = [[LCDiffModel alloc] initWithItem:subObj row:subIdx section:idx];
            [olds addObject:oldModel];
        }];
    }];
    
    [newItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSObject *oldObj = (NSObject *)obj;
        NSArray *subDatalist = [oldObj dataList];
        [subDatalist enumerateObjectsUsingBlock:^(id  _Nonnull subObj, NSUInteger subIdx, BOOL * _Nonnull stop) {
            LCDiffModel *newModel = [[LCDiffModel alloc] initWithItem:subObj row:subIdx section:idx];
            [news addObject:newModel];
        }];
    }];
    
    return [self diff:olds newItems:news];
}

@end


