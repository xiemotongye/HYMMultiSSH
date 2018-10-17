//
//  HYMConfigWindowController.h
//  MultiSSH
//
//  Created by huangyimin on 2018/10/17.
//  Copyright © 2018 huangyimin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HYMHost.h"

typedef NS_ENUM(NSInteger, HYMConfigType) {
    HYMConfigTypeAdd = 0,
    HYMConfigTypeModify,
};

@interface HYMConfigWindowController : NSWindowController

@property (nonatomic, strong) HYMHost *host;
@property (nonatomic, assign) HYMConfigType configType;

@end
