//
//  LCDiffManager.h
//  QQ
//
//  Created by bingolin on 2018/1/19.
//

#import <Foundation/Foundation.h>

@class LCDiffChange;

@interface LCDiffManager : NSObject

/**
 传入新旧两个集合，算出Diff的编辑距离集合
 
 @param oldItems <#oldItems description#>
 @param newItems <#newItems description#>
 @return <#return value description#>
 */
- (NSArray<LCDiffChange *> *)diff:(NSArray *)oldItems newItems:(NSArray *)newItems;

@end

