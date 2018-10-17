//
//  HYMHostsTableVC.m
//  MultiSSH
//
//  Created by huangyimin on 2018/10/16.
//  Copyright © 2018 huangyimin. All rights reserved.
//

#import "HYMHostsTableVC.h"
#import "HYMHostsManager.h"
#import "HYMConfigWindowController.h"

static NSString * const kCheckboxCellIdentifier = @"HYMCheckBoxID";
static NSString * const kHostCellIdentifier = @"HYMHostID";
static NSString * const kStatusCellIdentifier = @"HYMStatusID";

@implementation HYMGradientBar

- (NSView *)hitTest:(NSPoint)point {
    return nil;
}

@end

@interface HYMHostsTableVC ()<NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, strong) HYMConfigWindowController *configWindow;

@end

@implementation HYMHostsTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hostAdded:) name:kHostAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kHostStatusChanged object:nil];
    
    self.checkboxAll.objectValue = @0;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.editMenu.delegate = self;
}

- (void)hostAdded:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        
        NSInteger index = [[HYMHostsManager sharedManager].hosts indexOfObject:[sender object]];
        NSMutableIndexSet *idxSet = [[NSMutableIndexSet alloc] init];
        [idxSet addIndex:index];
        [self.tableView selectRowIndexes:idxSet byExtendingSelection:NO];
    });
}

- (void)refresh {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - IBActions
- (IBAction)clickCheckboxAll:(id)sender {
    if ([self.checkboxAll.objectValue isEqual:@0]) {
        for (HYMHost *host in [HYMHostsManager sharedManager].hosts) {
            host.isChoosen = NO;
        }
    } else {
        for (HYMHost *host in [HYMHostsManager sharedManager].hosts) {
            host.isChoosen = YES;
        }
    }
    [self.tableView reloadData];
}

- (IBAction)addHost:(id)sender {
    self.configWindow = [[HYMConfigWindowController alloc] initWithWindowNibName:@"HYMConfigWindowController"];
    self.configWindow.configType = HYMConfigTypeAdd;
    [self.configWindow showWindow:nil];
}

- (IBAction)removeHost:(id)sender {
    [[HYMHostsManager sharedManager].hosts removeObjectAtIndex:self.tableView.selectedRow];
    [[HYMHostsManager sharedManager] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHostRemoved object:[NSNumber numberWithInteger:self.tableView.selectedRow]];
    [self.tableView reloadData];
}

- (IBAction)duplicateHost:(id)sender {
    if (self.tableView.selectedRow < 0 || self.tableView.selectedRow >= [HYMHostsManager sharedManager].hosts.count) {
        return;
    }
    HYMHost *orgHost = [HYMHostsManager sharedManager].hosts[self.tableView.selectedRow];
    NSMutableArray *arrIP = [NSMutableArray arrayWithArray:[orgHost.host componentsSeparatedByString:@"."]];
    NSInteger newLastIPComponent = [[arrIP lastObject] integerValue] + 1;
    arrIP[arrIP.count - 1] = [NSString stringWithFormat:@"%ld", newLastIPComponent];
    
    HYMHost *newHost = HYMHost.new;
    newHost.host = [arrIP componentsJoinedByString:@"."];
    newHost.userName = orgHost.userName;
    newHost.password = orgHost.password;
    [[HYMHostsManager sharedManager].hosts addObject:newHost];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHostAdded object:newHost];
}

- (IBAction)modifyHost:(id)sender {
    if (self.tableView.selectedRow < 0 || self.tableView.selectedRow >= [HYMHostsManager sharedManager].hosts.count) {
        return;
    }
    self.configWindow = [[HYMConfigWindowController alloc] initWithWindowNibName:@"HYMConfigWindowController"];
    self.configWindow.configType = HYMConfigTypeModify;
    self.configWindow.host = [HYMHostsManager sharedManager].hosts[self.tableView.selectedRow];
    [self.configWindow showWindow:nil];
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [HYMHostsManager sharedManager].hosts.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // Check the column
    NSString *identifier = [tableColumn identifier];
    HYMHost *host = [HYMHostsManager sharedManager].hosts[row];
    
    // Get the unused image
    if ([identifier isEqualToString:kCheckboxCellIdentifier]) {
        if (host.isChoosen) {
            return @1;
        } else {
            return @0;
        }
    } else if ([identifier isEqualToString:kHostCellIdentifier]) {
        return host.host;
    } else if ([identifier isEqualToString:kStatusCellIdentifier]) {
        NSString *imageName = @"";
        switch (host.status) {
            case HYMHostStatusOffline:
                imageName = @"status_offline";
                break;
            case HYMHostStatusOnline:
                imageName = @"status_online";
                break;
            case HYMHostStatusRunning:
                imageName = @"status_running";
                break;
            default:
                break;
        }
        return [NSImage imageNamed:imageName];
    }
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];

    if ([identifier isEqualToString:kCheckboxCellIdentifier]) {
        NSNumber *isChecked = object;
        if ([isChecked isEqual:@0]) {
            [HYMHostsManager sharedManager].hosts[row].isChoosen = NO;
        } else {
            [HYMHostsManager sharedManager].hosts[row].isChoosen = YES;
        }
        [tableView reloadData];
    }
}

# pragma mark - NSTableViewDelegate
- (BOOL)tableView:(NSTableView *)tableView shouldSelectTableColumn:(nullable NSTableColumn *)tableColumn {
    return NO;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [HYMHostsManager sharedManager].selectedIndex = self.tableView.selectedRow;
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    if ([identifier isEqualToString:kCheckboxCellIdentifier]) {
        return YES;
    }
    return NO;
}
@end
