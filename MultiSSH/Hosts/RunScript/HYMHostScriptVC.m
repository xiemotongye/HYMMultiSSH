//
//  HYMHostScriptVC.m
//  MultiSSH
//
//  Created by huangyimin on 2018/10/17.
//  Copyright © 2018 huangyimin. All rights reserved.
//

#import "HYMHostScriptVC.h"

@interface HYMHostScriptVC ()

@end

@implementation HYMHostScriptVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)clearScript:(id)sender {
    self.txtScript.string = @"";
}

@end
