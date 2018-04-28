//
//  LCDiffChange.h
//  QQ
//
//  Created by bingolin on 2018/1/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "LCDiffStratege.h"

@interface LCDiffModel : NSObject <LCDiffModelProtocol>

@property (nonatomic, strong) id<LCDiffModelProtocol> item;
@property (nonatomic, strong) NSIndexPath *indexPath;

- (instancetype)initWithItem:(id<LCDiffModelProtocol>)item row:(NSUInteger)row section:(NSUInteger)section;

@end

#pragma mark -

/**
 diff result basic model
 */
@interface LCDiffBaseResult : NSObject

@end

/**
 insert model
 */
@interface LCDiffInsert : LCDiffBaseResult

@property (nonatomic, strong) id<NSObject> item;
@property (nonatomic, strong) NSIndexPath *indexPath;

- (instancetype)initWithItem:(id<NSObject>)item indexPath:(NSIndexPath *)indexPath;

@end

/**
 delete model
 */
@interface LCDiffDelete : LCDiffBaseResult

@property (nonatomic, strong) id<NSObject> item;
@property (nonatomic, strong) NSIndexPath *indexPath;

- (instancetype)initWithItem:(id<NSObject>)item indexPath:(NSIndexPath *)indexPath;

@end

/**
 replace model
 */
@interface LCDiffReplace : LCDiffBaseResult

@property (nonatomic, strong) id<NSObject> oItem;
@property (nonatomic, strong) id<NSObject> nItem;
@property (nonatomic, strong) NSIndexPath * indexPath;

- (instancetype)initWithOldItem:(id<NSObject>)oItem aNewItem:(id<NSObject>)nItem indexPath:(NSIndexPath *)indexPath;

@end

/**
 move model
 */
@interface LCDiffMove : LCDiffBaseResult

@property (nonatomic, strong) id<NSObject> item;
@property (nonatomic, strong) NSIndexPath * fromIndexPath;
@property (nonatomic, strong) NSIndexPath * toIndexPath;

- (instancetype)initWithItem:(id<NSObject>)item fromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

@end

/**
 一个表示变动操作的对象，可能是增加、删除、替换和移动
 */
@interface LCDiffChange : NSObject

@property (nonatomic, strong) LCDiffBaseResult *result;

/*
 for quick get result's real object, only one of those property can return one real object
 */
@property (nonatomic, strong) LCDiffInsert *aInsert;
@property (nonatomic, strong) LCDiffDelete *aDelete;
@property (nonatomic, strong) LCDiffReplace *aReplace;
@property (nonatomic, strong) LCDiffMove *aMove;

- (instancetype)initWithInsert:(LCDiffInsert *)aInsert;
- (instancetype)initWithDelete:(LCDiffDelete *)aDelete;
- (instancetype)initWithReplace:(LCDiffReplace *)aReplace;
- (instancetype)initWithMove:(LCDiffMove *)aMove;

@end

/**
 移动操作的索引模型，存储fromIndex和toIndex
 */
@interface LCDiffMoveIndexPath : NSObject

@property (nonatomic, strong) NSIndexPath *fromIndexPath;
@property (nonatomic, strong) NSIndexPath *toIndexPath;

- (instancetype)initWithFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

@end

#pragma mark -

/**
 存储了一系列LCDiffChange转化为iOS集合可操作的IndexPath序列
 */
@interface LCDiffIndexPathsColletion : NSObject

@property (nonatomic, strong) NSArray<NSIndexPath *> *inserts;
@property (nonatomic, strong) NSArray<NSIndexPath *> *deletes;
@property (nonatomic, strong) NSArray<NSIndexPath *> *replaces;
@property (nonatomic, strong) NSArray<LCDiffMoveIndexPath *> *moves;

- (instancetype)initWithInserts:(NSArray<NSIndexPath *> *)inserts
                        deletes:(NSArray<NSIndexPath *> *)deletes
                       replaces:(NSArray<NSIndexPath *> *)replaces
                          moves:(NSArray<LCDiffIndexPathsColletion *> *)moves;

@end

@interface LCDiffIndexPathConvertor : NSObject

- (LCDiffIndexPathsColletion *)convert:(NSArray<LCDiffChange *> *)changes section:(NSUInteger)section startIndex:(NSUInteger)startIndex;

@end

#pragma mark - animation

@interface UITableViewChangeAnimation : NSObject

@property (nonatomic, assign) UITableViewRowAnimation insertAnimation;   // 插入操作的动画
@property (nonatomic, assign) UITableViewRowAnimation deleteAnimation;   // 删除操作的动画
@property (nonatomic, assign) UITableViewRowAnimation replaceAnimation;  // 替换操作的动画

/**
 指定插入操作动画，其他操作默认为UITableViewRowAnimationAutomatic
 
 @param insertAnimation 插入动画
 @return <#return value description#>
 */
- (instancetype)initWithInsertAnimation:(UITableViewRowAnimation)insertAnimation;

/**
 指定删除操作动画，其他操作默认为UITableViewRowAnimationAutomatic
 
 @param deleteAnimation 删除动画
 @return <#return value description#>
 */
- (instancetype)initWithDeleteAnimation:(UITableViewRowAnimation)deleteAnimation;

/**
 指定替换操作动画，其他操作默认为UITableViewRowAnimationAutomatic
 
 @param replaceAnimation 替换动画
 @return <#return value description#>
 */
- (instancetype)initWithReplaceAnimation:(UITableViewRowAnimation)replaceAnimation;

/**
 设置插入、删除、替换、移动操作的动画效果
 
 @param insertAnimation 插入动画
 @param deleteAnimation 删除动画
 @param replaceAnimation 替换动画
 @return <#return value description#>
 */
- (instancetype)initWithInsertAnimation:(UITableViewRowAnimation)insertAnimation
                        deleteAnimation:(UITableViewRowAnimation)deleteAnimation
                       replaceAnimation:(UITableViewRowAnimation)replaceAnimation;

@end

