//
//  IntroductionViewController.m
//  MssForPhone
//
//  Created by it-mobile on 14/11/1.
//  Copyright (c) 2014年 Paul. All rights reserved.
//

#import "IntroductionViewController.h"
#import "AppDelegate.h"
#import <MapKit/MapKit.h>
#import "ShowMovieViewController.h"
#import "ASIHTTPRequest.h"
#import "API.h"
#import "UIImageView+WebCache.h"

#define mywidth  self.view.bounds.size.width
#define myheight  self.view.bounds.size.height
#define number languagelist_country.count

BOOL isopen;

@interface IntroductionViewController ()
{
    UIView *longpicture;
    UIView *languageview;
    NSMutableArray *languagelist_country;
    NSMutableArray *languagelist_lang;
    ASIHTTPRequest *requestlanguages;
    ASIHTTPRequest *requestinfo;
    NSString *response;
    id object;
    NSDictionary *languagesdic;
    NSDictionary *infodic;
    NSString *apistring;
    NSString *api_language;
    UIActivityIndicatorView *activityindicator;
    UIView *navcenter;
}
@end

@implementation IntroductionViewController
@synthesize myscroller;
@synthesize myimageview1;
@synthesize myMapview;
@synthesize myLocationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.tabBarItem setImage:[UIImage imageNamed:@"introduction.png"]];
        self.tabBarItem.title=@"介绍";
        isopen=NO;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.navigationItem.titleView=navcenter;
    self.navigationController.navigationBar.hidden=NO;
    self.tabBarController.navigationItem.rightBarButtonItem=nil;
    //----- SETUP DEVICE ORIENTATION CHANGE NOTIFICATION -----
    UIDevice *device = [UIDevice currentDevice]; //Get the device object
    [device beginGeneratingDeviceOrientationNotifications]; //Tell it to start monitoring the accelerometer for orientation
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; //Get the notification centre for the app
    [nc addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:device];

    AppDelegate *delegate=[[UIApplication sharedApplication]delegate];
    delegate.Orientations=YES;
    
    UIButton *languagebt = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    [languagebt addTarget:self action:@selector(selectlanguage) forControlEvents:UIControlEventTouchUpInside];
    [languagebt setBackgroundImage:[UIImage imageNamed:@"语言.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftbt = [[UIBarButtonItem alloc]initWithCustomView:languagebt];
    self.tabBarController.navigationItem.rightBarButtonItem=leftbt;

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
   
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    UIDevice *device = [UIDevice currentDevice]; //Get the device object
    [nc removeObserver:self name:UIDeviceOrientationDidChangeNotification object:device];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    languagelist_country=[[NSMutableArray alloc]init];
    languagelist_lang=[[NSMutableArray alloc]init];
    api_language=@"cn";
    
    myscroller=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, mywidth, myheight-64-49)];
    myscroller.contentSize=CGSizeMake(mywidth, 910/2+49+200+40);
    myscroller.backgroundColor=[UIColor groupTableViewBackgroundColor];
    myscroller.userInteractionEnabled=YES;
    [self.view addSubview:myscroller];
    
    myimageview1=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, mywidth, 910/2)];
    [myscroller addSubview:myimageview1];
    
    UILabel *infolabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 910/2, 320, 49)];
    infolabel.text=@"旋转屏幕查看公司里程碑" ;
    infolabel.font=[UIFont fontWithName:@"Heiti TC" size:15];
    infolabel.textAlignment=YES;
    [myscroller addSubview:infolabel];
    
    myMapview=[[MKMapView alloc]initWithFrame:CGRectMake(0,myheight-64 , 320, 200)];
    [myscroller addSubview:myMapview];
    
    myMapview.delegate=self;
    myMapview.showsUserLocation=YES;
    if ([CLLocationManager locationServicesEnabled])
    {
        self.myLocationManager = [[CLLocationManager alloc] init];
        [myLocationManager setDistanceFilter:kCLDistanceFilterNone];
        self.myLocationManager.delegate =self;
        self.myLocationManager.desiredAccuracy=kCLLocationAccuracyBest;
        //        self.myLocationManager.purpose =
        //        @"To provide functionality based on user's current location.";
        myMapview.mapType=MKMapTypeStandard;
        
        /* Set the map type to Standard */
        self.myMapview.mapType = MKMapTypeStandard;
        
        [self.myLocationManager startUpdatingLocation];
    } else {
        /* Location services are not enabled.
         Take appropriate action: for instance, prompt the user to enable location services */
        NSLog(@"Location services are not enabled");
    }
    
    UIView *videoview=[[UIView alloc]initWithFrame:CGRectMake(0, myheight-64+200, 320, 40)];
    [myscroller addSubview:videoview];
    UIImageView *videoimage=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"公司视频"]];
    [videoimage setFrame:CGRectMake(90, 5, 30, 30)];
    [videoview addSubview:videoimage];
    UILabel *videolabel=[[UILabel alloc]initWithFrame:CGRectMake(100, 0, 160, 40)];
    videolabel.text=@"公司宣传视频";
    videolabel.font=[UIFont fontWithName:@"Heiti TC" size:16];
    videolabel.textAlignment=YES;
    [videoview addSubview:videolabel];
    
    UIButton *videobutton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    [videoview addSubview:videobutton];
    [videobutton addTarget:self action:@selector(CompanyVideo) forControlEvents:UIControlEventTouchUpInside];
    
    longpicture=[[UIView alloc]initWithFrame:CGRectMake(0, 0, myheight, mywidth)];
    longpicture.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:longpicture];
    longpicture.hidden=YES;
    
    UIScrollView *history=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, myheight, mywidth)];
    history.contentSize=CGSizeMake(mywidth, 2290/2);
    [longpicture addSubview:history];
    
    UIImageView *historyimage=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"历史里程碑.png"]];
    [historyimage setFrame:CGRectMake(0, 0, myheight, 2290/2)];
    [history addSubview:historyimage];
    
    requestlanguages=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:HTTP_getlanguages]];
    requestlanguages.tag=1;
    [requestlanguages setDelegate:self];
    [requestlanguages setTimeOutSeconds:60];
    [requestlanguages setDidFinishSelector:@selector(requestFinished:)];
    [requestlanguages setDidFailSelector:@selector(requestFailed:)];
    [requestlanguages startAsynchronous];
    
    apistring=[NSString stringWithFormat:@"%@?lang=%@",HTTP_info,api_language];
    NSLog(@"%@",apistring);
    requestinfo=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:apistring]];
    requestinfo.tag=2;
    [requestinfo setDelegate:self];
    [requestinfo setTimeOutSeconds:60];
    [requestinfo setDidFinishSelector:@selector(requestFinished:)];
    [requestinfo setDidFailSelector:@selector(requestFailed:)];
    [requestinfo startAsynchronous];
    
    navcenter=[[UIView alloc]initWithFrame:CGRectMake(0,0,160, 44)];
    navcenter.backgroundColor=[UIColor clearColor];
    UILabel *mylabel=[[UILabel alloc]initWithFrame:CGRectMake(40, 0, 80, 44)];
    mylabel.text=@"介绍";
    mylabel.textAlignment=YES;
    mylabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:16];
    mylabel.backgroundColor=[UIColor clearColor];
    [navcenter addSubview:mylabel];
    
    activityindicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(30,12,20, 20)];
    activityindicator.color=[UIColor blackColor];
    [navcenter addSubview:activityindicator];
    activityindicator.hidden=NO;
    [activityindicator startAnimating];

}

//-------------------------------------------------------------------------------------------------------------------------------------------------

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request.tag==1) {
        response=[request responseString];
        
        [self jsonStringToObject];
        languagesdic=object;
        NSLog(@"%@",languagesdic);
        
        for (int i=0; i<[[languagesdic objectForKey:@"data"]count]; i++) {
            [languagelist_country addObject:[[[languagesdic objectForKey:@"data"] objectAtIndex:i]objectForKey:@"lang_title"]];
            [languagelist_lang addObject:[[[languagesdic objectForKey:@"data"] objectAtIndex:i]objectForKey:@"lang"]];
        }
        
        languageview=[[UIView alloc]initWithFrame:CGRectMake(320, 64, 80, 40*number)];
        languageview.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        languageview.alpha=0;
        [self.view addSubview:languageview];

        for (int i=0; i<=number-1; i++) {
            UIButton *lbt=[[UIButton alloc]initWithFrame:CGRectMake(0, 40*i, 80, 40)];
            [lbt setTitle:[NSString stringWithFormat:@"%@",[languagelist_country objectAtIndex:i]] forState:UIControlStateNormal];
            [lbt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            lbt.titleLabel.font=[UIFont systemFontOfSize:15];
            lbt.titleLabel.textAlignment=YES;
            lbt.showsTouchWhenHighlighted=YES;
            lbt.tag=i;
            [lbt addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
            [languageview addSubview:lbt];
        }

    }else if (request.tag==2) {
        response=[request responseString];
        
        [self jsonStringToObject];
        infodic=object;
        NSLog(@"%@",infodic);

        NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[[infodic objectForKey:@"data"]objectAtIndex:0]objectForKey:@"file"]]];
        [myimageview1 sd_setImageWithURL:url];
        [activityindicator stopAnimating];

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
-(void)confirm:(UIButton *)sender
{
    api_language=[languagelist_lang objectAtIndex:sender.tag];
    NSLog(@"%@",api_language);
    [UIView animateWithDuration:0.3 animations:^{
        [languageview setFrame:CGRectMake(320, 64, 80, 40*number)];
    }];
    isopen=NO;
}

-(void)selectlanguage
{
    if (isopen==NO) {
        [UIView animateWithDuration:0.3 animations:^{
            [languageview setFrame:CGRectMake(240, 64, 80, 40*number)];
            languageview.alpha=1;
        }];
        isopen=YES;
    }else if(isopen==YES)
    {
        [UIView animateWithDuration:0.3 animations:^{
            [languageview setFrame:CGRectMake(320, 64, 80, 40*number)];
            languageview.alpha=0;
        }];
        isopen=NO;
    }
}

-(void)CompanyVideo
{
    ShowMovieViewController *showmoviewvc=[[ShowMovieViewController alloc]initWithNibName:@"ShowMovieViewController" bundle:nil];
    showmoviewvc.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self.navigationController pushViewController:showmoviewvc animated:NO];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    /* We received the new location */
    CLLocationCoordinate2D coor2d=CLLocationCoordinate2DMake(31.275342,120.817883);
    CustomAnnotation *annotation =
    [[CustomAnnotation alloc] initWithCoordinates:coor2d
                                            title:@"YUDO柳道万和" subTitle:@"苏州市甪直镇凌港路29号"];
    float zoomLevel=0.01;
    MKCoordinateRegion region = MKCoordinateRegionMake(coor2d, MKCoordinateSpanMake(zoomLevel, zoomLevel));
    [myMapview setRegion:[myMapview regionThatFits:region] animated:YES];
    //添加大头针
    [myMapview addAnnotation:annotation];
    
    [self.myLocationManager stopUpdatingLocation];
    NSLog(@"Latitude = %f", coor2d.latitude);
    NSLog(@"Longitude = %f", coor2d.longitude);
    
    //---------------位置反编码----------------
    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error){
        for (CLPlacemark *place in placemarks) {
            NSLog(@"name=%@",place.name);                         //位置名
            NSLog(@"thoroughfare=%@",place.thoroughfare);         //街道
            NSLog(@"subThoroughfare=%@",place.subThoroughfare);   //子街道
            NSLog(@"locality=%@",place.locality);                 //市
            NSLog(@"subLocality=%@",place.subLocality);           //区
            NSLog(@"country=%@",place.country);                   //国家
            
        }
    }
     ];
    
    //自动显示标注
    [self.myMapview selectAnnotation:annotation animated:YES];
    
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    /* Failed to receive user's location */
    NSLog(@"定位失败");
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
//        [myMapview setCenterCoordinate:userLocation.coordinate animated:YES];
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    //判断是否为当前设备的annotation
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    static NSString *indentifer=@"annotation";
    MKPinAnnotationView *MKAnnotationView=(MKPinAnnotationView  *)[myMapview dequeueReusableAnnotationViewWithIdentifier:indentifer];
    if (MKAnnotationView==nil) {
        //MKPinAnnotationView是大头针视图
        MKAnnotationView=[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:indentifer];
        MKAnnotationView.pinColor=MKPinAnnotationColorRed;
        
        //是否显示大头针标题
        MKAnnotationView.canShowCallout=YES;
        
        //从天而降动画
        MKAnnotationView.animatesDrop=YES;
        
        UIButton *button=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
        MKAnnotationView.rightCalloutAccessoryView=button;
    }
    
    MKAnnotationView.annotation=annotation;
    return MKAnnotationView;
}


-(void)buttonAction
{
    UIAlertView *callalter=[[UIAlertView alloc]initWithTitle:nil message:@"呼叫 (86)512-6504-8882" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
    [callalter show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"cancel");
            
            break;
            
        case 1:
            NSLog(@"ok");
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://8651265048882"]]];
            break;
            
        default:
            break;
    }
}

- (void)orientationChanged:(NSNotification *)note  {
    UIDeviceOrientation o = [[UIDevice currentDevice] orientation];
    
    
    switch (o) {
        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
            self.navigationController.navigationBarHidden=NO;
            self.tabBarController.tabBar.hidden=NO;
            longpicture.hidden=YES;
            languageview.hidden=NO;
            
            break;
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            self.navigationController.navigationBarHidden=YES;
            self.tabBarController.tabBar.hidden=YES;
            longpicture.hidden=NO;
            languageview.hidden=YES;

            break;
        case UIDeviceOrientationLandscapeLeft:      // Device oriented horizontally, home button on the right
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
            self.navigationController.navigationBarHidden=YES;
            self.tabBarController.tabBar.hidden=YES;
            longpicture.hidden=NO;
            languageview.hidden=YES;

            
            break;
        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
            self.navigationController.navigationBarHidden=YES;
            self.tabBarController.tabBar.hidden=YES;
            longpicture.hidden=NO;
            languageview.hidden=YES;

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
