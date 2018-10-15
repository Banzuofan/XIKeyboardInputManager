//
//  XIViewController.m
//  XIKeyboardInputManager
//
//  Created by banzuofan@hotmail.com on 10/11/2018.
//  Copyright (c) 2018 banzuofan@hotmail.com. All rights reserved.
//

#import "XIViewController.h"
#import "XIKeyboardInputManager.h"
#import "XIProgressHUD.h"

@interface XIViewController ()
{
    UITableView *contentTable;
    NSMutableArray *dataSources;
}
@end

static NSString * const ReusedCellId = @"ReusedCellId";

@implementation XIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    dataSources = @[
  @{@"title":@"XIKeyboardBackgroundNone",@"description":@""},//0
  @{@"title":@"XIKeyboardBackgroundTransparent",@"description":@""},//1
  @{@"title":@"XIKeyboardBackgroundTranslucent",@"description":@""}//2
  ].mutableCopy;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return dataSources.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReusedCellId];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ReusedCellId];
    }
    NSDictionary *dic = dataSources[indexPath.row];
    cell.textLabel.text = dic[@"title"];
    cell.detailTextLabel.text = dic[@"description"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    XIKeyboardBackgroundMode mode = XIKeyboardBackgroundNone;
    NSString *draft = nil;
    if(indexPath.row==0){
    }
    else if(indexPath.row==1){
        mode = XIKeyboardBackgroundTransparent;
        draft = @"// Do any additional setup after loading the view, typically from a nib.";
    }
    else if(indexPath.row==2){
        mode = XIKeyboardBackgroundTranslucent;
    }
    
    [self beginEditingWithDraft:draft placeholder:@"enter some text..." backgroundMode:mode limitedTextLength:1000 inputType:CommonReplyType shouldEndFinishing:^BOOL(NSString *currentInput) {
        if(currentInput.length==0){
            [XIProgressHUD showToast:@"empty input, check again!" onView:self.view dismissAfter:1];
            return NO;
        }
        return YES;
    } completion:^(NSDictionary *result, BOOL finished) {
        NSString *text = result[@"text"];
        if(finished){
            NSMutableDictionary *newdic = [NSMutableDictionary dictionaryWithDictionary:dataSources[indexPath.row]];
            [newdic setObject:text forKey:@"description"];
            [dataSources replaceObjectAtIndex:indexPath.row withObject:newdic];
            [self.tableView reloadData];
        }
        else{
            [self setDraft:text forKey:[@(indexPath.row) stringValue]];
            [XIProgressHUD showToast:@"Draft saved!" onView:self.view dismissAfter:1];
        }
    }];
}

@end
