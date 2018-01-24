//
//  BLESearchViewController.m
//  BabyBLETest
//
//  Created by lanmi on 2017/9/21.
//  Copyright © 2017年 com.qcymail. All rights reserved.
//

#import "BLESearchViewController.h"
#import "BabyBluetooth.h"
#import "ViewController.h"
#import "QCYBle.h"

@interface BLESearchViewController () <QCYDelegate>
{
    QCYBle *qcyBle;
}

@property NSMutableArray *bleDevices;
@end

@implementation BLESearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bleDevices = [[NSMutableArray alloc] initWithCapacity:0];
    qcyBle = [QCYBle shareQCYBle];
    qcyBle.delegate = self;
    [qcyBle startScan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bleDevices.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        
    }
    QCYEarphone *earphone = (QCYEarphone *)self.bleDevices[indexPath.row];
    if (earphone.peripheral.state == CBPeripheralStateDisconnected) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if (earphone.peripheral.state == CBPeripheralStateConnected){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.text = earphone.peripheral.name;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QCYEarphone *earphone = (QCYEarphone *)self.bleDevices[indexPath.row];
    if (earphone.peripheral.state == CBPeripheralStateDisconnected) {
        [earphone connect];
    }else if(earphone.peripheral.state == CBPeripheralStateConnected){
        [earphone disConnect];
    }
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - QCYDelegate
- (void)onConnected:(QCYEarphone *)earphone {
    [self.tableView reloadData];
}

- (void)onDisconnected:(QCYEarphone *)earphone {
    [self.tableView reloadData];
}

- (void)onDiscoverToPeripherals:(QCYEarphone *)earphone {
    [self.bleDevices addObject:earphone];
    [self.tableView reloadData];
}

- (void)onFailToConnect:(QCYEarphone *)earphone {
    [self.tableView reloadData];
}

- (void)onNotification:(QCYEarphone *)earphone{
    
}

@end
