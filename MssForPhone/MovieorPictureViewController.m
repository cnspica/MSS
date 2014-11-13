//
//  MovieorPictureViewController.m
//  MssForPhone
//
//  Created by it-mobile on 14/11/7.
//  Copyright (c) 2014年 Paul. All rights reserved.
//

#import "MovieorPictureViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"

#define mywidth  self.view.bounds.size.width
#define myheight  self.view.bounds.size.height

@interface MovieorPictureViewController ()
{
    MPMoviePlayerController *moviePlayer;
    NSInteger page;

}

@end

@implementation MovieorPictureViewController
@synthesize pdfview,videoview;
@synthesize myscroller;
@synthesize subscroller;
@synthesize pagecontrol;
@synthesize normal,normal2;

- (void)viewDidLoad {
    [super viewDidLoad];
    UISegmentedControl * mySegment;
    mySegment = [[UISegmentedControl alloc]
                 initWithFrame:CGRectMake(0,0,150,29)];
    [mySegment insertSegmentWithTitle:@"PDF" atIndex:0 animated:YES];
    [mySegment insertSegmentWithTitle:@"Video" atIndex:1 animated:YES];
    mySegment.segmentedControlStyle = UISegmentedControlStyleBar;
    [mySegment addTarget:self action:@selector(segAction:) forControlEvents:UIControlEventValueChanged];
    mySegment.selectedSegmentIndex = 0;
    
    UIView *segmentview=[[UIView alloc]initWithFrame:CGRectMake((mywidth-150)/2,(44-29)/2,150,29)];
    [segmentview addSubview:mySegment];
    self.navigationItem.titleView=segmentview;
    
    NSString *path=[[NSBundle mainBundle] pathForResource:@"BackCover" ofType:@"mp4"];
    NSURL *url=[[NSURL alloc] initFileURLWithPath:path];
    moviePlayer=[[MPMoviePlayerController alloc]initWithContentURL:url];
    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;;
    [moviePlayer.view setFrame:CGRectMake(0, 0, mywidth, myheight)];
    [moviePlayer.view setBackgroundColor:[UIColor clearColor]];
    [videoview addSubview:moviePlayer.view];
    
    
    
    [pagecontrol setCurrentPage:0];
    pagecontrol.currentPageIndicatorTintColor=[UIColor blackColor];
    pagecontrol.pageIndicatorTintColor=[UIColor grayColor];
    
    myscroller=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, mywidth, myheight-100)];
    myscroller.backgroundColor=[UIColor groupTableViewBackgroundColor];
    myscroller.userInteractionEnabled=YES;
    myscroller.maximumZoomScale=2.5;
    myscroller.minimumZoomScale=1;
    myscroller.delegate=self;
    [pdfview addSubview:myscroller];
    
    UITapGestureRecognizer *singletap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(fuifu)];
    singletap.numberOfTapsRequired=1;
    [myscroller addGestureRecognizer:singletap];
    
    UITapGestureRecognizer *doubletap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(fangda)];
    doubletap.numberOfTapsRequired=2;
    [myscroller addGestureRecognizer:doubletap];
    
    subscroller=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, mywidth, myheight-100)];
    subscroller.contentSize=CGSizeMake(mywidth*2, myheight-100);
    subscroller.pagingEnabled=YES;
    subscroller.delegate=self;
    subscroller.tag=1;
    [myscroller addSubview:subscroller];
    
    normal=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, mywidth, myheight-100)];
    normal.image=[UIImage imageNamed:@"page_01.jpg"];
    normal.userInteractionEnabled=YES;
    [subscroller addSubview:normal];
    
    
    normal2=[[UIImageView alloc]initWithFrame:CGRectMake(mywidth, 0, mywidth, myheight-100)];
    normal2.image=[UIImage imageNamed:@"page_02.jpg"];
    normal2.userInteractionEnabled=YES;
    [subscroller addSubview:normal2];

}

-(void)segAction:(UISegmentedControl *)seg
{
    switch (seg.selectedSegmentIndex) {
        case 0:
            NSLog(@"PDF");
            videoview.hidden=YES;
            pdfview.hidden=NO;
            [moviePlayer pause];

            break;
            
        case 1:
            NSLog(@"Video");
            pdfview.hidden=YES;
            videoview.hidden=NO;
            [moviePlayer play];

            break;
            
        default:
            break;
    }
}

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
    AppDelegate *delegate=[[UIApplication sharedApplication]delegate];
    delegate.Orientations=YES;
}

- (void)orientationChanged:(NSNotification *)note  {
    UIDeviceOrientation o = [[UIDevice currentDevice] orientation];
    
    
    switch (o) {
        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
            NSLog(@"1");
            [moviePlayer.view setFrame:CGRectMake(0, 0, 320, 568)];
            self.navigationController.navigationBarHidden=NO;
            
            break;
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            NSLog(@"2");
            [moviePlayer.view setFrame:CGRectMake(0, 0, 568,320)];
            self.navigationController.navigationBarHidden=YES;
            
            break;
        case UIDeviceOrientationLandscapeLeft:      // Device oriented horizontally, home button on the right
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
            NSLog(@"3");
            [moviePlayer.view setFrame:CGRectMake(0, 0, 568,320)];
            self.navigationController.navigationBarHidden=YES;
            
            
            break;
        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
            NSLog(@"4");
            [moviePlayer.view setFrame:CGRectMake(0, 0, 568,320)];
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

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    for (UIView *v in myscroller.subviews){
        if ([v isKindOfClass:[subscroller class]])
        {
            return v;
        }
    }
    return nil;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    //    NSLog(@"结束缩放 - %f", scale);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag==1) {
        page=scrollView.contentOffset.x/mywidth;
        pagecontrol.currentPage=page;
    }
    
}


-(void)fuifu
{
    [UIView animateWithDuration:0.3 animations:^{
        myscroller.zoomScale=1;
        
    }];
}

-(void)fangda
{
    [UIView animateWithDuration:0.3 animations:^{
        myscroller.zoomScale=2.5;
        
    }];
    
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
