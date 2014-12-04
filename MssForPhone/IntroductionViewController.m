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
#import "IntroductionCell.h"
#import "CNdetailViewController.h"
#import "ProductsViewController.h"

#define mywidth  self.view.bounds.size.width
#define myheight  self.view.bounds.size.height
#define number languagelist_country.count

BOOL isopen;

@interface IntroductionViewController ()
{
    UIView *longpicture;
    UIView *languageview;
    UIImageView *historyimage;
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
    NSInteger companynumber;
    NSInteger networknumber;
    BOOL languagedic_finished;
    BOOL infodic_finished;
    NSString *url_buttomvideo;
    UILabel *mylabel;//标题
    UILabel *infolabel;//里程碑
    
    NSString *introduction;
    NSString *company;
    NSString *net;
    NSString *video;
    NSString *companyvideo;
    NSString *historystring;
}
@end

@implementation IntroductionViewController
@synthesize myscroller;
@synthesize myimageview1;
@synthesize myMapview;
@synthesize myLocationManager;
@synthesize yudotable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initlabel];
        [self.tabBarItem setImage:[UIImage imageNamed:@"introduction.png"]];
        self.tabBarItem.title=introduction;

    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.title=introduction;
    self.tabBarController.navigationItem.titleView=navcenter;
    self.navigationController.navigationBar.hidden=NO;
    
    //----- SETUP DEVICE ORIENTATION CHANGE NOTIFICATION -----
    UIDevice *device = [UIDevice currentDevice]; //Get the device object
    [device beginGeneratingDeviceOrientationNotifications]; //Tell it to start monitoring the accelerometer for orientation
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; //Get the notification centre for the app
    [nc addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:device];

    AppDelegate *delegate=[[UIApplication sharedApplication]delegate];
    delegate.Orientations=YES;
    
    //---------------------------------------------------------------------------
    UIButton *languagebt = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    [languagebt addTarget:self action:@selector(selectlanguage) forControlEvents:UIControlEventTouchUpInside];
    [languagebt setBackgroundImage:[UIImage imageNamed:@"语言2.png"] forState:UIControlStateNormal];
    UIBarButtonItem *leftbt = [[UIBarButtonItem alloc]initWithCustomView:languagebt];
    self.tabBarController.navigationItem.rightBarButtonItem=leftbt;
    //---------------------------------------------------------------------------

    api_language=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lan"]];
    apistring=[NSString stringWithFormat:@"%@?lang=%@",HTTP_yudoinfo,api_language];
    requestinfo=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:apistring]];
    requestinfo.tag=2;
    [requestinfo setDelegate:self];
    [requestinfo setTimeOutSeconds:60];
    [requestinfo setDidFinishSelector:@selector(requestFinished:)];
    [requestinfo setDidFailSelector:@selector(requestFailed:)];
    [requestinfo startAsynchronous];

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

    requestlanguages=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:HTTP_getlanguages]];
    requestlanguages.tag=1;
    [requestlanguages setDelegate:self];
    [requestlanguages setTimeOutSeconds:60];
    [requestlanguages setDidFinishSelector:@selector(requestFinished:)];
    [requestlanguages setDidFailSelector:@selector(requestFailed:)];
    [requestlanguages startAsynchronous];

    
    myscroller=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, mywidth, myheight-49-64)];
    myscroller.backgroundColor=[UIColor groupTableViewBackgroundColor];
    myscroller.userInteractionEnabled=YES;
    myscroller.delegate=self;
    [self.view addSubview:myscroller];

    
    myimageview1=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, mywidth, 910/2)];
    [myscroller addSubview:myimageview1];
    
    infolabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 910/2, mywidth, 49)];
    infolabel.text=historystring;
    infolabel.backgroundColor=[UIColor whiteColor];
    infolabel.font=[UIFont fontWithName:@"Heiti TC" size:15];
    infolabel.textAlignment=YES;
    [myscroller addSubview:infolabel];


    yudotable=[[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    yudotable.backgroundColor=[UIColor clearColor];
    yudotable.delegate=self;
    yudotable.dataSource=self;
    yudotable.scrollEnabled=NO;
    [myscroller addSubview:yudotable];
    
    longpicture=[[UIView alloc]initWithFrame:CGRectMake(0, 0, myheight, mywidth)];
    longpicture.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:longpicture];
    longpicture.alpha=0;
    
    UIScrollView *history=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, myheight, mywidth)];
    history.contentSize=CGSizeMake(mywidth, 2290/2);
    [longpicture addSubview:history];
    
    historyimage=[[UIImageView alloc]init];
    [history addSubview:historyimage];
    

    navcenter=[[UIView alloc]initWithFrame:CGRectMake(0,0,200, 44)];
    navcenter.backgroundColor=[UIColor clearColor];
    mylabel=[[UILabel alloc]initWithFrame:CGRectMake(30, 0, 140, 44)];
    mylabel.text=introduction;
    mylabel.textAlignment=YES;
    mylabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:16];
    mylabel.backgroundColor=[UIColor clearColor];
    [navcenter addSubview:mylabel];
    
    activityindicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(30,12,20, 20)];
    activityindicator.color=[UIColor blackColor];
    [navcenter addSubview:activityindicator];
    [activityindicator startAnimating];
    activityindicator.hidesWhenStopped=YES;
    
    languageview=[[UIView alloc]initWithFrame:CGRectZero];
    languageview.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    languageview.alpha=0;
    [self.view addSubview:languageview];
    
}

-(void)initlabel
{
    NSBundle *bundle=[NSBundle mainBundle];
    NSURL *plistURL=[bundle URLForResource:@"Localization" withExtension:@"plist"];
    NSDictionary *root=[[NSDictionary alloc]initWithContentsOfURL:plistURL];
//    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lan"]);
    NSDictionary *dic=[root objectForKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"lan"]];
    introduction=[dic objectForKey:@"introduction"];
    company=[dic objectForKey:@"company"];
    net=[dic objectForKey:@"net"];
    video=[dic objectForKey:@"video"];
    companyvideo=[dic objectForKey:@"companyvideo"];
    historystring=[dic objectForKey:@"history"];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request.tag==1) {
        response=[request responseString];
        
        [self jsonStringToObject];
        languagesdic=object;
//        NSLog(@"%@",languagesdic);
        
        for (int i=0; i<[[languagesdic objectForKey:@"data"]count]; i++) {
            [languagelist_country addObject:[[[languagesdic objectForKey:@"data"] objectAtIndex:i]objectForKey:@"lang_title"]];
            [languagelist_lang addObject:[[[languagesdic objectForKey:@"data"] objectAtIndex:i]objectForKey:@"lang"]];
        }
        
        languageview.frame=CGRectMake(mywidth, 64, 90, 40*number);

        for (int i=0; i<=number-1; i++) {
            UIButton *lbt=[[UIButton alloc]initWithFrame:CGRectMake(0, 40*i, 90, 40)];
            [lbt setTitle:[NSString stringWithFormat:@"%@",[languagelist_country objectAtIndex:i]] forState:UIControlStateNormal];
            [lbt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            lbt.titleLabel.font=[UIFont systemFontOfSize:15];
            lbt.titleLabel.textAlignment=YES;
            lbt.showsTouchWhenHighlighted=YES;
            lbt.tag=i;
            [lbt addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
            [languageview addSubview:lbt];
            languagedic_finished=YES;
        }

    }else if (request.tag==2) {
        response=[request responseString];
        
        [self jsonStringToObject];
        infodic=object;
        NSLog(@"%@",infodic);

        NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[[[infodic objectForKey:@"data"]objectForKey:@"top_images"] objectAtIndex:0]objectForKey:@"file"]]];
        [myimageview1 sd_setImageWithURL:url];
        
        
        float scale=[[NSString stringWithFormat:@"%@",[[[[infodic objectForKey:@"data"]objectForKey:@"top_images"] objectAtIndex:1]objectForKey:@"width"]] floatValue]/myheight;
        float imageheight=[[NSString stringWithFormat:@"%@",[[[[infodic objectForKey:@"data"]objectForKey:@"top_images"] objectAtIndex:1]objectForKey:@"height"]] floatValue];
        float imagewidth=[[NSString stringWithFormat:@"%@",[[[[infodic objectForKey:@"data"]objectForKey:@"top_images"] objectAtIndex:1]objectForKey:@"width"]] floatValue];
        
        [historyimage setFrame:CGRectMake(0, 0, imagewidth/scale, imageheight/scale)];
         NSURL *url_history=[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[[[infodic objectForKey:@"data"]objectForKey:@"top_images"] objectAtIndex:1]objectForKey:@"file"]]];
        [historyimage sd_setImageWithURL:url_history];
        
        companynumber=[[[infodic objectForKey:@"data"] objectForKey:@"companies"]count];
        networknumber=[[[infodic objectForKey:@"data"] objectForKey:@"net"]count];
        
        [yudotable setFrame:CGRectMake(0, 910/2+49, mywidth, 56*3+44*7)];
        
        url_buttomvideo=[[[[infodic objectForKey:@"data"] objectForKey:@"bottom_video"]objectAtIndex:0] objectForKey:@"file"];
        infodic_finished=YES;
        
        [yudotable reloadData];
    }

    if (languagedic_finished&&infodic_finished) {
        myscroller.contentSize=CGSizeMake(mywidth, 910/2+49+56*3+44*7+20);
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
    [[NSUserDefaults standardUserDefaults]setObject:api_language forKey:@"lan"];
    [[NSUserDefaults standardUserDefaults]synchronize];
//    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lan"]);
    [UIView animateWithDuration:0.3 animations:^{
        [languageview setFrame:CGRectMake(mywidth, 64, 90, 40*number)];
        languageview.alpha=0;
    }];
    isopen=NO;
    
    api_language=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lan"]];
    apistring=[NSString stringWithFormat:@"%@?lang=%@",HTTP_yudoinfo,api_language];
    requestinfo=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:apistring]];
    requestinfo.tag=2;
    [requestinfo setDelegate:self];
    [requestinfo setTimeOutSeconds:60];
    [requestinfo setDidFinishSelector:@selector(requestFinished:)];
    [requestinfo setDidFailSelector:@selector(requestFailed:)];
    [requestinfo startAsynchronous];
    
    [self initlabel];
    
    self.tabBarItem.title=introduction;
    self.tabBarController.title=introduction;
    mylabel.text=introduction;
    infolabel.text=historystring;
    [yudotable reloadData];
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ChangeBaritemNotificaton" object:nil];

}

-(void)selectlanguage
{
    if (isopen==NO) {
        [UIView animateWithDuration:0.3 animations:^{
            [languageview setFrame:CGRectMake(mywidth-90, 64, 90, 40*number)];
            languageview.alpha=1;
        }];
        isopen=YES;
    }else if(isopen==YES)
    {
        [UIView animateWithDuration:0.3 animations:^{
            [languageview setFrame:CGRectMake(mywidth, 64, 90, 40*number)];
            languageview.alpha=0;
        }];
        isopen=NO;
    }
    
   
}

- (void)orientationChanged:(NSNotification *)note  {
    UIDeviceOrientation o = [[UIDevice currentDevice] orientation];
    
    
    switch (o) {
        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
            self.navigationController.navigationBarHidden=NO;
            self.tabBarController.tabBar.hidden=NO;
            longpicture.alpha=0;
            languageview.hidden=NO;
            
            break;
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            self.navigationController.navigationBarHidden=YES;
            self.tabBarController.tabBar.hidden=YES;
            longpicture.alpha=1;
            languageview.hidden=YES;
            
            break;
        case UIDeviceOrientationLandscapeLeft:      // Device oriented horizontally, home button on the right
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
            self.navigationController.navigationBarHidden=YES;
            self.tabBarController.tabBar.hidden=YES;
            longpicture.alpha=1;
            languageview.hidden=YES;
            
            
            break;
        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
            self.navigationController.navigationBarHidden=YES;
            self.tabBarController.tabBar.hidden=YES;
            longpicture.alpha=1;
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (section==0) {
        return companynumber;
    }else if(section==1)
    {
        return networknumber;
    }else if(section==2)
    {
        return 1;
    }
    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 3;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    if (section==0)
    {
        return company;
    }else if (section==1)
    {
        return net;
    }else if(section==2)
    {
        return video;
    }
        return nil;
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
{
    //    if (section==0)
    //    {
    //        return @"abc-end";
    //    }else if (section==1)
    //    {
    //        return @"123-end";
    //    }else
    return nil;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    static NSString *cellIdentifier = @"IntroductionCell";
    UINib *nib = [UINib nibWithNibName:@"IntroductionCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    IntroductionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.mylabel2.hidden=YES;
    for (int i=0; i<companynumber; i++) {
        if (indexPath.section==0&&indexPath.row==i) {
            cell.mylabel.text=[[[[infodic objectForKey:@"data"] objectForKey:@"companies"] objectAtIndex:i] objectForKey:@"company"];
            [cell.myimageview sd_setImageWithURL:[NSURL URLWithString:[[[[infodic objectForKey:@"data"] objectForKey:@"companies"] objectAtIndex:i] objectForKey:@"ico"]]];
        }
    }
    for (int j=0; j<networknumber; j++) {
        if (indexPath.section==1&&indexPath.row==j) {
            cell.mylabel.hidden=YES;
            cell.myimageview.hidden=YES;
            cell.mylabel2.hidden=NO;
            cell.mylabel2.text=[[[[infodic objectForKey:@"data"] objectForKey:@"net"] objectAtIndex:j] objectForKey:@"net"];
        }
    }
    
    if (indexPath.section==2) {
        cell.mylabel.hidden=YES;
        cell.myimageview.hidden=YES;
        cell.mylabel2.hidden=NO;
        cell.mylabel2.text=companyvideo;
    }
    
    cell.backgroundColor=[UIColor whiteColor];
    cell.mylabel.font=[UIFont systemFontOfSize:15];
    cell.mylabel2.font=[UIFont systemFontOfSize:15];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (int i=0; i<companynumber; i++) {
        if (indexPath.section==0&&indexPath.row==i) {
            CNdetailViewController *cnvc=[[CNdetailViewController alloc]initWithNibName:@"CNdetailViewController" bundle:nil];
            cnvc.idstring=[[[[infodic objectForKey:@"data"] objectForKey:@"companies"] objectAtIndex:indexPath.row]objectForKey:@"id"];
            cnvc.navtitle=[[[[infodic objectForKey:@"data"] objectForKey:@"companies"] objectAtIndex:indexPath.row]objectForKey:@"company"];
            NSLog(@"CNdetailViewController id=%@",cnvc.idstring);
            cnvc.tag=1;
            cnvc.api_language=api_language;
            [self.navigationController pushViewController:cnvc animated:YES];
        }
    }
    for (int j=0; j<networknumber; j++) {
        if (indexPath.section==1&&indexPath.row==j) {
            CNdetailViewController *cnvc=[[CNdetailViewController alloc]initWithNibName:@"CNdetailViewController" bundle:nil];
            cnvc.idstring=[[[[infodic objectForKey:@"data"] objectForKey:@"net"] objectAtIndex:indexPath.row]objectForKey:@"id"];
            cnvc.navtitle=[[[[infodic objectForKey:@"data"] objectForKey:@"net"] objectAtIndex:indexPath.row]objectForKey:@"net"];
            NSLog(@"CNdetailViewController id=%@",cnvc.idstring);
            cnvc.tag=2;
            cnvc.api_language=api_language;
            [self.navigationController pushViewController:cnvc animated:YES];
        }
    }

    if (indexPath.section==2&&indexPath.row==0) {
        NSLog(@"公司宣传视频");
        ShowMovieViewController *showmoviewvc=[[ShowMovieViewController alloc]initWithNibName:@"ShowMovieViewController" bundle:nil];
        showmoviewvc.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        showmoviewvc.videourl=url_buttomvideo;
        showmoviewvc.navtitle=companyvideo;
        [self.navigationController pushViewController:showmoviewvc animated:YES];

    }
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
