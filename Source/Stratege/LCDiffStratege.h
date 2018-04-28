//
//  LCDiffStratege.h
//  QQ
//
//  Created by bingolin on 2018/1/22.
//

#import <Foundation/Foundation.h>

@class LCDiffChange;

@protocol LCDiffModelProtocol <NSObject>

@required

/**
 if this model has two demension
 
 @return <#return value description#>
 */
- (BOOL)isTwoDimensionDataSource;

/**
 if isTwoDimensionDataSource == YES, return sub data list.
 
 @return <#return value description#>
 */
- (NSArray *)dataList;

@optional
/**
 if this obj is equal to another obj
 
 @param Obj <#Obj description#>
 @return <#return value description#>
 */
- (BOOL)isEqualToObject:(id)Obj;

/**
 identifier to identify a object

 @return <#return value description#>
 */
- (id<NSCopying>)diffIdentifier;

@end

@protocol LCDiffStrategy <NSObject>

/**
 计算两个一维集合间的diff
 
 @param oldItems <#oldItems description#>
 @param newItems <#newItems description#>
 @return <#return value description#>
 */
- (NSArray<LCDiffChange *> *)oneDimensionDiffForOldItems:(NSArray *)oldItems newItems:(NSArray *)newItems;

/**
 计算两个二维集合间的diff
 
 @param oldItems <#oldItems description#>
 @param newItems <#newItems description#>
 @return <#return value description#>
 */
- (NSArray<LCDiffChange *> *)twoDimensionDiffForOldItems:(NSArray *)oldItems newItems:(NSArray *)newItems;

@end

/**
 基础Diff策略对象，后续的不同diff策略对象可继承该对象进行扩展
 */
@interface LCDiffBaseStratege : NSObject <LCDiffStrategy>

/**
 预处理计算两个集合的diff
 
 @param oldItems <#oldItems description#>
 @param newItems <#newItems description#>
 @return <#return value description#>
 */
- (NSArray<LCDiffChange *> *)preprogress:(NSArray *)oldItems newItems:(NSArray *)newItems;

@end

