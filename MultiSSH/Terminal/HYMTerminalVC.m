//
//  HYMTerminalVC.m
//  MultiSSH
//
//  Created by huangyimin on 2018/10/15.
//  Copyright © 2018 huangyimin. All rights reserved.
//

#import "HYMTerminalVC.h"
#import "HYMHostsManager.h"
#import "NMSSH.h"

@interface HYMTerminalVC () <NMSSHSessionDelegate, NMSSHChannelDelegate, NSTextViewDelegate>

@property (nonatomic, strong) dispatch_queue_t sshQueue;
@property (nonatomic, strong) NMSSHSession *session;
@property (nonatomic, assign) dispatch_once_t onceToken;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) NSMutableString *lastCommand;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *password;

@end

@implementation HYMTerminalVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(runScript:) name:kRunScript object:nil];
    
    self.textView.editable = NO;
    self.textView.selectable = NO;
    self.textView.delegate = self;
    self.lastCommand = [[NSMutableString alloc] init];
    self.host = self.theHost.host;
    self.userName = self.theHost.userName;
    self.password = self.theHost.password;
    
    self.sshQueue = dispatch_queue_create("NMSSH.queue", DISPATCH_QUEUE_SERIAL);
}

- (void)viewDidAppear {
    [super viewDidAppear];

    dispatch_once(&_onceToken, ^{
        [self connect:nil];
    });
}

- (void)dealloc {
    [self.session disconnect:nil];
}

- (void)performCommand {
    if (self.semaphore) {
        self.password = [self.lastCommand substringToIndex:MAX(0, self.lastCommand.length - 1)];
        dispatch_semaphore_signal(self.semaphore);
    }
    else {
        NSString *command = [self.lastCommand copy];
        dispatch_async(self.sshQueue, ^{
            [[self.session channel] writeCommand:command timeout:@10 success:nil failure:nil];
        });
    }
    
    [self.lastCommand setString:@""];
}

- (void)connect:(void(^)(NMSSHSession *))complete {
    dispatch_async(self.sshQueue, ^{
        self.session = [NMSSHSession connectToHost:self.host withUsername:self.userName complete:^(NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self appendToTextView:@"Connection error"];
                    self.theHost.status = HYMHostStatusOffline;
                    [[NSNotificationCenter defaultCenter] postNotificationName:kHostStatusChanged object:nil];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self appendToTextView:[NSString stringWithFormat:@"ssh %@@%@\n", self.session.username, self.host]];
                });
                
                [self.session authenticateByPassword:self.password success:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.textView.editable = YES;
                    });
                    self.session.channel.delegate = self;
                    self.session.channel.requestPty = YES;
                    
                    [self.session.channel startShell:^{
                        self.theHost.status = HYMHostStatusOnline;
                        [[NSNotificationCenter defaultCenter] postNotificationName:kHostStatusChanged object:nil];
                    } failure:^(NSError *error) {
                        if (error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self appendToTextView:error.localizedDescription];
                                self.textView.editable = NO;
                                self.theHost.status = HYMHostStatusOffline;
                                [[NSNotificationCenter defaultCenter] postNotificationName:kHostStatusChanged object:nil];
                            });
                        }
                    }];
                    if (complete) {
                        complete(self.session);
                    }
                } failure:^(NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self appendToTextView:@"Authentication error\n"];
                        self.theHost.status = HYMHostStatusOffline;
                        [[NSNotificationCenter defaultCenter] postNotificationName:kHostStatusChanged object:nil];
                        self.textView.editable = NO;
                    });
                }];
            }
        }];
        self.session.delegate = self;
    });
    
}

- (void)disconnect:(id)sender {
    dispatch_async(self.sshQueue, ^{
        [self.session disconnect:nil];
    });
}

- (void)appendToTextView:(NSString *)text {
    self.textView.string = [NSString stringWithFormat:@"%@%@", self.textView.string, text];
    [self.textView scrollRangeToVisible:NSMakeRange([self.textView.string length] - 1, 1)];
}

#pragma mark - NMSSHChannelDelegate
- (void)channel:(NMSSHChannel *)channel didReadData:(NSString *)message {
    NSString *msg = [message copy];
    
    if ([msg isEqualToString:@"Password:"]) {
        NSString *newCommand = [NSString stringWithFormat:@"%@\n", self.password];
        dispatch_async(self.sshQueue, ^{
            [[self.session channel] writeCommand:newCommand timeout:@10 success:nil failure:nil];
        });
    } else if ([msg containsString:@"(yes/no)"]) {
        dispatch_async(self.sshQueue, ^{
            [[self.session channel] writeCommand:@"yes\n" timeout:@10 success:nil failure:nil];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendToTextView:msg];
    });
}

- (void)channel:(NMSSHChannel *)channel didReadError:(NSString *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendToTextView:[NSString stringWithFormat:@"[ERROR] %@", error]];
    });
}

- (void)channelShellDidClose:(NMSSHChannel *)channel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendToTextView:@"\nShell closed\n"];
        self.textView.editable = NO;
    });
}

#pragma mark - NMSSHSessionDelegate
- (NSString *)session:(NMSSHSession *)session keyboardInteractiveRequest:(NSString *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendToTextView:request];
        self.textView.editable = YES;
    });
    
    self.semaphore = dispatch_semaphore_create(0);
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    self.semaphore = nil;
    
    return self.password;
}

- (void)session:(NMSSHSession *)session didDisconnectWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendToTextView:[NSString stringWithFormat:@"\nDisconnected with error: %@", error.localizedDescription]];
        
        self.textView.editable = NO;
    });
}

#pragma mark - NSTextViewDelegate
- (void)textViewDidChangeSelection:(NSNotification *)notification {
    [self.textView scrollRangeToVisible:NSMakeRange([self.textView.string length] - 1, 1)];

    if ((signed long)(self.textView.selectedRange.location) < (signed long)(self.textView.string.length - self.lastCommand.length - 1)) {
        self.textView.selectedRange = NSMakeRange(self.textView.string.length, 0);
    }
}

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(nullable NSString *)replacementString {
    if (replacementString.length == 0) {
        
        if ([self.lastCommand length] > 0) {
            [self.lastCommand replaceCharactersInRange:NSMakeRange(self.lastCommand.length-1, 1) withString:@""];
            return YES;
        }
        else {
            return NO;
        }
    }
    
    [self.lastCommand appendString:replacementString];
    
    if ([replacementString isEqualToString:@"\n"]) {
        [self performCommand];
    }
    
    return YES;
}

#pragma mark - Notifications
- (void)runScript:(id)sender {
    if (!self.theHost.isChoosen || self.theHost.status == HYMHostStatusOffline) {
        return;
    }
    NSString *scriptContent = [sender object];
    NSError *error = nil;
    NSString *scriptPath = @"/private/tmp/my_script.sh";
    [scriptContent writeToFile:scriptPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    [[self.session channel] uploadFile:scriptPath to:scriptPath progress:nil success:^{
        [self connect:^(NMSSHSession *session) {
            NSString *newCommand = [NSString stringWithFormat:@"sh %@\n", scriptPath];
            dispatch_async(self.sshQueue, ^{
                [session.channel writeCommand:newCommand timeout:@10 success:nil failure:nil];
            });
        }];
    } failure:^(NSError *error) {
        [self connect:nil];
    }];
}
@end
