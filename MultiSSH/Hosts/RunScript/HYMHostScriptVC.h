//
//  HYMHostScriptVC.h
//  MultiSSH
//
//  Created by huangyimin on 2018/10/17.
//  Copyright © 2018 huangyimin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HYMHostScriptVC : NSViewController

@property (weak) IBOutlet NSTextView *txtScript;
@property (weak) IBOutlet NSButton *btnClear;
@property (weak) IBOutlet NSButton *btnRun;

@end
