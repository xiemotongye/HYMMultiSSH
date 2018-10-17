//
//  HYMHost.h
//  MultiSSH
//
//  Created by huangyimin on 2018/10/16.
//  Copyright © 2018 huangyimin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HYMHostStatus) {
    HYMHostStatusOffline = 0,
    HYMHostStatusOnline,
    HYMHostStatusRunning,
};

@interface HYMHost : NSObject

@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *password;

@property (nonatomic, assign) HYMHostStatus status;
@property (nonatomic, assign) BOOL isChoosen;

@end
