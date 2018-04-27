//
//  ViewController.m
//  DeepDiffOC
//
//  Created by bingolin on 2018/1/23.
//  Copyright © 2018年 bingolin. All rights reserved.
//

#import "ViewController.h"

#import "LCDUser.h"
#import "LCDeepDiff.h"
#import "UITableView+DeepDiff.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) LCDiffManager *diffManager;

@property (strong, nonatomic) UITableViewChangeAnimation *animation;

@property (strong, nonatomic) NSMutableArray<LCDUser *> *data;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    
    self.diffManager = [[LCDiffManager alloc] init];
    self.animation = [[UITableViewChangeAnimation alloc] init];
}

- (NSArray<LCDUser *> *)data
{
    if (!_data) {
        int count = (arc4random() % 100) + 1;
        _data = [[NSMutableArray alloc] initWithCapacity:count];
        for (int index = count - 1; index >= 0; index--) {
            LCDUser *user = [[LCDUser alloc] initWithName:[NSString stringWithFormat:@"%d", index] age:index];
            [_data addObject:user];
        }
    }
    return _data;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdent = @"UITableViewCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdent];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdent];
    }
    
    LCDUser *user = self.data[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", user.name];
    
    return cell;
}

- (IBAction)insertButtonClick:(id)sender
{
    NSArray *oldData = [NSArray arrayWithArray:self.data];
    
    LCDUser *user1 = [[LCDUser alloc] initWithName:[NSString stringWithFormat:@"%zi", self.data.count] age:self.data.count];
    [self.data insertObject:user1 atIndex:0];
    LCDUser *user2 = [[LCDUser alloc] initWithName:[NSString stringWithFormat:@"%zi", self.data.count] age:self.data.count];
    [self.data insertObject:user2 atIndex:0];
    
    NSArray *changes = [self.diffManager diff:oldData newItems:[self.data copy]];
    [self.tableView reloadDataWithChanges:changes section:0 startIndex:0 withRowAnimations:self.animation completion:^(BOOL finished) {
        NSLog(@"insert finish!");
    }];
}

- (IBAction)deleteButtonClick:(id)sender
{
    NSArray *oldData = [NSArray arrayWithArray:self.data];
    
    [self.data removeObjectAtIndex:0];
    
    NSArray *changes = [self.diffManager diff:oldData newItems:[self.data copy]];
    [self.tableView reloadDataWithChanges:changes section:0 startIndex:0 withRowAnimations:self.animation completion:^(BOOL finished) {
        NSLog(@"delete finish!");
    }];
}

- (IBAction)moveButtonClick:(id)sender
{
    NSArray *oldData = [NSArray arrayWithArray:self.data];
    
    LCDUser *user = self.data[0];
    [self.data removeObjectAtIndex:0];
    [self.data insertObject:user atIndex:1];
    
    NSArray *changes = [self.diffManager diff:oldData newItems:[self.data copy]];
    [self.tableView reloadDataWithChanges:changes section:0 startIndex:0 withRowAnimations:self.animation completion:^(BOOL finished) {
        NSLog(@"move finish!");
    }];
}

- (IBAction)replaceButtonClick:(id)sender
{
    NSArray *oldData = [NSArray arrayWithArray:self.data];
    
    NSInteger number = (arc4random() % 1000) + 100;
    LCDUser *newUser = [[LCDUser alloc] initWithName:[NSString stringWithFormat:@"%zi", number] age:number];
    self.data[0] = newUser;
    
    NSArray *changes = [self.diffManager diff:oldData newItems:[self.data copy]];
    [self.tableView reloadDataWithChanges:changes section:0 startIndex:0 withRowAnimations:self.animation completion:^(BOOL finished) {
        NSLog(@"replace finish!");
    }];
}

- (IBAction)insertAndDeleteButtonClick:(id)sender
{
    NSArray *oldData = [NSArray arrayWithArray:self.data];
    
    [self.data removeObjectAtIndex:3];
    NSInteger number = (arc4random() % 1000) + 100;
    LCDUser *newUser = [[LCDUser alloc] initWithName:[NSString stringWithFormat:@"%zi", number] age:number];
    [self.data insertObject:newUser atIndex:1];
    
    NSArray *changes = [self.diffManager diff:oldData newItems:[self.data copy]];
    [self.tableView reloadDataWithChanges:changes section:0 startIndex:0 withRowAnimations:self.animation completion:^(BOOL finished) {
        NSLog(@"replace finish!");
    }];
}

@end
