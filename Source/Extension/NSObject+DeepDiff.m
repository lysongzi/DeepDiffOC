//
//  NSArray+DeepDiff.m
//  QQ
//
//  Created by bingolin on 2018/1/26.
//

#if !__has_feature(objc_arc)
#error  does not support Objective-C Automatic Reference Counting (ARC)
#endif

#import "NSObject+DeepDiff.h"

@implementation NSObject (DeepDiff)

- (BOOL)isTwoDimensionDataSource
{
    return NO;
}

- (NSArray *)dataList
{
    return nil;
}

- (BOOL)isEqualToObject:(id)Obj
{
    return [self isEqual:Obj];
}

- (id<NSObject>)diffIdentifier
{
    return [NSString stringWithFormat:@"%zi", self.hash];
}

@end

@implementation NSArray (DeepDiff)

- (BOOL)isTwoDimensionDataSource
{
    return YES;
}

- (NSArray *)dataList
{
    return self;
}

@end

@implementation NSMutableArray (DeepDiff)

- (BOOL)isTwoDimensionDataSource
{
    return YES;
}

- (NSArray *)dataList
{
    return self;
}

@end
