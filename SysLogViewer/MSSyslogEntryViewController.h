//
//  MSSyslogEntryViewController.h
//  SysLogViewer
//
//  Created by Chris Mills on 03/04/2012.
//  Copyright (c) 2012 MillsySoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSSysLogEntry.h"

@interface MSSyslogEntryViewController : UITableViewController

@property (retain, nonatomic) IBOutlet UITableView *syslogTable;
@property (retain, nonatomic) MSSysLogEntry* entry;
@property (retain, nonatomic) IBOutlet UILabel *priorityLabel;
@property (retain, nonatomic) IBOutlet UILabel *severityLabel;
@property (retain, nonatomic) IBOutlet UILabel *faciltyLabel;
@property (retain, nonatomic) IBOutlet UILabel *timestampLabel;
@property (retain, nonatomic) IBOutlet UILabel *processIDLabel;
@property (retain, nonatomic) IBOutlet UILabel *tagLabel;
@property (retain, nonatomic) IBOutlet UILabel *msgLabel;
@property (retain, nonatomic) IBOutlet UILabel *hostLabel;
@property (retain, nonatomic) IBOutlet UILabel *portLabel;

@end
