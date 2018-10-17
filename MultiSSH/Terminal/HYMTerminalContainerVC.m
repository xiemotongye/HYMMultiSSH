//
//  HYMTerminalContainerVC.m
//  MultiSSH
//
//  Created by huangyimin on 2018/10/16.
//  Copyright © 2018 huangyimin. All rights reserved.
//

#import "HYMTerminalContainerVC.h"
#import "HYMTerminalVC.h"
#import "HYMHostsManager.h"

@interface HYMTerminalContainerVC ()

@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation HYMTerminalContainerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeHost:) name:kSelectedHostChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addTerminal:) name:kHostAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeTerminal:) name:kHostRemoved object:nil];
    self.items = [NSMutableArray new];
    for (HYMHost *host in [HYMHostsManager sharedManager].hosts) {
        HYMTerminalVC *vc = [[HYMTerminalVC alloc] init];
        vc.theHost = host;
        
        [self.items addObject:vc];
        [self addTerminalView:vc];
    }
    
}

- (void)addTerminalView:(NSViewController *)vc {
    NSView *terminalView = vc.view;
    [self.view addSubview:terminalView positioned:NSWindowAbove relativeTo:nil];
    [self addChildViewController:vc];
    NSString *hVFL = @"H:|-0-[terminalView]-0-|";
    NSArray *hCons = [NSLayoutConstraint constraintsWithVisualFormat:hVFL options:0 metrics:nil views:@{@"terminalView":terminalView}];
    [self.view addConstraints:hCons];
    
    NSString *vVFL = @"V:|-0-[terminalView]-0-|";
    NSArray *vCons = [NSLayoutConstraint constraintsWithVisualFormat:vVFL options:0 metrics:nil views:@{@"terminalView":terminalView}];
    [self.view addConstraints:vCons];
}

- (void)changeHost:(id)sender {
    NSUInteger index = [[sender object] unsignedIntegerValue];
    NSViewController *vc = _items[index];
    [vc removeFromParentViewController];
    [vc.view removeFromSuperview];
    [self addTerminalView:vc];
}

- (void)addTerminal:(id)sender {
    HYMHost *host = [sender object];
    HYMTerminalVC *vc = [[HYMTerminalVC alloc] init];
    vc.theHost = host;
    
    [self.items addObject:vc];
    [self addTerminalView:vc];
}

- (void)removeTerminal:(id)sender {
    NSNumber *numIndex = [sender object];
    NSInteger index = [numIndex integerValue];
    NSViewController *vc = self.items[index];
    [self.items removeObjectAtIndex:index];
    [vc removeFromParentViewController];
    [vc.view removeFromSuperview];
}
@end
