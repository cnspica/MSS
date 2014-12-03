//
//  DataViewController.m
//  MssForPhone
//
//  Created by it-mobile on 14/11/19.
//  Copyright (c) 2014年 Paul. All rights reserved.
//

#import "DataViewController.h"
#import "AppDelegate.h"
#import "DataDetailViewController.h"
#import "API.h"
#import "UIImageView+WebCache.h"
#import "ASIHTTPRequest.h"


#define heightwidth (self.view.bounds.size.width/2-1)

@interface DataViewController ()
{
    UISearchBar *productsearch;
    UIView *searchView;
    
    ASIHTTPRequest *requestdatas;
    NSString *response;
    id object;
    NSDictionary *datadic;
    NSString *apistring;
    NSString *api_language;
    int numbers;
    
    NSString *Parameters;
}

@end

@implementation DataViewController
@synthesize productscroller;
@synthesize mysearchbar;
@synthesize alphaview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initlabel];
        [self.tabBarItem setImage:[UIImage imageNamed:@"technology.png"]];
        self.tabBarItem.title=Parameters;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeitem) name:@"ChangeBaritemNotificaton" object:nil];
    }
    return self;
}

-(void)changeitem
{
    [self initlabel];
    self.tabBarItem.title=Parameters;
}

-(void)initlabel
{
    NSBundle *bundle=[NSBundle mainBundle];
    NSURL *plistURL=[bundle URLForResource:@"Localization" withExtension:@"plist"];
    NSDictionary *root=[[NSDictionary alloc]initWithContentsOfURL:plistURL];
//    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lan"]);
    NSDictionary *dic=[root objectForKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"lan"]];
    Parameters=[dic objectForKey:@"data"];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self initlabel];
    self.tabBarItem.title=Parameters;

    self.tabBarController.title=Parameters;
    self.navigationController.navigationBar.hidden=YES;
    self.tabBarController.navigationItem.titleView=nil;
    self.tabBarController.navigationItem.rightBarButtonItem=nil;
    
    AppDelegate *delegate=[[UIApplication sharedApplication]delegate];
    delegate.Orientations=NO;
    
    api_language=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lan"]];
//    NSLog(@"%@",api_language);
    apistring=[NSString stringWithFormat:@"%@?lang=%@",HTTP_technologieslist,api_language];
    requestdatas=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:apistring]];
    requestdatas.tag=1;
    [requestdatas setDelegate:self];
    [requestdatas setTimeOutSeconds:60];
    [requestdatas setDidFinishSelector:@selector(requestFinished:)];
    [requestdatas setDidFailSelector:@selector(requestFailed:)];
    [requestdatas startAsynchronous];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor groupTableViewBackgroundColor];
    
    alphaview=[[UIView alloc]initWithFrame:CGRectMake(0,self.navigationController.navigationBar.bounds.size.height+20, self.view.bounds.size.width, self.view.bounds.size.height)];
    alphaview.backgroundColor=[UIColor blackColor];
    alphaview.alpha=0.5;
    [self.view addSubview:alphaview];
    alphaview.hidden=YES;
    
    UITapGestureRecognizer *hideGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidekb)];
    [alphaview addGestureRecognizer:hideGesture];
    
    
    
}

//-------------------------------------------------------------------------------------------------------------------------------------------------

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request.tag==1) {
        response=[request responseString];
        
        [self jsonStringToObject];
        datadic=object;
//        NSLog(@"%@",datadic);
        
        numbers=(int)[[datadic objectForKey:@"data"]count];
//        NSLog(@"%d",numbers);
        
        productscroller.backgroundColor=[UIColor clearColor];
        if (numbers%2==0) {
            productscroller.contentSize=CGSizeMake(self.view.bounds.size.width, (heightwidth+1)*numbers/2);
        }else {
            productscroller.contentSize=CGSizeMake(self.view.bounds.size.width, (heightwidth+1)*(numbers+1)/2);
        }
        productscroller.pagingEnabled=NO;
        [self initscroller];
        
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

//初始化图片位置
-(void)initscroller
{

    for (int i=1; i<=numbers; i++) {
        int width=heightwidth;
        
        if (i%2==0) {
            //偶数
            int temp=(i+1)/2;
            UIImageView *ptimage2=[[UIImageView alloc]initWithFrame:CGRectMake(1+width, temp+(temp-1)*width, width, width)];
            ptimage2.tag=i;
            ptimage2.userInteractionEnabled=YES;
            ptimage2.backgroundColor=[UIColor whiteColor];
            [productscroller addSubview:ptimage2];
            [self initscrollerpicture:ptimage2];
            
            UIButton *ptbutton2=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, width, width)];
            ptbutton2.tag=i;

            [ptimage2 addSubview:ptbutton2];
            [ptbutton2 addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        else
        {
            //奇数
            int temp=(i+1)/2;
            UIImageView *ptimage1=[[UIImageView alloc]initWithFrame:CGRectMake(0, temp+(temp-1)*width, width, width)];
            ptimage1.tag=i;
            ptimage1.userInteractionEnabled=YES;
            ptimage1.backgroundColor=[UIColor whiteColor];
            [productscroller addSubview:ptimage1];
            [self initscrollerpicture:ptimage1];
            
            UIButton *ptbutton1=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, width, width)];
            ptbutton1.tag=i;
            
            [ptimage1 addSubview:ptbutton1];
            [ptbutton1 addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
}


//初始化图片资源
-(void)initscrollerpicture:(UIImageView *)ptimage
{
    NSURL *url=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@",[[[datadic objectForKey:@"data"]objectAtIndex:(ptimage.tag-1)] objectForKey:@"ico"]]];
//    NSLog(@"%@",url);
    [ptimage sd_setImageWithURL:url];
    
}

//点击图片目标函数
-(void)click:(UIButton *)sender
{
    DataDetailViewController *datasdetailvc=[[DataDetailViewController alloc]initWithNibName:@"DataDetailViewController" bundle:nil];
    datasdetailvc.idstring=[NSString stringWithFormat:@"%@",[[[datadic objectForKey:@"data"]objectAtIndex:(sender.tag-1)] objectForKey:@"id"]];
    NSLog(@"DataDetailViewController id=%@",datasdetailvc.idstring);
    datasdetailvc.navtitle=[NSString stringWithFormat:@"%@",[[[datadic objectForKey:@"data"]objectAtIndex:(sender.tag-1)] objectForKey:@"technology"]];
    datasdetailvc.api_language=api_language;
    [self.navigationController pushViewController:datasdetailvc animated:YES];
}

//搜索delegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    mysearchbar.showsCancelButton=YES;
    for(id cc in [mysearchbar subviews])
    {
        for (UIView *view in [cc subviews]) {
            
            if ([NSStringFromClass(view.class)                 isEqualToString:@"UINavigationButton"]) {
                
                UIButton *btn = (UIButton *)view;
                [btn setTitle:@"取消" forState:UIControlStateNormal];
                
            }
            
        }
        
    }
    alphaview.hidden=NO;
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [mysearchbar resignFirstResponder];
    mysearchbar.showsCancelButton=NO;
    mysearchbar.text=nil;
    alphaview.hidden=YES;
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}

-(void)hidekb
{
    [mysearchbar resignFirstResponder];
    mysearchbar.showsCancelButton=NO;
    mysearchbar.text=nil;
    alphaview.hidden=YES;
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
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
