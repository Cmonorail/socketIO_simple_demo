//
//  ViewController.m
//  SocketIO_Chat_Example
//
//  Created by 周英斌 on 2017/2/11.
//  Copyright © 2017年 周英斌. All rights reserved.
//

#import "ViewController.h"
#import <SocketIO/SocketIO-Swift.h>
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *inputView;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UITableView *messageTableView;
@property (nonatomic,strong)SocketIOClient *client;
@property (nonatomic,strong)NSMutableArray * messageArray;//存放消息的数组

@end
static NSString *const KMessageCellId = @"KMessageCellId";
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.messageTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:KMessageCellId];
    [self connection];
    
    
}

- (NSMutableArray *)messageArray{
    if (!_messageArray) {
        _messageArray = @[].mutableCopy;
    }
    return _messageArray;
}
- (SocketIOClient *)client{
    if (!_client) {
        NSURL* url = [[NSURL alloc] initWithString:@"http://127.0.0.1:3000"];
        
        _client = [[SocketIOClient alloc] initWithSocketURL:url config:@{@"log": @YES, @"forcePolling": @YES}];
    }
    return _client;
}

- (void)connection{

    [self.client on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"*************\n\niOS客户端上线\n\n*************");
        [self.client emit:@"login" with:@[@"30342"]];
    }];
    [self.client on:@"chat message" callback:^(NSArray * _Nonnull event, SocketAckEmitter * _Nonnull ack) {
        if (event[0] && ![event[0] isEqualToString:@""]) {
            [self.messageArray insertObject:event[0] atIndex:0];
            [self.messageTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        }
    }];
    [self.client on:@"privateMessage" callback:^(NSArray * _Nonnull event, SocketAckEmitter * _Nonnull ack) {
        if (event[0] && ![event[0] isEqualToString:@""]) {
            [self.messageArray insertObject:event[0] atIndex:0];
            [self.messageTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        }
    }];
    [self.client on:@"disconnect" callback:^(NSArray * _Nonnull event, SocketAckEmitter * _Nonnull ack) {
        NSLog(@"*************\n\niOS客户端下线\n\n*************%@",event?event[0]:@"");
    }];
    [self.client on:@"error" callback:^(NSArray * _Nonnull event, SocketAckEmitter * _Nonnull ack) {
        NSLog(@"*************\n\n%@\n\n*************",event?event[0]:@"");
    }];
    [self.client connect];

}
//按钮点击事件
- (IBAction)sendMessage:(id)sender {
    if (self.inputView.text.length>0) {
        
        [self.client emit:@"chat message" with:@[@{@"toUser":@"30621",@"message":self.inputView.text}]];
        [self.messageArray insertObject:self.inputView.text atIndex:0];
        [self.messageTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        self.inputView.text = @"";
    }
    
}

#pragma mark - TableViewDataSouce
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.messageArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:KMessageCellId];
    cell.textLabel.text    = self.messageArray[indexPath.row];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}
@end
