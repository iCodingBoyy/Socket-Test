//
//  ViewController.m
//  SocketClient
//
//  Created by 马远征 on 14-4-25.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"

@interface ViewController ()<GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *_asyncSocket;
    NSOutputStream *_outPutStream;
    int receiveLen;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	_asyncSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    BOOL connectOK = [_asyncSocket connectToHost:@"192.168.1.115" onPort:443 error: &error];
    
    if (!connectOK)
    {
        NSLog(@"connect error: %@", error);
    }
    else
    {
        NSLog(@"--客户端成功连接--");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"--%d--%s",__LINE__,__FUNCTION__);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"IMG_0017.JPG"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath])
    {
        [fileManager removeItemAtPath:filePath error:nil];
    }
    [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    _outPutStream = [[NSOutputStream alloc]initToFileAtPath:filePath append:YES];
    [_outPutStream open];
    receiveLen = 0;
    [sock readDataWithTimeout:-1 tag:2];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
//    NSLog(@"--%d--%s",__LINE__,__FUNCTION__);
    if (tag == 2)
    {
        
        int writelen =  [_outPutStream write:[data bytes] maxLength:data.length];
        [sock readDataWithTimeout:-1 tag:2];
        receiveLen += writelen;
        NSLog(@"--%d-%d",receiveLen,data.length);
    }
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
//    if (elapsed < 15.0)
//    {
//        [sock disconnect];
//    }
    NSLog(@"超时");
    return 0;
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"--%d--%s",__LINE__,__FUNCTION__);
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"--%d--%s",__LINE__,__FUNCTION__);
}



@end
