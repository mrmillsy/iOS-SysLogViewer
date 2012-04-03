//
//  MSSettingsTableViewControllerViewController.h
//  SysLogViewer
//
//  Created by Chris Mills on 03/04/2012.
//  Copyright (c) 2012 MillsySoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MSSettingsTableViewControllerDataSource
-(void)updatePortNumber:(int)portNumber;
@end

@interface MSSettingsTableViewController : UITableViewController

@property (retain, nonatomic) IBOutlet UIStepper *portCounter;
@property (retain, nonatomic) IBOutlet UILabel *portLabel;
@property (retain, nonatomic) IBOutlet UILabel *ipLabel;
//delegate
@property (retain, nonatomic) id<MSSettingsTableViewControllerDataSource> delegate;

@end
