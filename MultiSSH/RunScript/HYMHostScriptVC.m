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
    self.txtScript.continuousSpellCheckingEnabled = NO;
    self.txtScript.grammarCheckingEnabled = NO;
    self.txtScript.automaticQuoteSubstitutionEnabled = NO;
    self.txtScript.automaticDashSubstitutionEnabled = NO;
    self.txtScript.automaticTextReplacementEnabled = NO;
}

- (IBAction)clearScript:(id)sender {
    self.txtScript.string = @"";
}

- (IBAction)runScript:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HYMRunScript" object:self.txtScript.string];
}

@end
