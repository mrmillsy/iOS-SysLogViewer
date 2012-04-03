//
//  MSViewController.h
//  SysLogViewer
//
//  Created by Chris Mills on 02/03/2012.
//  Copyright (c) 2012 MillsySoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSSettingsTableViewController.h"

@interface MSViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MSSettingsTableViewControllerDataSource, UIAlertViewDelegate>
@property (retain, nonatomic) IBOutlet UITableView *syslogTableView;
@property (retain, nonatomic) IBOutlet UISwitch *autoScrollSwitch;

@end
