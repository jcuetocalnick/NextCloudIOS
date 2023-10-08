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
    section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"_customize_", nil)];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"theme" rowType:XLFormRowDescriptorTypeName title:NSLocalizedString(@"_app_Name_", nil)];
    row.cellConfigAtConfigure[@"backgroundColor"] = UIColor.secondarySystemGroupedBackgroundColor;
    [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
    [row.cellConfig setObject:UIColor.labelColor forKey:@"textLabel.textColor"];
    [row.cellConfig setObject:[[UIImage imageNamed:@"note.text"] imageWithColor:UIColor.systemRedColor size:25] forKey:@"imageView.image"];
    row.action.viewControllerClass = [CCAdvanced class];
    [section addFormRow:row];
    
    //Add title to Localizable
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"theme" rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"_theme_color_", nil)];
    row.cellConfigAtConfigure[@"backgroundColor"] = UIColor.secondarySystemGroupedBackgroundColor;
    [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
    [row.cellConfig setObject:UIColor.labelColor forKey:@"textLabel.textColor"];
    [row.cellConfig setObject:[[UIImage imageNamed:@"palette"] imageWithColor:UIColor.systemRedColor size:25] forKey:@"imageView.image"];
    row.action.viewControllerClass = [CCAdvanced class];
    [section addFormRow:row];
    
    //Add title to Localizable
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"theme" rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"_theme_background_image_", nil)];
    row.cellConfigAtConfigure[@"backgroundColor"] = UIColor.secondarySystemGroupedBackgroundColor;
    [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
    [row.cellConfig setObject:UIColor.labelColor forKey:@"textLabel.textColor"];
    [row.cellConfig setObject:[[UIImage imageNamed:@"autoUpload"] imageWithColor:UIColor.systemBlueColor size:25] forKey:@"imageView.image"];
    row.action.viewControllerClass = [CCAdvanced class];
    [section addFormRow:row];
    
    //Add title to Localizable
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"theme" rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"_theme_slogan_", nil)];
    row.cellConfigAtConfigure[@"backgroundColor"] = UIColor.secondarySystemGroupedBackgroundColor;
    [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
    [row.cellConfig setObject:UIColor.labelColor forKey:@"textLabel.textColor"];
    [row.cellConfig setObject:[[UIImage imageNamed:@"note.text"] imageWithColor:UIColor.systemPurpleColor size:25] forKey:@"imageView.image"];
    row.action.viewControllerClass = [CCAdvanced class];
    [section addFormRow:row];
    
    //Add Logo Picture
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"theme" rowType:XLFormRowDescriptorTypeImage title:NSLocalizedString(@"_theme_logo_", nil)];
    row.cellConfigAtConfigure[@"backgroundColor"] = UIColor.secondarySystemGroupedBackgroundColor;
    [row.cellConfig setObject:[UIFont systemFontOfSize:15.0] forKey:@"textLabel.font"];
    [row.cellConfig setObject:UIColor.labelColor forKey:@"textLabel.textColor"];
    [row.cellConfig setObject:[[UIImage imageNamed:@"autoUpload"] imageWithColor:UIColor.systemPurpleColor size:25] forKey:@"imageView.image"];
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

