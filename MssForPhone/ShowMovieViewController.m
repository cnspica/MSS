//
//  ShowMovieViewController.m
//  MssForPhone
//
//  Created by it-mobile on 14/11/4.
//  Copyright (c) 2014年 Paul. All rights reserved.
//

#import "ShowMovieViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"
#import "ASIHTTPRequest.h"
#import <CommonCrypto/CommonDigest.h>

#define mywidth     320
#define myheight    568

@interface ShowMovieViewController ()
{
    MPMoviePlayerController *moviePlayer;
}
@end

@implementation ShowMovieViewController
@synthesize videourl;
@synthesize navtitle;
@synthesize myactivityindicator;
@synthesize cachelabel;


- (void)viewDidAppear:(BOOL)animated {
    // Do any additional setup after loading the view from its nib.
    //----- SETUP DEVICE ORIENTATION CHANGE NOTIFICATION -----
    UIDevice *device = [UIDevice currentDevice]; //Get the device object
    [device beginGeneratingDeviceOrientationNotifications]; //Tell it to start monitoring the accelerometer for orientation
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; //Get the notification centre for the app
    [nc addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:device];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound){
        [moviePlayer stop];
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    UIDevice *device = [UIDevice currentDevice]; //Get the device object
    [nc removeObserver:self name:UIDeviceOrientationDidChangeNotification object:device];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.title=navtitle;
    AppDelegate *delegate=[[UIApplication sharedApplication]delegate];
    delegate.Orientations=YES;    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [myactivityindicator startAnimating];
    myactivityindicator.hidesWhenStopped=YES;
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:videourl]];
    //获取全局变量
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //设置缓存方式
    [request setDownloadCache:appDelegate.myCache];
    //设置缓存数据存储策略，这里采取的是如果无更新或无法联网就读取缓存数据
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request setDidFinishSelector:@selector(requestFinished:)];
    request.delegate = self;
    request.tag=1;
    [request startAsynchronous];
    
}

//md5加密
- (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (int)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ]; 
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if(request.tag==1)
    {
        NSLog(@"movie");
        //取得当前应用的主目录
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *videopath = [paths objectAtIndex:0];
        NSLog(@"%@",videopath);
        NSString *temp1=[self md5:[NSString stringWithFormat:@"%@",videourl]];
                //取得当前应用主目录数据库文件存储路径
        
        NSArray *stringarray=[videourl componentsSeparatedByString:@"."];
        NSString *temp2=[stringarray objectAtIndex:([stringarray count]-1)];
        
        NSString *dbFile=[videopath stringByAppendingPathComponent:[NSString stringWithFormat:@"Caches/PermanentStore/%@.%@",temp1,temp2]];
        NSFileManager *fileManager=[NSFileManager defaultManager];
        BOOL find=[fileManager fileExistsAtPath:dbFile];
        

        if (find) {
            NSLog(@"来自缓存");
            NSString *str=[NSString stringWithFormat:@"%@",dbFile];
            NSLog(@"%@",str);
            moviePlayer = [[MPMoviePlayerController alloc]initWithContentURL:[NSURL fileURLWithPath:str]];
            moviePlayer.scalingMode = MPMovieScalingModeAspectFit;;
            [moviePlayer.view setFrame:CGRectMake(0, 0, mywidth, myheight)];
            [moviePlayer.view setBackgroundColor:[UIColor clearColor]];
            [self.view addSubview:moviePlayer.view];
            [moviePlayer play];
            [myactivityindicator stopAnimating];
            cachelabel.hidden=YES;
            
        }else
        {
            NSLog(@"来自网络");
            [myactivityindicator stopAnimating];
            cachelabel.hidden=YES;

        }
        
    }
    
}

- (void)orientationChanged:(NSNotification *)note  {
    UIDeviceOrientation o = [[UIDevice currentDevice] orientation];
    
    
    switch (o) {
        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
            [moviePlayer.view setFrame:CGRectMake(0, 0, mywidth, myheight)];
            self.navigationController.navigationBarHidden=NO;

            break;
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            [moviePlayer.view setFrame:CGRectMake(0, 0, myheight,mywidth)];
            self.navigationController.navigationBarHidden=YES;
            
            break;
        case UIDeviceOrientationLandscapeLeft:      // Device oriented horizontally, home button on the right
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
            [moviePlayer.view setFrame:CGRectMake(0, 0, myheight,mywidth)];
            self.navigationController.navigationBarHidden=YES;

            
            break;
        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
            [moviePlayer.view setFrame:CGRectMake(0, 0, myheight,mywidth)];
            self.navigationController.navigationBarHidden=YES;

            
            break;
        default:
            break;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // 操作
    return YES;  // YES为允许横屏，否则不允许横屏
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
