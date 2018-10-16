//
//  HYMHostsTableVC.m
//  MultiSSH
//
//  Created by huangyimin on 2018/10/16.
//  Copyright © 2018 huangyimin. All rights reserved.
//

#import "HYMHostsTableVC.h"
#import "HYMHostsManager.h"

static NSString * const kCheckboxCellIdentifier = @"HYMCheckBoxID";
static NSString * const kHostCellIdentifier = @"HYMHostID";
static NSString * const kStatusCellIdentifier = @"HYMStatusID";

@implementation HYMGradientBar

- (NSView *)hitTest:(NSPoint)point {
    return nil;
}

@end

@interface HYMHostsTableVC ()<NSTableViewDelegate, NSTableViewDataSource>

@end

@implementation HYMHostsTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.checkboxAll.objectValue = @0;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

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

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    if ([identifier isEqualToString:kCheckboxCellIdentifier]) {
        return YES;
    }
    return NO;
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

- (BOOL)tableView:(NSTableView *)tableView shouldSelectTableColumn:(nullable NSTableColumn *)tableColumn {
    return NO;
}

# pragma mark - NSTableViewDelegate
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [HYMHostsManager sharedManager].selectedIndex = self.tableView.selectedRow;
}
@end
