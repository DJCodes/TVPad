//
//  DetailViewController.h
//  TVPad
//
//  Created by Alain Jiang on 2013-02-24.
//  Copyright (c) 2013 DJ Codes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UITableViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
