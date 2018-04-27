//
//  NSArray+DeepDiff.h
//  QQ
//
//  Created by bingolin on 2018/1/26.
//

#import <Foundation/Foundation.h>
#import "LCDeepDiff.h"

@interface NSObject (DeepDiff) <LCDiffDataSource>

@end

@interface NSArray (DeepDiff)

@end

@interface NSMutableArray (DeepDiff)

@end
