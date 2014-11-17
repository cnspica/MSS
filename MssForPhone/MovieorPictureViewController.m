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
#import "ASIHTTPRequest.h"
#import "API.h"
#import "UIImageView+WebCache.h"

#define mywidth  self.view.bounds.size.width
#define myheight  self.view.bounds.size.height

@interface MovieorPictureViewController ()
{
    MPMoviePlayerController *moviePlayer;
    NSInteger page;
    ASIHTTPRequest *requestpictures;
    NSString *apistring;
    NSString *response;
    id object;
    NSDictionary *applicationdic;
    NSInteger pagenumber;
    AppDelegate *delegate;
}

@end

@implementation MovieorPictureViewController
@synthesize pdfview,videoview;
@synthesize myscroller;
@synthesize subscroller;
@synthesize pagecontrol;
@synthesize api_language;
@synthesize idstring;
@synthesize myactivityindicator;

-(void)viewWillAppear:(BOOL)animated
{
    delegate=[[UIApplication sharedApplication]delegate];
    delegate.Orientations=NO;

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    apistring=[NSString stringWithFormat:@"%@?lang=%@&id=%@",HTTP_applicationinfo,api_language,idstring];
    requestpictures=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:apistring]];
    requestpictures.tag=1;
    [requestpictures setDelegate:self];
    [requestpictures setTimeOutSeconds:60];
    [requestpictures setDidFinishSelector:@selector(requestFinished:)];
    [requestpictures setDidFailSelector:@selector(requestFailed:)];
    [requestpictures startAsynchronous];

    videoview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, mywidth, myheight)];
    [self.view addSubview:videoview];
    videoview.hidden=YES;
    
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
    
//    NSString *path=[[NSBundle mainBundle] pathForResource:@"BackCover" ofType:@"mp4"];
    NSURL *url=[NSURL URLWithString:@"http://192.168.158.234/minimss/resource/yudo.mp4"];
    moviePlayer=[[MPMoviePlayerController alloc]initWithContentURL:url];
    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;;
    [moviePlayer.view setFrame:CGRectMake(0, 0, mywidth, myheight)];
    [moviePlayer.view setBackgroundColor:[UIColor clearColor]];
    [videoview addSubview:moviePlayer.view];
    
    [pagecontrol setCurrentPage:0];
    pagecontrol.currentPageIndicatorTintColor=[UIColor blackColor];
    pagecontrol.pageIndicatorTintColor=[UIColor grayColor];
    
    myscroller=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 164, mywidth, myheight-360)];
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
    
    myactivityindicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake((mywidth-20)/2, (myheight-20)/2, 20, 20)];
    myactivityindicator.color=[UIColor blackColor];
    [self.view addSubview:myactivityindicator];
    [myactivityindicator startAnimating];
    myactivityindicator.hidesWhenStopped=YES;

    
}

//-------------------------------------------------------------------------------------------------------------------------------------------------

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request.tag==1) {
        response=[request responseString];
        
        [self jsonStringToObject];
        applicationdic=object;
        NSLog(@"%@",applicationdic);
        pagecontrol.numberOfPages=[[applicationdic objectForKey:@"data"] count];
        pagenumber=pagecontrol.numberOfPages;
        NSLog(@"共有%li页",(long)pagenumber);
        subscroller=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, mywidth, myheight-360)];
        subscroller.contentSize=CGSizeMake(mywidth*pagenumber, myheight-360);
        subscroller.pagingEnabled=YES;
        subscroller.delegate=self;
        subscroller.tag=1;
        [myscroller addSubview:subscroller];
        
        for (int i=0; i<pagenumber; i++) {
            UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(mywidth*i, 0, mywidth, myheight-360)];
            [imageview sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[[applicationdic objectForKey:@"data"] objectAtIndex:i] objectForKey:@"file"]]]];
            NSLog(@"%@",[NSString stringWithFormat:@"%@",[[[applicationdic objectForKey:@"data"] objectAtIndex:i] objectForKey:@"file"]]);
            [subscroller addSubview:imageview];
        }
        [myactivityindicator stopAnimating];
    }
    
    
}

//-------------------------------------------------------------------------------------------------------------------------------------------------


- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error=[request error];
    NSLog(@"%@",error);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------

-(id)jsonStringToObject
{
    NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    
    object = [NSJSONSerialization JSONObjectWithData:data
              
                                             options:NSJSONReadingAllowFragments
              
                                               error:&error];
    
    return object;
}

-(void)segAction:(UISegmentedControl *)seg
{
       switch (seg.selectedSegmentIndex) {
        case 0:
            NSLog(@"PDF");
            delegate.Orientations=NO;
            videoview.hidden=YES;
            pdfview.hidden=NO;
            [moviePlayer pause];

            break;
            
        case 1:
            NSLog(@"Video");
            delegate.Orientations=YES;
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
