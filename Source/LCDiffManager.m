//
//  LCDiffManager.m
//  QQ
//
//  Created by bingolin on 2018/1/19.
//

#if !__has_feature(objc_arc)
#error  does not support Objective-C Automatic Reference Counting (ARC)
#endif

#import "LCDiffManager.h"
#import "LCDeepDiff.h"

@interface LCDiffManager ()

@property (nonatomic, strong) LCDiffBaseStratege *heckleAlgorithm;  // heckle算法器

@end

@implementation LCDiffManager

- (instancetype)init
{
    if (self = [super init]) {
        // TO DO...
    }
    return self;
}

- (LCDiffBaseStratege *)heckleAlgorithm
{
    if (!_heckleAlgorithm) {
        _heckleAlgorithm = [[LCDiffHeckle alloc] init];
//        _heckleAlgorithm = [[LCDiffIGHeckle alloc] init];
    }
    return _heckleAlgorithm;
}

#pragma mark - diff

- (NSArray<LCDiffChange *> *)diff:(NSArray *)oldItems newItems:(NSArray *)newItems
{
    NSArray *changes = [self.heckleAlgorithm preprogress:oldItems newItems:newItems];
    if (changes) {
        return changes;
    }
    
    NSObject *firstOldItem = [oldItems firstObject];
    NSObject *firstNewItem = [newItems firstObject];
    
    if ([firstOldItem isTwoDimensionDataSource] && [firstNewItem isTwoDimensionDataSource]) {
        return [self.heckleAlgorithm twoDimensionDiffForOldItems:oldItems newItems:newItems];
    }
    else if (![firstOldItem isTwoDimensionDataSource] && ![firstNewItem isTwoDimensionDataSource]) {
        return [self.heckleAlgorithm oneDimensionDiffForOldItems:oldItems newItems:newItems];
    }
    else {
        NSLog(@"oldItems and newItems has unequal demension!");
        assert(0);
    }
}

@end

