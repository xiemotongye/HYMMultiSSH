//
//  HYMHost.m
//  MultiSSH
//
//  Created by huangyimin on 2018/10/16.
//  Copyright © 2018 huangyimin. All rights reserved.
//

#import "HYMHost.h"
#import "HYMHostsManager.h"

@implementation HYMHost

- (instancetype)init {
    self = [super init];
    if (self) {
        _isChoosen = YES;
        _status = HYMHostStatusOffline;
    }
    return self;
}

@end
