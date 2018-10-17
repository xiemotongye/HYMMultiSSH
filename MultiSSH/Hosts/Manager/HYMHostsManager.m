//
//  HYMHostsManager.m
//  MultiSSH
//
//  Created by huangyimin on 2018/10/16.
//  Copyright © 2018 huangyimin. All rights reserved.
//

#import "HYMHostsManager.h"

static NSString * const kLocalStorageFile = @"my_hosts_config";

@implementation HYMHostsManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static HYMHostsManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [HYMHostsManager new];
        manager.hosts = [NSMutableArray new];
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(synchronize) name:kHostAdded object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(synchronize) name:kHostRemoved object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(synchronize) name:kHostModified object:nil];
        
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [docPath stringByAppendingPathComponent:kLocalStorageFile];
        if ([NSKeyedUnarchiver unarchiveObjectWithFile:path]) {
            manager.hosts = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        }
    });
    return manager;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (_selectedIndex != selectedIndex) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedHostChanged object:[NSNumber numberWithUnsignedInteger:selectedIndex]];
        _selectedIndex = selectedIndex;
    }
}

- (void)synchronize {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [docPath stringByAppendingPathComponent:kLocalStorageFile];
    [NSKeyedArchiver archiveRootObject:self.hosts toFile:path];
}
@end
