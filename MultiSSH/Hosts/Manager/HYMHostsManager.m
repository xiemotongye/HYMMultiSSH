//
//  HYMHostsManager.m
//  MultiSSH
//
//  Created by huangyimin on 2018/10/16.
//  Copyright © 2018 huangyimin. All rights reserved.
//

#import "HYMHostsManager.h"

@implementation HYMHostsManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static HYMHostsManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [HYMHostsManager new];
        manager.hosts = [NSMutableArray new];
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(synchronize) name:kHostAdded object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(synchronize) name:kHostRemoved object:nil];
        
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
    
}
@end
