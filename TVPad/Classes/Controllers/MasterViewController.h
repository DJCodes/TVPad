//
//  MasterViewController.h
//  TVPad
//
//  Created by Alain Jiang on 2013-02-24.
//  Copyright (c) 2013 DJ Codes. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController<NSXMLParserDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
