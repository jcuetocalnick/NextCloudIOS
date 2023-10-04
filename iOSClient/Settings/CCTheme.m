//
//  CCTheme.m
//  Nextcloud
//
//  Created by Schadrack Cineas on 10/3/23.
//  Copyright © 2023 Marino Faggiana. All rights reserved.
//
#import "CCTheme.h"
#import <Foundation/Foundation.h>
#import "NCBridgeSwift.h"
#import "CCAdvanced.h"
#import "CCUtility.h"


@interface CCTheme ()
{
    AppDelegate *appDelegate;
    NSString *versionServer;
    NSString *themingName;
    NSString *themingSlogan;
}
@end

@implementation CCTheme
- (void)initializeForm
{
    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    form.rowNavigationOptions = XLFormRowNavigationOptionNone;

    // Section : COLOR --------------------------------------------------------------
    section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"_information_", nil)];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"autoUpload" rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"_settings_autoupload_", nil)];
    row.cellConfigAtConfigure[@"backgroundColor"] = UIColor.secondarySystemGroupedBackgroundColor;
    [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
    [row.cellConfig setObject:UIColor.labelColor forKey:@"textLabel.textColor"];
    [row.cellConfig setObject:[[UIImage imageNamed:@"autoUpload"] imageWithColor:UIColor.systemRedColor size:25] forKey:@"imageView.image"];
    row.action.viewControllerClass = [CCAdvanced class];

    [section addFormRow:row];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.form = form;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"_theme_", nil);
    self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.tableView.backgroundColor = UIColor.systemGroupedBackgroundColor;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:NCGlobal.shared.notificationCenterApplicationDidEnterBackground object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initialize) name:NCGlobal.shared.notificationCenterInitialize object:nil];

    [self initializeForm];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    appDelegate.activeViewController = self;

    versionServer = [[NCGlobal shared] capabilityServerVersion];
    themingName = [[NCGlobal shared] capabilityThemingName];
    themingSlogan = [[NCGlobal shared] capabilityThemingSlogan];
}

- (void)initialize
{
    [self initializeForm];

}

@end

