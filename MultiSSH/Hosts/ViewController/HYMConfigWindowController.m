//
//  HYMConfigWindowController.m
//  MultiSSH
//
//  Created by huangyimin on 2018/10/17.
//  Copyright © 2018 huangyimin. All rights reserved.
//

#import "HYMConfigWindowController.h"
#import "HYMHostsManager.h"
#import "HYMHost.h"

@interface HYMConfigWindowController ()

@property (weak) IBOutlet NSTextField *txtHostIP;
@property (weak) IBOutlet NSTextField *txtUserName;
@property (weak) IBOutlet NSSecureTextField *txtPassword;

@property (weak) IBOutlet NSTextField *lblHostIPValidator;
@property (weak) IBOutlet NSTextField *lblUserNameValidator;
@property (weak) IBOutlet NSTextField *lblPasswordValidator;
@end

@implementation HYMConfigWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (BOOL)isIPAddress:(NSString *)txt {
    NSString *regex = @"^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:txt];
}

- (IBAction)clickOK:(id)sender {
    self.lblHostIPValidator.hidden = YES;
    self.lblUserNameValidator.hidden = YES;
    self.lblPasswordValidator.hidden = YES;
    BOOL shouldAbort = NO;
    
    if (!self.txtHostIP.stringValue.length) {
        self.lblHostIPValidator.stringValue = @"Cannot be empty.";
        self.lblHostIPValidator.hidden = NO;
        shouldAbort = YES;
    } else if (![self isIPAddress:self.txtHostIP.stringValue]) {
        self.lblHostIPValidator.stringValue = @"Not an IP Address.";
        self.lblHostIPValidator.hidden = NO;
        shouldAbort = YES;
    }
    if (!self.txtUserName.stringValue.length) {
        self.lblUserNameValidator.hidden = NO;
        shouldAbort = YES;
    }
    if (!self.txtPassword.stringValue.length) {
        self.lblPasswordValidator.hidden = NO;
        shouldAbort = YES;
    }
    if (shouldAbort) {
        return;
    }
    
    [self addHost];
}

- (void)addHost {
    HYMHost *host = HYMHost.new;
    host.host = self.txtHostIP.stringValue;
    host.userName = self.txtUserName.stringValue;
    host.password = self.txtPassword.stringValue;
    [[HYMHostsManager sharedManager].hosts addObject:host];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHostAdded object:host];
    [self close];
}

@end
