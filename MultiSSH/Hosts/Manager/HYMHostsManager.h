//
//  HYMHostsManager.h
//  MultiSSH
//
//  Created by huangyimin on 2018/10/16.
//  Copyright © 2018 huangyimin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYMHost.h"

static NSString * const kSelectedHostChanged = @"HYMSelectedHostChanged";

@interface HYMHostsManager : NSObject

@property (nonatomic, strong) NSMutableArray<HYMHost *> *hosts;
@property (nonatomic, assign) NSUInteger selectedIndex;

+ (instancetype)sharedManager;

- (void)addHost:(HYMHost *)host;
- (void)removeHost:(HYMHost *)host;
- (void)dulplicateHost:(HYMHost *)host;
- (void)editHost:(HYMHost *)orgHost withNewHost:(HYMHost *)newHost;

@end
