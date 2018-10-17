//
//  HYMHost.m
//  MultiSSH
//
//  Created by huangyimin on 2018/10/16.
//  Copyright © 2018 huangyimin. All rights reserved.
//

#import "HYMHost.h"
#import "HYMHostsManager.h"

@interface HYMHost () <NSCoding>

@end

@implementation HYMHost

- (instancetype)init {
    self = [super init];
    if (self) {
        _isChoosen = YES;
        _status = HYMHostStatusOffline;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.host = [aDecoder decodeObjectForKey:@"host"];
        self.userName = [aDecoder decodeObjectForKey:@"userName"];
        self.password = [aDecoder decodeObjectForKey:@"password"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.host forKey:@"host"];
    [aCoder encodeObject:self.userName forKey:@"userName"];
    [aCoder encodeObject:self.password forKey:@"password"];
}

@end
