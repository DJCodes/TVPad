//
//  DetailViewController.m
//  TVPad
//
//  Created by Alain Jiang on 2013-02-24.
//  Copyright (c) 2013 DJ Codes. All rights reserved.
//

#import "DetailViewController.h"
#import "Channel.h"
#import "Program.h"
#import "ASIHTTPRequest.h"
#import "TFHpple.h"
#import "TFHppleElement.h"

@interface DetailViewController (){
    NSMutableArray *_objects;
}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
    
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        
        if (!_objects) {
            _objects = [[NSMutableArray alloc] init];
        }
        else{
            [_objects removeAllObjects];
        }
        
        Channel *channel = self.detailItem;
        
        
        NSURL *url = [NSURL URLWithString:channel.url];
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request setDelegate:self];
        [request startAsynchronous];
        
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *baseUrl = @"http://www.113ds.com";
    NSData *responseData = [request responseData];
    TFHpple *paser = [[TFHpple alloc] initWithHTMLData:responseData];
    NSArray *array = [paser searchWithXPathQuery:@"//div[@class=\"txt\"]"];

    for (int i=0; i<array.count; i++) {
        
        TFHppleElement *element = [array objectAtIndex:i];
        
        Program *program = [[Program alloc] init];
        
        TFHppleElement *child = [element.children objectAtIndex:1];
        
        program.url = [baseUrl stringByAppendingString:[child.attributes objectForKey:@"href"]];
        
        TFHppleElement *node = [child.children objectAtIndex:0];
        program.picUrl = [node.attributes objectForKey:@"src"];
        program.title = [node.attributes objectForKey:@"alt"];
        
        [_objects addObject:program];
        
    }
    
    [self.tableView reloadData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"Error:%@", error);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Program *program = _objects[indexPath.row];
    
    cell.textLabel.text = program.title;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//
//}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"showProgram"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Program *program = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:program];
    }
    
}


@end
