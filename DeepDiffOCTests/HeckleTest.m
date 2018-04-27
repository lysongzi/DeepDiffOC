//
//  HeckleTest.m
//  DeepDiffOCTests
//
//  Created by bingolin on 2018/1/29.
//  Copyright © 2018年 bingolin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "LCDeepDiff.h"
#import "LCDUser.h"

@interface HeckleTest : XCTestCase

@property (nonatomic, strong) LCDiffManager *diffManager;

@end

@implementation HeckleTest

- (void)setUp {
    [super setUp];
    
    self.diffManager = [[LCDiffManager alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testEmpty
{
    NSArray *oldItems = @[];
    NSArray *newItems = @[];
    
    NSArray *changes = [self.diffManager diff:oldItems newItems:newItems];
    XCTAssertEqual(changes.count, 0);
}

- (void)testAllInsert
{
    NSArray *oldItems = @[];
    NSArray *newItems = @[@"a", @"b", @"c", @"d"];
    
    NSArray *changes = [self.diffManager diff:oldItems newItems:newItems];
    XCTAssertEqual(changes.count, 4);
    
    XCTAssertEqual(((LCDiffChange *)changes[0]).aInsert.item, @"a");
    XCTAssertEqual(((LCDiffChange *)changes[0]).aInsert.indexPath.row, 0);
    
    XCTAssertEqual(((LCDiffChange *)changes[1]).aInsert.item, @"b");
    XCTAssertEqual(((LCDiffChange *)changes[1]).aInsert.indexPath.row, 1);
    
    XCTAssertEqual(((LCDiffChange *)changes[2]).aInsert.item, @"c");
    XCTAssertEqual(((LCDiffChange *)changes[2]).aInsert.indexPath.row, 2);
    
    XCTAssertEqual(((LCDiffChange *)changes[3]).aInsert.item, @"d");
    XCTAssertEqual(((LCDiffChange *)changes[3]).aInsert.indexPath.row, 3);
}

- (void)testAllDelete
{
    NSArray *oldItems = @[@"a", @"b", @"c", @"d"];
    NSArray *newItems = @[];
    
    NSArray *changes = [self.diffManager diff:oldItems newItems:newItems];
    XCTAssertEqual(changes.count, 4);
    
    XCTAssertEqual(((LCDiffChange *)changes[0]).aDelete.item, @"a");
    XCTAssertEqual(((LCDiffChange *)changes[0]).aDelete.indexPath.row, 0);
    
    XCTAssertEqual(((LCDiffChange *)changes[1]).aDelete.item, @"b");
    XCTAssertEqual(((LCDiffChange *)changes[1]).aDelete.indexPath.row, 1);
    
    XCTAssertEqual(((LCDiffChange *)changes[2]).aDelete.item, @"c");
    XCTAssertEqual(((LCDiffChange *)changes[2]).aDelete.indexPath.row, 2);
    
    XCTAssertEqual(((LCDiffChange *)changes[3]).aDelete.item, @"d");
    XCTAssertEqual(((LCDiffChange *)changes[3]).aDelete.indexPath.row, 3);
}

- (void)testReplace
{
    NSArray *oldItems = @[@"a", @"b", @"c"];
    NSArray *newItems = @[@"a", @"B", @"c", @"c"];
    
    NSArray *changes = [self.diffManager diff:oldItems newItems:newItems];
    XCTAssertEqual(changes.count, 3);
    
    XCTAssertEqual(((LCDiffChange *)changes[0]).aDelete.item, @"b");
    XCTAssertEqual(((LCDiffChange *)changes[0]).aDelete.indexPath.row, 1);
    
    XCTAssertEqual(((LCDiffChange *)changes[1]).aInsert.item, @"B");
    XCTAssertEqual(((LCDiffChange *)changes[1]).aInsert.indexPath.row, 1);
}

- (void)testAllReplace
{
    NSArray *oldItems = @[@"a", @"b", @"c"];
    NSArray *newItems = @[@"A", @"B", @"C"];
    
    NSArray *changes = [self.diffManager diff:oldItems newItems:newItems];
    XCTAssertEqual(changes.count, 6);
    
    XCTAssertEqual(((LCDiffChange *)changes[0]).aDelete.item, @"a");
    XCTAssertEqual(((LCDiffChange *)changes[0]).aDelete.indexPath.row, 0);
    
    XCTAssertEqual(((LCDiffChange *)changes[1]).aDelete.item, @"b");
    XCTAssertEqual(((LCDiffChange *)changes[1]).aDelete.indexPath.row, 1);
    
    XCTAssertEqual(((LCDiffChange *)changes[2]).aDelete.item, @"c");
    XCTAssertEqual(((LCDiffChange *)changes[2]).aDelete.indexPath.row, 2);
    
    XCTAssertEqual(((LCDiffChange *)changes[3]).aInsert.item, @"A");
    XCTAssertEqual(((LCDiffChange *)changes[3]).aInsert.indexPath.row, 0);
    
    XCTAssertEqual(((LCDiffChange *)changes[4]).aInsert.item, @"B");
    XCTAssertEqual(((LCDiffChange *)changes[4]).aInsert.indexPath.row, 1);
    
    XCTAssertEqual(((LCDiffChange *)changes[5]).aInsert.item, @"C");
    XCTAssertEqual(((LCDiffChange *)changes[5]).aInsert.indexPath.row, 2);
}

- (void)testSamePrefix
{
    NSArray *oldItems = @[@"a", @"b", @"c"];
    NSArray *newItems = @[@"a", @"B"];
    
    NSArray *changes = [self.diffManager diff:oldItems newItems:newItems];
    XCTAssertEqual(changes.count, 3);
    
    XCTAssertEqual(((LCDiffChange *)changes[0]).aDelete.item, @"b");
    XCTAssertEqual(((LCDiffChange *)changes[0]).aDelete.indexPath.row, 1);
    
    XCTAssertEqual(((LCDiffChange *)changes[1]).aDelete.item, @"c");
    XCTAssertEqual(((LCDiffChange *)changes[1]).aDelete.indexPath.row, 2);
    
    XCTAssertEqual(((LCDiffChange *)changes[2]).aInsert.item, @"B");
    XCTAssertEqual(((LCDiffChange *)changes[2]).aInsert.indexPath.row, 1);
}

- (void)testReversed
{
    NSArray *oldItems = @[@"a", @"b", @"c"];
    NSArray *newItems = @[@"c", @"b", @"a"];
    
    NSArray *changes = [self.diffManager diff:oldItems newItems:newItems];
    XCTAssertEqual(changes.count, 1);
    
    XCTAssertNotNil(((LCDiffChange *)changes[0]).aMove);
}

- (void)testSmallChangeAtEdge
{
    NSArray *oldItems = @[@"s", @"i", @"t", @"t", @"i", @"n", @"g"];
    NSArray *newItems = @[@"k", @"i", @"t", @"t", @"e", @"n"];
    
    NSArray *changes = [self.diffManager diff:oldItems newItems:newItems];
    XCTAssertEqual(changes.count, 5);
    
    XCTAssertEqual(((LCDiffChange *)changes[0]).aDelete.item, @"s");
    XCTAssertEqual(((LCDiffChange *)changes[1]).aDelete.item, @"i");
    XCTAssertEqual(((LCDiffChange *)changes[2]).aDelete.item, @"g");
    XCTAssertEqual(((LCDiffChange *)changes[3]).aInsert.item, @"k");
    XCTAssertEqual(((LCDiffChange *)changes[4]).aInsert.item, @"e");
}

- (void)testSmallChange2AtEdge
{
    NSArray *oldItems = @[@"s", @"a", @"i", @"t", @"t", @"i", @"n", @"g"];
    NSArray *newItems = @[@"k", @"i", @"t", @"t", @"e", @"n"];
    
    NSArray *changes = [self.diffManager diff:oldItems newItems:newItems];
    XCTAssertEqual(changes.count, 6);
    
    XCTAssertEqual(((LCDiffChange *)changes[0]).aDelete.item, @"s");
    XCTAssertEqual(((LCDiffChange *)changes[1]).aDelete.item, @"a");
    XCTAssertEqual(((LCDiffChange *)changes[2]).aDelete.item, @"i");
    XCTAssertEqual(((LCDiffChange *)changes[3]).aDelete.item, @"g");
    XCTAssertEqual(((LCDiffChange *)changes[4]).aInsert.item, @"k");
    XCTAssertEqual(((LCDiffChange *)changes[5]).aInsert.item, @"e");
}

- (void)testSamePostfix
{
    NSArray *oldItems = @[@"a", @"b", @"c", @"d", @"e", @"f"];
    NSArray *newItems = @[@"d", @"e", @"f"];
    
    NSArray *changes = [self.diffManager diff:oldItems newItems:newItems];
    XCTAssertEqual(changes.count, 3);
    
    XCTAssertEqual(((LCDiffChange *)changes[0]).aDelete.item, @"a");
    XCTAssertEqual(((LCDiffChange *)changes[0]).aDelete.indexPath.row, 0);
    
    XCTAssertEqual(((LCDiffChange *)changes[1]).aDelete.item, @"b");
    XCTAssertEqual(((LCDiffChange *)changes[1]).aDelete.indexPath.row, 1);
    
    XCTAssertEqual(((LCDiffChange *)changes[2]).aDelete.item, @"c");
    XCTAssertEqual(((LCDiffChange *)changes[2]).aDelete.indexPath.row, 2);
}

- (void)testShift
{
    NSArray *oldItems = @[@"a", @"b", @"c", @"d"];
    NSArray *newItems = @[@"c", @"d", @"e", @"f"];
    
    NSArray *changes = [self.diffManager diff:oldItems newItems:newItems];
    XCTAssertEqual(changes.count, 4);
    
    XCTAssertEqual(((LCDiffChange *)changes[0]).aDelete.item, @"a");
    XCTAssertEqual(((LCDiffChange *)changes[0]).aDelete.indexPath.row, 0);
    
    XCTAssertEqual(((LCDiffChange *)changes[1]).aDelete.item, @"b");
    XCTAssertEqual(((LCDiffChange *)changes[1]).aDelete.indexPath.row, 1);
    
    XCTAssertEqual(((LCDiffChange *)changes[2]).aInsert.item, @"e");
    XCTAssertEqual(((LCDiffChange *)changes[2]).aInsert.indexPath.row, 2);
    
    XCTAssertEqual(((LCDiffChange *)changes[3]).aInsert.item, @"f");
    XCTAssertEqual(((LCDiffChange *)changes[3]).aInsert.indexPath.row, 3);
}

- (void)testReplaceWholeNewWorld
{
    NSArray *oldItems = @[@"a", @"b", @"c"];
    NSArray *newItems = @[@"d"];
    
    NSArray *changes = [self.diffManager diff:oldItems newItems:newItems];
    XCTAssertEqual(changes.count, 4);
    
    XCTAssertNotNil(((LCDiffChange *)changes[0]).aDelete);
    XCTAssertNotNil(((LCDiffChange *)changes[1]).aDelete);
    XCTAssertNotNil(((LCDiffChange *)changes[2]).aDelete);
    XCTAssertNotNil(((LCDiffChange *)changes[3]).aInsert);
}

- (void)testReplace1character
{
    NSArray *oldItems = @[@"a"];
    NSArray *newItems = @[@"b"];
    
    NSArray *changes = [self.diffManager diff:oldItems newItems:newItems];
    XCTAssertEqual(changes.count, 2);
    
    XCTAssertNotNil(((LCDiffChange *)changes[0]).aDelete);
    XCTAssertNotNil(((LCDiffChange *)changes[1]).aInsert);
}

- (void)testDeleteUntilOne
{
    NSArray *oldItems = @[@"a", @"b", @"c", @"d", @"e"];
    NSArray *newItems = @[@"a"];
    
    NSArray *changes = [self.diffManager diff:oldItems newItems:newItems];
    XCTAssertEqual(changes.count, 4);
    
    XCTAssertEqual(((LCDiffChange *)changes[0]).aDelete.item, @"b");
    XCTAssertEqual(((LCDiffChange *)changes[0]).aDelete.indexPath.row, 1);
    
    XCTAssertEqual(((LCDiffChange *)changes[1]).aDelete.item, @"c");
    XCTAssertEqual(((LCDiffChange *)changes[1]).aDelete.indexPath.row, 2);
    
    XCTAssertEqual(((LCDiffChange *)changes[2]).aDelete.item, @"d");
    XCTAssertEqual(((LCDiffChange *)changes[2]).aDelete.indexPath.row, 3);
    
    XCTAssertEqual(((LCDiffChange *)changes[3]).aDelete.item, @"e");
    XCTAssertEqual(((LCDiffChange *)changes[3]).aDelete.indexPath.row, 4);
}

- (void)testObjectReplace
{
    NSArray *oldItems = @[
                          [[LCDUser alloc] initWithName:@"Bei jing" age:10],
                          [[LCDUser alloc] initWithName:@"Shang hai" age:20],
                          [[LCDUser alloc] initWithName:@"Shen zhen" age:30]
                          ];
    NSArray *newItems = @[
                          [[LCDUser alloc] initWithName:@"Bei jing" age:10],
                          [[LCDUser alloc] initWithName:@"Bei hai" age:20],
                          [[LCDUser alloc] initWithName:@"Shen zhen" age:30]
                          ];
    
    NSArray *changes = [self.diffManager diff:oldItems newItems:newItems];
    XCTAssertEqual(changes.count, 2);
    
    XCTAssertNotNil(((LCDiffChange *)changes[0]).aDelete);
    XCTAssertNotNil(((LCDiffChange *)changes[1]).aInsert);
}

@end
