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

#define mywidth self.view.bounds.size.width
#define myheight self.view.bounds.size.height

@interface TechnologyViewController ()

@end

@implementation TechnologyViewController
@synthesize myscroller;
@synthesize myimageview1;
@synthesize myimageview2;
@synthesize myimageview3;
@synthesize myimageview4;

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
    self.tabBarController.navigationItem.titleView=nil;

    AppDelegate *delegate=[[UIApplication sharedApplication]delegate];
    delegate.Orientations=NO;
    self.tabBarController.navigationItem.rightBarButtonItem=nil;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    myscroller=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, mywidth, myheight-64-49)];
    myscroller.contentSize=CGSizeMake(mywidth, 1560/2+10+1511/2+10+2523/2+10+1196/2);
    myscroller.backgroundColor=[UIColor groupTableViewBackgroundColor];
    myscroller.userInteractionEnabled=YES;
    [self.view addSubview:myscroller];
    
    myimageview1=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, mywidth, 1560/2)];
    myimageview1.image=[UIImage imageNamed:@"叠模注塑.png"];
    [myscroller addSubview:myimageview1];
    
    myimageview2=[[UIImageView alloc]initWithFrame:CGRectMake(0, 1560/2+10, mywidth, 1511/2)];
    myimageview2.image=[UIImage imageNamed:@"换色注塑.png"];
    [myscroller addSubview:myimageview2];
    
    myimageview3=[[UIImageView alloc]initWithFrame:CGRectMake(0, 1560/2+10+1511/2+10, mywidth, 2523/2)];
    myimageview3.image=[UIImage imageNamed:@"硅橡胶注塑.png"];
    [myscroller addSubview:myimageview3];
    
    myimageview4=[[UIImageView alloc]initWithFrame:CGRectMake(0, 1560/2+10+1511/2+10+2523/2+10, mywidth, 1196/2)];
    myimageview4.image=[UIImage imageNamed:@"时间控制注塑.png"];
    [myscroller addSubview:myimageview4];
    
    UIButton *timerbutton=[[UIButton alloc]initWithFrame:CGRectMake(0, 1560/2+10+1511/2+10+2523/2+150, mywidth, 200)];
    timerbutton.backgroundColor=[UIColor clearColor];
    [timerbutton addTarget:self action:@selector(timermovie) forControlEvents:UIControlEventTouchUpInside];
    [myscroller addSubview:timerbutton];
    
}

-(void)timermovie
{
    ShowMovieViewController *showmoviewvc=[[ShowMovieViewController alloc]initWithNibName:@"ShowMovieViewController" bundle:nil];
    showmoviewvc.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
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
