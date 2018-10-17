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
static NSString * const kHostAdded = @"HYMHostAdded";
static NSString * const kHostRemoved = @"HYMHostRemoved";
static NSString * const kHostModified = @"HYMHostModified";
static NSString * const kRunScript = @"HYMRunScript";
static NSString * const kHostStatusChanged = @"HYMHostStatusChanged";

@interface HYMHostsManager : NSObject

@property (nonatomic, strong) NSMutableArray<HYMHost *> *hosts;
@property (nonatomic, assign) NSUInteger selectedIndex;

+ (instancetype)sharedManager;
- (void)synchronize;

@end
