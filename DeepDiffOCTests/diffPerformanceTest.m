//
//  PerformanceTest.m
//  DeepDiffOCTests
//
//  Created by bingolin on 2018/2/23.
//  Copyright © 2018年 bingolin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LCDeepDiff.h"

static NSString * const kOldDataSetKey = @"__kOldDataSetKey__";
static NSString * const kNewDataSetKey = @"__kNewDataSetKey__";

@interface PerformanceTest : XCTestCase

@property (nonatomic, strong) LCDiffManager *diffManager;

@end

@implementation PerformanceTest

- (void)setUp {
    [super setUp];
    
    self.diffManager = [[LCDiffManager alloc] init];
}

#pragma mark - test under 100

- (void)test10Items_Replace2
{
    NSRange removeRange = NSMakeRange(0, 2);
    NSRange addRange = NSMakeRange(2, 2);
    NSDictionary *dataSet = [self generateWithCount:10 removeRange:removeRange addRange:addRange];
    
    [self measureBlock:^{
        NSArray *changes = [self.diffManager diff:dataSet[kOldDataSetKey] newItems:dataSet[kNewDataSetKey]];
        XCTAssertEqual(changes.count, 4);
    }];
}

#pragma mark - test 100

- (void)test100Items_Delete10
{
    NSRange removeRange = NSMakeRange(10, 10);
    NSRange addRange = NSMakeRange(NSNotFound, NSNotFound);
    NSDictionary *dataSet = [self generateWithCount:100 removeRange:removeRange addRange:addRange];
    
    [self measureBlock:^{
        NSArray *changes = [self.diffManager diff:dataSet[kOldDataSetKey] newItems:dataSet[kNewDataSetKey]];
        XCTAssertEqual(changes.count, 10);
    }];
}

- (void)test100Items_Add10
{
    NSRange removeRange = NSMakeRange(NSNotFound, NSNotFound);
    NSRange addRange = NSMakeRange(99, 10);
    NSDictionary *dataSet = [self generateWithCount:90 removeRange:removeRange addRange:addRange];
    
    [self measureBlock:^{
        NSArray *changes = [self.diffManager diff:dataSet[kOldDataSetKey] newItems:dataSet[kNewDataSetKey]];
        XCTAssertEqual(changes.count, 10);
    }];
}

- (void)test100Items_Replace50
{
    NSRange removeRange = NSMakeRange(0, 50);
    NSRange addRange = NSMakeRange(50, 50);
    NSDictionary *dataSet = [self generateWithCount:100 removeRange:removeRange addRange:addRange];
    
    [self measureBlock:^{
        NSArray *changes = [self.diffManager diff:dataSet[kOldDataSetKey] newItems:dataSet[kNewDataSetKey]];
        XCTAssertEqual(changes.count, 100);
    }];
}

- (void)test100Items_AllInsert
{
    NSArray *oData = @[];
    NSArray *nData = [self generateDataWithCapacity:100];
    
    [self measureBlock:^{
        NSArray *changes = [self.diffManager diff:oData newItems:nData];
        XCTAssertEqual(changes.count, 100);
    }];
}

- (void)test100Items_AllDelete
{
    NSArray *oData = [self generateDataWithCapacity:100];
    NSArray *nData = @[];
    
    [self measureBlock:^{
        NSArray *changes = [self.diffManager diff:oData newItems:nData];
        XCTAssertEqual(changes.count, 100);
    }];
}

#pragma mark - test 1000

- (void)test1000Items_Delete100
{
    NSRange removeRange = NSMakeRange(100, 100);
    NSRange addRange = NSMakeRange(NSNotFound, NSNotFound);
    NSDictionary *dataSet = [self generateWithCount:1000 removeRange:removeRange addRange:addRange];
    
    [self measureBlock:^{
        NSArray *changes = [self.diffManager diff:dataSet[kOldDataSetKey] newItems:dataSet[kNewDataSetKey]];
        XCTAssertEqual(changes.count, 100);
    }];
}

- (void)test1000Items_Add100
{
    NSRange removeRange = NSMakeRange(NSNotFound, NSNotFound);
    NSRange addRange = NSMakeRange(999, 100);
    NSDictionary *dataSet = [self generateWithCount:1000 removeRange:removeRange addRange:addRange];
    
    [self measureBlock:^{
        NSArray *changes = [self.diffManager diff:dataSet[kOldDataSetKey] newItems:dataSet[kNewDataSetKey]];
        XCTAssertEqual(changes.count, 100);
    }];
}

- (void)test1000Items_Replace100
{
    NSRange removeRange = NSMakeRange(100, 100);
    NSRange addRange = NSMakeRange(700, 100);
    NSDictionary *dataSet = [self generateWithCount:1000 removeRange:removeRange addRange:addRange];
    
    [self measureBlock:^{
        NSArray *changes = [self.diffManager diff:dataSet[kOldDataSetKey] newItems:dataSet[kNewDataSetKey]];
        XCTAssertEqual(changes.count, 200);
    }];
}

- (void)test1000Items_AllInsert
{
    NSArray *oData = @[];
    NSArray *nData = [self generateDataWithCapacity:1000];
    
    [self measureBlock:^{
        NSArray *changes = [self.diffManager diff:oData newItems:nData];
        XCTAssertEqual(changes.count, 1000);
    }];
}

- (void)test1000Items_AllDelete
{
    NSArray *oData = [self generateDataWithCapacity:1000];
    NSArray *nData = @[];
    
    [self measureBlock:^{
        NSArray *changes = [self.diffManager diff:oData newItems:nData];
        XCTAssertEqual(changes.count, 1000);
    }];
}

#pragma mark - test 10000

- (void)test10000Items_Delete1000
{
    NSRange removeRange = NSMakeRange(1000, 1000);
    NSRange addRange = NSMakeRange(NSNotFound, NSNotFound);
    NSDictionary *dataSet = [self generateWithCount:10000 removeRange:removeRange addRange:addRange];

    [self measureBlock:^{
        NSArray *changes = [self.diffManager diff:dataSet[kOldDataSetKey] newItems:dataSet[kNewDataSetKey]];
        XCTAssertEqual(changes.count, 1000);
    }];
}

- (void)test10000Items_Add1000
{
    NSRange removeRange = NSMakeRange(NSNotFound, NSNotFound);
    NSRange addRange = NSMakeRange(1000, 1000);
    NSDictionary *dataSet = [self generateWithCount:10000 removeRange:removeRange addRange:addRange];

    [self measureBlock:^{
        NSArray *changes = [self.diffManager diff:dataSet[kOldDataSetKey] newItems:dataSet[kNewDataSetKey]];
        XCTAssertEqual(changes.count, 1000);
    }];
}

- (void)test10000Items_AllInsert
{
    NSArray *oData = @[];
    NSArray *nData = [self generateDataWithCapacity:10000];

    [self measureBlock:^{
        NSArray *changes = [self.diffManager diff:oData newItems:nData];
        XCTAssertEqual(changes.count, 10000);
    }];
}

- (void)test10000Items_AllDelete
{
    NSArray *oData = [self generateDataWithCapacity:10000];
    NSArray *nData = @[];

    [self measureBlock:^{
        NSArray *changes = [self.diffManager diff:oData newItems:nData];
        XCTAssertEqual(changes.count, 10000);
    }];
}

#pragma mark - test 100000

- (void)test100000Items_Delete10000
{
    NSRange removeRange = NSMakeRange(10000, 10000);
    NSRange addRange = NSMakeRange(NSNotFound, NSNotFound);
    NSDictionary *dataSet = [self generateWithCount:100000 removeRange:removeRange addRange:addRange];

    [self measureBlock:^{
        NSArray *changes = [self.diffManager diff:dataSet[kOldDataSetKey] newItems:dataSet[kNewDataSetKey]];
        XCTAssertEqual(changes.count, 10000);
    }];
}

- (void)test100000Items_Add10000
{
    NSRange removeRange = NSMakeRange(NSNotFound, NSNotFound);
    NSRange addRange = NSMakeRange(10000, 10000);
    NSDictionary *dataSet = [self generateWithCount:100000 removeRange:removeRange addRange:addRange];

    [self measureBlock:^{
        NSArray *changes = [self.diffManager diff:dataSet[kOldDataSetKey] newItems:dataSet[kNewDataSetKey]];
        XCTAssertEqual(changes.count, 10000);
    }];
}

- (void)test100000Items_AllInsert
{
    NSArray *oData = @[];
    NSArray *nData = [self generateDataWithCapacity:100000];

    [self measureBlock:^{
        NSArray *changes = [self.diffManager diff:oData newItems:nData];
        XCTAssertEqual(changes.count, 100000);
    }];
}

- (void)test100000Items_AllDelete
{
    NSArray *oData = [self generateDataWithCapacity:100000];
    NSArray *nData = @[];

    [self measureBlock:^{
        NSArray *changes = [self.diffManager diff:oData newItems:nData];
        XCTAssertEqual(changes.count, 100000);
    }];
}

#pragma mark - private

- (NSDictionary *)generateWithCount:(NSUInteger)count
                   removeRange:(NSRange)removeRange
                      addRange:(NSRange)addRange
{
    NSArray *oData = [self generateDataWithCapacity:count];
    NSArray *nData = [self generateNewDataWithOldData:oData removeRange:removeRange addRange:addRange];
    return @{
             kOldDataSetKey : oData,
             kNewDataSetKey : nData
             };
}

- (NSArray *)generateDataWithCapacity:(NSUInteger)count
{
    NSMutableArray *data = [NSMutableArray new];
    for (int index = 0; index < count; index++) {
        NSString *uuid = [NSUUID UUID].UUIDString;
        [data addObject:uuid];
    }
    return data;
}

- (NSArray *)generateNewDataWithOldData:(NSArray *)oldData
                            removeRange:(NSRange)removeRange
                               addRange:(NSRange)addRange
{
    NSMutableArray *nData = [NSMutableArray arrayWithArray:oldData];
    
    if (removeRange.location != NSNotFound) {
        [nData removeObjectsInRange:removeRange];
    }
    
    if (addRange.location != NSNotFound) {
        for (int index = 0; index < addRange.length; index++) {
            NSUInteger insertIndex = addRange.location + index;
            NSString *uuid = [NSUUID UUID].UUIDString;
            if (insertIndex < nData.count) {
                [nData insertObject:uuid atIndex:insertIndex];
            }
            else {
                [nData addObject:uuid];
            }
        }
    }
    
    return nData;
}

@end
