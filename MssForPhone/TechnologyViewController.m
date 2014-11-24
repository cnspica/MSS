//
//  TechnologyViewController.m
//  MssForPhone
//
//  Created by it-mobile on 14/11/1.
//  Copyright (c) 2014年 Paul. All rights reserved.
//

#import "TechnologyViewController.h"
#import "ShowMovieViewController.h"
#import "AppDelegate.h"
#import "ASIHTTPRequest.h"
#import "API.h"
#import "UIImageView+WebCache.h"

#define mywidth self.view.bounds.size.width
#define myheight self.view.bounds.size.height
#define jianju 10

@interface TechnologyViewController ()
{
    ASIHTTPRequest *requesttechnology;
    NSString *response;
    id object;
    NSDictionary *technologydic;
    NSString *apistring;
    NSString *api_language;
    NSInteger tempheight;
    float scale;//比例系数
    UIActivityIndicatorView *activityindicator;
    UIView *navcenter;
    UIButton *timerbutton;
}
@end

@implementation TechnologyViewController
@synthesize myscroller;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.tabBarItem setImage:[UIImage imageNamed:@"technology.png"]];
        self.tabBarItem.title=@"技术";
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.title=@"技术";
    self.navigationController.navigationBar.hidden=NO;
    self.tabBarController.navigationItem.titleView=navcenter;
    self.tabBarController.navigationItem.rightBarButtonItem=nil;

    AppDelegate *delegate=[[UIApplication sharedApplication]delegate];
    delegate.Orientations=NO;
    
    tempheight=0;

    api_language=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lan"]];
    apistring=[NSString stringWithFormat:@"%@?lang=%@",HTTP_technologyinfo,api_language];
    requesttechnology=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:apistring]];
    requesttechnology.tag=1;
    [requesttechnology setDelegate:self];
    [requesttechnology setTimeOutSeconds:60];
    [requesttechnology setDidFinishSelector:@selector(requestFinished:)];
    [requesttechnology setDidFailSelector:@selector(requestFailed:)];
    [requesttechnology startAsynchronous];

}

- (void)viewDidLoad {
    [super viewDidLoad];

    myscroller=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, mywidth, myheight-64-49)];
    myscroller.backgroundColor=[UIColor groupTableViewBackgroundColor];
    myscroller.userInteractionEnabled=YES;
    myscroller.delegate=self;
    [self.view addSubview:myscroller];
    
    
    navcenter=[[UIView alloc]initWithFrame:CGRectMake(0,0,160, 44)];
    navcenter.backgroundColor=[UIColor clearColor];
    UILabel *mylabel=[[UILabel alloc]initWithFrame:CGRectMake(40, 0, 80, 44)];
    mylabel.text=@"技术";
    mylabel.textAlignment=YES;
    mylabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:16];
    mylabel.backgroundColor=[UIColor clearColor];
    [navcenter addSubview:mylabel];
    
    activityindicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(30,12,20, 20)];
    activityindicator.color=[UIColor blackColor];
    [navcenter addSubview:activityindicator];
    [activityindicator startAnimating];
    activityindicator.hidesWhenStopped=YES;
    
    timerbutton=[[UIButton alloc]initWithFrame:CGRectZero];
    timerbutton.backgroundColor=[UIColor clearColor];
    [timerbutton addTarget:self action:@selector(timermovie) forControlEvents:UIControlEventTouchUpInside];
    [myscroller addSubview:timerbutton];


}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request.tag==1) {
        response=[request responseString];
        
        [self jsonStringToObject];
        technologydic=object;
        NSLog(@"%@",technologydic);
        
        for (int i=0; i<[[[technologydic objectForKey:@"data"] objectForKey:@"images"] count]; i++)
        {
            scale=[[[[[technologydic objectForKey:@"data"] objectForKey:@"images"] objectAtIndex:i] objectForKey:@"width"] floatValue]/320;
            NSLog(@"比例系数＝%f",scale);
            
            UIImageView *myimageview=[[UIImageView alloc]initWithFrame:CGRectZero];

            NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[[[technologydic objectForKey:@"data"] objectForKey:@"images"] objectAtIndex:i] objectForKey:@"file"]]];
            NSLog(@"%@",[NSString stringWithFormat:@"%@",[[[[technologydic objectForKey:@"data"] objectForKey:@"images"] objectAtIndex:i] objectForKey:@"file"]]);
            [myimageview sd_setImageWithURL:url];
            
            [myimageview setFrame:CGRectMake(0, tempheight, [[[[[technologydic objectForKey:@"data"] objectForKey:@"images"] objectAtIndex:i] objectForKey:@"width"] floatValue]/scale,[[[[[technologydic objectForKey:@"data"] objectForKey:@"images"] objectAtIndex:i] objectForKey:@"height"] floatValue]/scale)];
            
            NSLog(@"%f",[[[[[technologydic objectForKey:@"data"] objectForKey:@"images"] objectAtIndex:i] objectForKey:@"height"] floatValue]/scale);
            tempheight=jianju+tempheight+[[[[[technologydic objectForKey:@"data"] objectForKey:@"images"] objectAtIndex:i]objectForKey:@"height"] floatValue]/scale;
            [myscroller addSubview:myimageview];
        }
        myscroller.contentSize=CGSizeMake(mywidth,tempheight-jianju);
        [activityindicator stopAnimating];
        
        [timerbutton setFrame:CGRectMake(0, tempheight-500, mywidth, 200)];
        
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

-(void)timermovie
{
    ShowMovieViewController *showmoviewvc=[[ShowMovieViewController alloc]initWithNibName:@"ShowMovieViewController" bundle:nil];
    showmoviewvc.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    showmoviewvc.navtitle=@"时间控制注塑";
    [self.navigationController pushViewController:showmoviewvc animated:NO];
    
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
