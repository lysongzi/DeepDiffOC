//
//  LCDUser.h
//  DeepDiffOCTests
//
//  Created by bingolin on 2018/1/23.
//  Copyright © 2018年 bingolin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCDUser : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSNumber *age;

- (instancetype)initWithName:(NSString *)name age:(NSInteger)age;

@end
