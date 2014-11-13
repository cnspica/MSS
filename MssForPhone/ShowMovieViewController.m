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

#define mywidth     320
#define myheight    568

@interface ShowMovieViewController ()
{
    MPMoviePlayerController *moviePlayer;
}
@end

@implementation ShowMovieViewController

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
    self.title=@"时间控制注塑";
    AppDelegate *delegate=[[UIApplication sharedApplication]delegate];
    delegate.Orientations=YES;    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:@"http://192.168.158.234/yudo/video/002_MC_Cap.mp4"]];
    
    NSString *path=[[NSBundle mainBundle] pathForResource:@"BackCover" ofType:@"mp4"];
    NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
    moviePlayer=[[MPMoviePlayerController alloc]initWithContentURL:url];
    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;;
    [moviePlayer.view setFrame:CGRectMake(0, 0, mywidth, myheight)];
    [moviePlayer.view setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:moviePlayer.view];
    [moviePlayer play];

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
