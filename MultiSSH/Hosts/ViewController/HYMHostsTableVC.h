//
//  HYMHostsTableVC.h
//  MultiSSH
//
//  Created by huangyimin on 2018/10/16.
//  Copyright © 2018 huangyimin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HYMGradientBar : NSButton

@end

@interface HYMHostsTableVC : NSViewController

@property (weak) IBOutlet NSButton *checkboxAll;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSMenu *editMenu;
@property (weak) IBOutlet HYMGradientBar *bg;

@end
