//
//  ViewController.m
//  Server
//
//  Created by 马远征 on 14-4-25.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"

@interface ViewController () <GCDAsyncSocketDelegate>
{
    dispatch_queue_t _socketQueue;
    
    GCDAsyncSocket *_asyncSocket;
    
    NSMutableArray *_connectedSocks;
    
    BOOL _isRuning;
    
    UIButton *_button;
    
    NSInputStream *_inputStream;
    
    int writelen;
}
@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        NSLog(@"---init---");
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	_button = [UIButton buttonWithType:UIButtonTypeCustom];
    [_button setFrame:CGRectMake(120, 240, 80, 34)];
    [_button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [_button setTitle:@"connect" forState:UIControlStateNormal];
    [_button setTitle:@"connect" forState:UIControlStateHighlighted];
    [_button addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
    
    NSString *queueName = NSStringFromClass([self class]);
    _socketQueue = dispatch_queue_create([queueName UTF8String], NULL);
    _asyncSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:_socketQueue];
    _connectedSocks = [[NSMutableArray alloc]init];
    _isRuning = NO;
}

- (void)btnClick
{
    if (!_isRuning)
    {
        NSError *error = nil;
        if (![_asyncSocket acceptOnPort:443 error:&error])
        {
            NSLog(@"---socket连接失败---%@",error);
            return;
        }
        _isRuning = YES;
        [_button setTitle:@"disconnect" forState:UIControlStateNormal];
        [_button setTitle:@"disconnect" forState:UIControlStateHighlighted];
    }
    else
    {
        [_asyncSocket disconnect];
        @synchronized(_connectedSocks)
		{
			NSUInteger i;
			for (i = 0; i < [_connectedSocks count]; i++)
			{
				[[_connectedSocks objectAtIndex:i] disconnect];
			}
		}
        _isRuning = NO;
        [_button setTitle:@"connect" forState:UIControlStateNormal];
        [_button setTitle:@"connect" forState:UIControlStateHighlighted];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	@synchronized(_connectedSocks)
	{
		[_connectedSocks addObject:newSocket];
	}
	
    //    NSString *welcomeMsg = @"Welcome to the AsyncSocket Echo Server\r\n";
    //	NSData *welcomeData = [welcomeMsg dataUsingEncoding:NSUTF8StringEncoding];
    //
    //	[newSocket writeData:welcomeData withTimeout:-1 tag:0];
    //	[newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:15.0 tag:0];
    NSString *filepath = [[NSBundle mainBundle]pathForResource:@"IMG_0017" ofType:@"JPG"];
    NSLog(@"---filePath--%@",filepath);
    NSData *data = [NSData dataWithContentsOfFile:filepath];
    
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filepath];
    
    
    _inputStream = [[NSInputStream alloc]initWithFileAtPath:filepath];
    [_inputStream open];
    NSLog(@"-----%d",handle.availableData.length);
    writelen = 0;
    uint8_t buffer[4096];
    int len =  [_inputStream read:buffer maxLength:1024];
    writelen += len;
    if (len == 0 || len == -1)
    {
        NSLog(@"---写数据出错---");
    }
    else
    {
        NSLog(@"---开始写数据---%d",len);
        NSData *data = [NSData dataWithBytes:buffer length:len];
        [newSocket writeData:data withTimeout:-1 tag:1];
    }
    
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == 1)
    {
        uint8_t buffer[4096];
        
        int len =  [_inputStream read:buffer maxLength:1024];
        writelen += len;
        if (len == 0 || len == -1)
        {
            NSLog(@"---写数据完成---%d",writelen);
            [_inputStream close];
//            NSString *msg = [NSString ]
//            [sock disconnect];
        }
        else
        {
            NSLog(@"---写数据---%d",len);
            NSData *data = [NSData dataWithBytes:buffer length:len];
            [sock writeData:data withTimeout:-1 tag:1];
        }
        
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //	[sock writeData:data withTimeout:-1 tag:1];
}


//- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
//                 elapsed:(NSTimeInterval)elapsed
//               bytesDone:(NSUInteger)length
//{
////	if (elapsed <= 15.0)
////	{
////		NSString *warningMsg = @"Are you still there?\r\n";
////		NSData *warningData = [warningMsg dataUsingEncoding:NSUTF8StringEncoding];
////		[sock writeData:warningData withTimeout:-1 tag:2];
////
////		return 10.0;
////	}
//
//	return 0.0;
//}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	if (sock != _asyncSocket)
	{
		@synchronized(_connectedSocks)
		{
			[_connectedSocks removeObject:sock];
		}
	}
}


@end
