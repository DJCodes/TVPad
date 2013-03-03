//
//  EpisodeViewController.m
//  TVPad
//
//  Created by Alain Jiang on 2013-02-27.
//  Copyright (c) 2013 DJ Codes. All rights reserved.
//

#import "EpisodeViewController.h"
#import "Episode.h"
#import "Program.h"
#import "ASIHTTPRequest.h"
#import "TFHpple.h"
#import "TFHppleElement.h"

@interface EpisodeViewController (){
    NSMutableArray *_objects;
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
}

@end

@implementation EpisodeViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        
        // Update the view.
        [self configureView];
    }
    

}

- (void) initNetworkCommunication {
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"172.23.45.131", 8885, &readStream, &writeStream);
    
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
    NSLog(@"stream event %i", streamEvent);
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
        
        Program *program = self.detailItem;
        
        
        
        NSURL *url = [NSURL URLWithString:program.url];
        
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
    NSArray *array = [paser searchWithXPathQuery:@"//ul[@id=\"pList1\"]//li"];
    
    for (int i=0; i<array.count; i++) {
        
        TFHppleElement *element = [array objectAtIndex:i];
        
        Episode *episode = [[Episode alloc] init];
        
        TFHppleElement *child = [element.children objectAtIndex:0];
        //TFHppleElement *node = [child.children objectAtIndex:0];
        //NSLog(@"%@", child);
        episode.url = [baseUrl stringByAppendingString:[child.attributes objectForKey:@"href"]];
        episode.title = [child.attributes objectForKey:@"title"];

        
        [_objects addObject:episode];
        
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

    [self initNetworkCommunication];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Episode *episode = _objects[indexPath.row];
    
    cell.textLabel.text = episode.title;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */

    Episode *episode = _objects[indexPath.row];
    NSURL *url = [NSURL URLWithString:episode.url];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {

        NSData *responseData = [request responseData];
        TFHpple *paser = [[TFHpple alloc] initWithHTMLData:responseData];
        NSArray *array = [paser searchWithXPathQuery:@"//span[@id=\"loadplay\"]//script"];
        
    
            
        TFHppleElement *element = [array objectAtIndex:0];
        TFHppleElement *child = [element.children objectAtIndex:0];
        NSString *link = child.content;
        NSRange first = [link rangeOfString:@"bdhd:"];
        NSRange last = [link rangeOfString:@"rmvb"];
        first.length = last.location - first.location + last.length;
        NSString *nlink = [link substringWithRange:first];

        NSString *response  = nlink;
        NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSUTF8StringEncoding]];
        [outputStream write:[data bytes] maxLength:[data length]];

    }
}

@end
