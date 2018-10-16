//
//  HYMTerminalVC.h
//  MultiSSH
//
//  Created by huangyimin on 2018/10/15.
//  Copyright © 2018 huangyimin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HYMHost.h"

@interface HYMTerminalVC : NSViewController

@property (weak) IBOutlet NSTextView *textView;
@property (nonatomic, strong) HYMHost *theHost;

@end
