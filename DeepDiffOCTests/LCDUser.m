//
//  LCDUser.m
//  DeepDiffOCTests
//
//  Created by bingolin on 2018/1/23.
//  Copyright © 2018年 bingolin. All rights reserved.
//

#import "LCDUser.h"

@implementation LCDUser

- (instancetype)initWithName:(NSString *)name age:(NSInteger)age
{
    if (self = [super init]) {
        _name = name;
        _age = @(age);
    }
    return self;
}

- (NSUInteger)hash
{
    return [self.name hash] & [self.age hash];
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    }
    else {
        LCDUser *tOther = (LCDUser *)other;
        return [self.name isEqualToString:tOther.name] && [self.age isEqual:tOther.age];
    }
}

- (id<NSObject>)diffIdentifier {
    return self.name;
}

@end
