//
//  ProductsViewController.m
//  MssForPhone
//
//  Created by it-mobile on 14/11/1.
//  Copyright (c) 2014年 Paul. All rights reserved.
//

#import "ProductsViewController.h"
#import "AppDelegate.h"
#import "ProductsDetailViewController.h"
#import "API.h"
#import "UIImageView+WebCache.h"
#import "ASIHTTPRequest.h"


#define heightwidth (self.view.bounds.size.width/2-1)

@interface ProductsViewController ()
{
    UISearchBar *productsearch;
    UIView *searchView;
    
    ASIHTTPRequest *requestproducts;
    NSString *response;
    id object;
    NSDictionary *productsdic;
    NSString *apistring;
    NSString *api_language;
    int numbers;
}
@end

@implementation ProductsViewController
@synthesize productscroller;
@synthesize mysearchbar;
@synthesize alphaview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.tabBarItem setImage:[UIImage imageNamed:@"product.png"]];
        self.tabBarItem.title=@"产品";
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.title=@"产品";
    self.navigationController.navigationBar.hidden=YES;
    self.tabBarController.navigationItem.titleView=nil;
    self.tabBarController.navigationItem.rightBarButtonItem=nil;

    AppDelegate *delegate=[[UIApplication sharedApplication]delegate];
    delegate.Orientations=NO;

}


- (void)viewDidLoad {
    [super viewDidLoad];
    api_language=@"cn";
    
    apistring=[NSString stringWithFormat:@"%@?lang=%@",HTTP_productslist,api_language];
    requestproducts=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:apistring]];
    requestproducts.tag=1;
    [requestproducts setDelegate:self];
    [requestproducts setTimeOutSeconds:60];
    [requestproducts setDidFinishSelector:@selector(requestFinished:)];
    [requestproducts setDidFailSelector:@selector(requestFailed:)];
    [requestproducts startAsynchronous];
    
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
        productsdic=object;
        NSLog(@"%@",productsdic);
        
        numbers=(int)[[productsdic objectForKey:@"data"]count];
        NSLog(@"%d",numbers);
        
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
    NSURL *url=[[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@",[[[productsdic objectForKey:@"data"]objectAtIndex:(ptimage.tag-1)] objectForKey:@"ico"]]];
    NSLog(@"%@",url);
    [ptimage sd_setImageWithURL:url];
    
}

//点击图片目标函数
-(void)click:(UIButton *)sender
{
    ProductsDetailViewController *productsdetailvc=[[ProductsDetailViewController alloc]initWithNibName:@"ProductsDetailViewController" bundle:nil];
    productsdetailvc.idstring=[NSString stringWithFormat:@"%@",[[[productsdic objectForKey:@"data"]objectAtIndex:(sender.tag-1)] objectForKey:@"id"]];
    NSLog(@"ProductsDetailViewController id=%@",productsdetailvc.idstring);
    productsdetailvc.navtitle=[NSString stringWithFormat:@"%@",[[[productsdic objectForKey:@"data"]objectAtIndex:(sender.tag-1)] objectForKey:@"product"]];
    [self.navigationController pushViewController:productsdetailvc animated:YES];
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
