//
//  LCDiffIGHeckle.m
//  DeepDiffOC
//
//  Created by bingolin on 2018/3/20.
//  Copyright © 2018年 bingolin. All rights reserved.
//

#import "LCDiffIGHeckle.h"

#import "IGListMoveIndex.h"
#import "LCDeepDiff.h"

#import <stack>
#import <unordered_map>
#import <vector>

using namespace std;

/// Used to track data stats while diffing.
struct IGListEntry {
    /// The number of times the data occurs in the old array
    NSInteger oldCounter = 0;
    /// The number of times the data occurs in the new array
    NSInteger newCounter = 0;
    /// The indexes of the data in the old array
    stack<NSInteger> oldIndexes;
    /// Flag marking if the data has been updated between arrays by checking the isEqual: method
    BOOL updated = NO;
};

/// Track both the entry and algorithm index. Default the index to NSNotFound
struct IGListRecord {
    IGListEntry *entry;
    mutable NSInteger index;
    
    IGListRecord() {
        entry = NULL;
        index = NSNotFound;
    }
};

struct IGListHashID {
    size_t operator()(const id o) const {
        return (size_t)[o hash];
    }
};

struct IGListEqualID {
    bool operator()(const id a, const id b) const {
        return (a == b) || [a isEqual: b];
    }
};

static id<NSObject> IGListTableKey(__unsafe_unretained id<IGListDiffable> object) {
    id<NSObject> key = [object diffIdentifier];
    NSCAssert(key != nil, @"Cannot use a nil key for the diffIdentifier of object %@", object);
    return key;
}

@implementation LCDiffIGHeckle

- (NSArray<LCDiffChange *> *)diff:(NSArray *)oldArray newItems:(NSArray *)newArray
{
    const NSInteger newCount = newArray.count;
    const NSInteger oldCount = oldArray.count;
    
    NSMapTable *oldMap = [NSMapTable strongToStrongObjectsMapTable];
    NSMapTable *newMap = [NSMapTable strongToStrongObjectsMapTable];
    
    // symbol table uses the old/new array diffIdentifier as the key and IGListEntry as the value
    // using id<NSObject> as the key provided by https://lists.gnu.org/archive/html/discuss-gnustep/2011-07/msg00019.html
    unordered_map<id<NSObject>, IGListEntry, IGListHashID, IGListEqualID> table;
    
    // pass 1
    // create an entry for every item in the new array
    // increment its new count for each occurence
    vector<IGListRecord> newResultsArray(newCount);
    for (NSInteger i = 0; i < newCount; i++) {
        id<NSObject> key = IGListTableKey(newArray[i]);
        IGListEntry &entry = table[key];
        entry.newCounter++;
        
        // add NSNotFound for each occurence of the item in the new array
        entry.oldIndexes.push(NSNotFound);
        
        // note: the entry is just a pointer to the entry which is stack-allocated in the table
        newResultsArray[i].entry = &entry;
    }
    
    // pass 2
    // update or create an entry for every item in the old array
    // increment its old count for each occurence
    // record the original index of the item in the old array
    // MUST be done in descending order to respect the oldIndexes stack construction
    vector<IGListRecord> oldResultsArray(oldCount);
    for (NSInteger i = oldCount - 1; i >= 0; i--) {
        id<NSObject> key = IGListTableKey(oldArray[i]);
        IGListEntry &entry = table[key];
        entry.oldCounter++;
        
        // push the original indices where the item occurred onto the index stack
        entry.oldIndexes.push(i);
        
        // note: the entry is just a pointer to the entry which is stack-allocated in the table
        oldResultsArray[i].entry = &entry;
    }
    
    // pass 3
    // handle data that occurs in both arrays
    for (NSInteger i = 0; i < newCount; i++) {
        IGListEntry *entry = newResultsArray[i].entry;
        
        // grab and pop the top original index. if the item was inserted this will be NSNotFound
        NSCAssert(!entry->oldIndexes.empty(), @"Old indexes is empty while iterating new item %zi. Should have NSNotFound", i);
        const NSInteger originalIndex = entry->oldIndexes.top();
        entry->oldIndexes.pop();
        
        if (originalIndex < oldCount) {
            const id<IGListDiffable> n = newArray[i];
            const id<IGListDiffable> o = oldArray[originalIndex];
            if (n != o && ![n isEqualToDiffableObject:o]) {
                entry->updated = YES;
            }
        }
        if (originalIndex != NSNotFound
            && entry->newCounter > 0
            && entry->oldCounter > 0) {
            // if an item occurs in the new and old array, it is unique
            // assign the index of new and old records to the opposite index (reverse lookup)
            newResultsArray[i].index = originalIndex;
            oldResultsArray[originalIndex].index = i;
        }
    }
    
    // storage for final NSIndexPaths or indexes
    id mInserts, mMoves, mUpdates, mDeletes;
    mInserts = [NSMutableIndexSet new];
    mUpdates = [NSMutableIndexSet new];
    mDeletes = [NSMutableIndexSet new];
    mMoves = [NSMutableArray<IGListMoveIndex *> new];
    NSMutableArray *result = [NSMutableArray new];
    
    // track offsets from deleted items to calculate where items have moved
    vector<NSInteger> deleteOffsets(oldCount), insertOffsets(newCount);
    NSInteger runningOffset = 0;
    
    // iterate old array records checking for deletes
    // incremement offset for each delete
    for (NSInteger i = 0; i < oldCount; i++) {
        deleteOffsets[i] = runningOffset;
        const IGListRecord record = oldResultsArray[i];
        // if the record index in the new array doesn't exist, its a delete
        if (record.index == NSNotFound) {
            [mDeletes addIndex:i];
            runningOffset++;
            
            LCDiffDelete *aDelete = [[LCDiffDelete alloc] initWithItem:[(LCDiffModel *)oldArray[i] item] indexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            LCDiffChange *change = [[LCDiffChange alloc] initWithDelete:aDelete];
            [result addObject:change];
        }
        
        [oldMap setObject:@(i) forKey:[oldArray[i] diffIdentifier]];
    }
    
    // reset and track offsets from inserted items to calculate where items have moved
    runningOffset = 0;
    
    for (NSInteger i = 0; i < newCount; i++) {
        insertOffsets[i] = runningOffset;
        const IGListRecord record = newResultsArray[i];
        const NSInteger oldIndex = record.index;
        // add to inserts if the opposing index is NSNotFound
        if (record.index == NSNotFound) {
            [mInserts addIndex:i];
            runningOffset++;
            
            LCDiffInsert *aInsert = [[LCDiffInsert alloc] initWithItem:[(LCDiffModel *)newArray[i] item] indexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            LCDiffChange *change = [[LCDiffChange alloc] initWithInsert:aInsert];
            [result addObject:change];
        }
        else {
            // note that an entry can be updated /and/ moved
            if (record.entry->updated) {
                [mUpdates addIndex:oldIndex];
            }
            
            // calculate the offset and determine if there was a move
            // if the indexes match, ignore the index
            const NSInteger insertOffset = insertOffsets[i];
            const NSInteger deleteOffset = deleteOffsets[oldIndex];
            if ((oldIndex - deleteOffset + insertOffset) != i) {
                id move = [[IGListMoveIndex alloc] initWithFrom:oldIndex to:i];
                [mMoves addObject:move];
                
                LCDiffMove *aMove = [[LCDiffMove alloc] initWithItem:[(LCDiffModel *)newArray[i] item] fromIndexPath:[NSIndexPath indexPathForRow:oldIndex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                LCDiffChange *change = [[LCDiffChange alloc] initWithMove:aMove];
                [result addObject:change];
            }
        }
        
        [newMap setObject:@(i) forKey:[newArray[i] diffIdentifier]];
    }
    
    NSCAssert((oldCount + [mInserts count] - [mDeletes count]) == newCount,
              @"Sanity check failed applying %zi inserts and %zi deletes to old count %zi equaling new count %zi",
              oldCount, [mInserts count], [mDeletes count], newCount);
    
    return result;
}

@end
