//
//  LCDiffChange.m
//  QQ
//
//  Created by bingolin on 2018/1/19.
//

#if !__has_feature(objc_arc)
#error  does not support Objective-C Automatic Reference Counting (ARC)
#endif

#import "LCDiffChange.h"
#import <UIKit/UIKit.h>

@implementation LCDiffModel

- (instancetype)initWithItem:(id<LCDiffModelProtocol>)item row:(NSUInteger)row section:(NSUInteger)section
{
    if (self = [super init]) {
        _item = item;
        _indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    if (self == object) {
        return YES;
    }
    
    LCDiffModel *model = (LCDiffModel *)object;
    return [self.item isEqual:model.item];
}

- (NSUInteger)hash
{
    return [self.item hash];
}

#pragma mark - LCDiffModelProtocol

- (id<NSCopying>)diffIdentifier
{
    return [self.item diffIdentifier];
}

- (BOOL)isTwoDimensionDataSource
{
    return NO;
}

- (NSArray *)dataList
{
    return nil;
}

@end

#pragma mark -

@implementation LCDiffBaseResult

@end

@implementation LCDiffInsert

- (instancetype)initWithItem:(id<NSObject>)item indexPath:(NSIndexPath *)indexPath
{
    if (self = [super init]) {
        _item  = item;
        _indexPath = indexPath;
    }
    return self;
}

@end

@implementation LCDiffDelete

- (instancetype)initWithItem:(id<NSObject>)item indexPath:(NSIndexPath *)indexPath
{
    if (self = [super init]) {
        _item  = item;
        _indexPath = indexPath;
    }
    return self;
}

@end

@implementation LCDiffReplace

- (instancetype)initWithOldItem:(id<NSObject>)oItem aNewItem:(id<NSObject>)nItem indexPath:(NSIndexPath *)indexPath
{
    if (self = [super init]) {
        _oItem = oItem;
        _nItem = nItem;
        _indexPath = indexPath;
    }
    return self;
}

@end

@implementation LCDiffMove

- (instancetype)initWithItem:(id<NSObject>)item fromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (self = [super init]) {
        _item = item;
        _toIndexPath = toIndexPath;
        _fromIndexPath = fromIndexPath;
    }
    return self;
}

@end

@implementation LCDiffChange

- (LCDiffInsert *)aInsert
{
    if ([_result isKindOfClass:[LCDiffInsert class]]) {
        return (LCDiffInsert *)_result;
    }
    return nil;
}

- (LCDiffDelete *)aDelete
{
    if ([_result isKindOfClass:[LCDiffDelete class]]) {
        return (LCDiffDelete *)_result;
    }
    return nil;
}

- (LCDiffReplace *)aReplace
{
    if ([_result isKindOfClass:[LCDiffReplace class]]) {
        return (LCDiffReplace *)_result;
    }
    return nil;
}

- (LCDiffMove *)aMove
{
    if ([_result isKindOfClass:[LCDiffMove class]]) {
        return (LCDiffMove *)_result;
    }
    return nil;
}

- (instancetype)initWithInsert:(LCDiffInsert *)aInsert
{
    if (self = [super init]) {
        _result = aInsert;
    }
    return self;
}

- (instancetype)initWithDelete:(LCDiffDelete *)aDelete
{
    if (self = [super init]) {
        _result = aDelete;
    }
    return self;
}

- (instancetype)initWithReplace:(LCDiffReplace *)aReplace
{
    if (self = [super init]) {
        _result = aReplace;
    }
    return self;
}

- (instancetype)initWithMove:(LCDiffMove *)aMove
{
    if (self = [super init]) {
        _result = aMove;
    }
    return self;
}

@end

#pragma mark -

@implementation LCDiffMoveIndexPath

- (instancetype)initWithFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (self = [super init]) {
        _fromIndexPath = fromIndexPath;
        _toIndexPath = toIndexPath;
    }
    return self;
}

@end

@implementation LCDiffIndexPathsColletion

- (instancetype)initWithInserts:(NSArray<NSIndexPath *> *)inserts
                        deletes:(NSArray<NSIndexPath *> *)deletes
                       replaces:(NSArray<NSIndexPath *> *)replaces
                          moves:(NSArray<LCDiffMoveIndexPath *> *)moves
{
    if (self = [super init]) {
        _inserts  = inserts;
        _deletes  = deletes;
        _replaces = replaces;
        _moves = moves;
    }
    return self;
}

@end

@implementation LCDiffIndexPathConvertor

- (LCDiffIndexPathsColletion *)convert:(NSArray<LCDiffChange *> *)changes section:(NSUInteger)section startIndex:(NSUInteger)startIndex
{
    NSMutableArray *inserts  = [NSMutableArray array];
    NSMutableArray *deletes  = [NSMutableArray array];
    NSMutableArray *replaces = [NSMutableArray array];
    NSMutableArray *moves = [NSMutableArray array];
    
    for (int idx = 0; idx < changes.count; idx++) {
        LCDiffChange *change = changes[idx];
        if ([change.result isKindOfClass:[LCDiffInsert class]]) {
            LCDiffInsert *obj = (LCDiffInsert *)change.result;
            NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:obj.indexPath.row + startIndex inSection:section + obj.indexPath.section];
            [inserts addObject:insertIndexPath];
        }
        else if ([change.result isKindOfClass:[LCDiffDelete class]]) {
            LCDiffDelete *obj = (LCDiffDelete *)change.result;
            NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:obj.indexPath.row + startIndex inSection:section + obj.indexPath.section];
            [deletes addObject:deleteIndexPath];
        }
        else if ([change.result isKindOfClass:[LCDiffReplace class]]) {
            LCDiffReplace *obj = (LCDiffReplace *)change.result;
            NSIndexPath *replaceIndexPath = [NSIndexPath indexPathForRow:obj.indexPath.row + startIndex inSection:section + obj.indexPath.section];
            [replaces addObject:replaceIndexPath];
        }
        else if ([change.result isKindOfClass:[LCDiffMove class]]) {
            LCDiffMove *obj = (LCDiffMove *)change.result;
            NSIndexPath *moveFromIndexPath = [NSIndexPath indexPathForRow:obj.fromIndexPath.row + startIndex inSection:section + obj.fromIndexPath.section];
            NSIndexPath *moveToIndexPath = [NSIndexPath indexPathForRow:obj.toIndexPath.row + startIndex inSection:section + obj.toIndexPath.section];
            LCDiffMoveIndexPath *moveIndexPath = [[LCDiffMoveIndexPath alloc] initWithFromIndexPath:moveFromIndexPath toIndexPath:moveToIndexPath];
            [moves addObject:moveIndexPath];
        }
    }

    return [[LCDiffIndexPathsColletion alloc] initWithInserts:inserts deletes:deletes replaces:replaces moves:moves];
}

@end

@implementation UITableViewChangeAnimation

- (instancetype)init
{
    return [self initWithInsertAnimation:UITableViewRowAnimationNone
                         deleteAnimation:UITableViewRowAnimationNone
                        replaceAnimation:UITableViewRowAnimationNone];
}

- (instancetype)initWithInsertAnimation:(UITableViewRowAnimation)insertAnimation
{
    return [self initWithInsertAnimation:insertAnimation
                         deleteAnimation:UITableViewRowAnimationNone
                        replaceAnimation:UITableViewRowAnimationNone];
}

- (instancetype)initWithDeleteAnimation:(UITableViewRowAnimation)deleteAnimation
{
    return [self initWithInsertAnimation:UITableViewRowAnimationNone
                         deleteAnimation:deleteAnimation
                        replaceAnimation:UITableViewRowAnimationNone];
}

- (instancetype)initWithReplaceAnimation:(UITableViewRowAnimation)replaceAnimation
{
    return [self initWithInsertAnimation:UITableViewRowAnimationNone
                         deleteAnimation:UITableViewRowAnimationNone
                        replaceAnimation:replaceAnimation];
}

- (instancetype)initWithInsertAnimation:(UITableViewRowAnimation)insertAnimation
                        deleteAnimation:(UITableViewRowAnimation)deleteAnimation
                       replaceAnimation:(UITableViewRowAnimation)replaceAnimation
{
    if (self = [super init]) {
        _insertAnimation = insertAnimation;
        _deleteAnimation = deleteAnimation;
        _replaceAnimation = replaceAnimation;
    }
    return self;
}

@end

