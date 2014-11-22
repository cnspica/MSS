//
//  ProductsDetailViewController.m
//  MssForPhone
//
//  Created by it-mobile on 14/11/3.
//  Copyright (c) 2014年 Paul. All rights reserved.
//

#import "ProductsDetailViewController.h"
#import "AppDelegate.h"
#import "ASIHTTPRequest.h"
#import "API.h"
#import "UIImageView+WebCache.h"

#define mywidth  self.view.bounds.size.width
#define myheight  self.view.bounds.size.height

@interface ProductsDetailViewController ()
{
    NSInteger page;
    ASIHTTPRequest *requestpictures;
    NSString *apistring;
    NSString *response;
    id object;
    NSDictionary *productdic;
    NSInteger pagenumber;
}

@end

@implementation ProductsDetailViewController
@synthesize myscroller;
@synthesize subscroller;
@synthesize pagecontrol;
@synthesize idstring;
@synthesize myactivityindicator;
@synthesize navtitle;
@synthesize api_language;

-(void)viewWillAppear:(BOOL)animated
{
    self.title=navtitle;
    self.navigationController.navigationBar.hidden=NO;
    AppDelegate *delegate=[[UIApplication sharedApplication]delegate];
    delegate.Orientations=NO;

}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [requestpictures cancel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    apistring=[NSString stringWithFormat:@"%@?lang=%@&id=%@",HTTP_productinfo,api_language,idstring];
    NSLog(@"%@",apistring);
    requestpictures=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:apistring]];
    requestpictures.tag=1;
    [requestpictures setDelegate:self];
    [requestpictures setTimeOutSeconds:60];
    [requestpictures setDidFinishSelector:@selector(requestFinished:)];
    [requestpictures setDidFailSelector:@selector(requestFailed:)];
    [requestpictures startAsynchronous];
    
    [pagecontrol setCurrentPage:0];
    pagecontrol.currentPageIndicatorTintColor=[UIColor blackColor];
    pagecontrol.pageIndicatorTintColor=[UIColor grayColor];
    
    myscroller=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, mywidth, myheight-100)];
    myscroller.backgroundColor=[UIColor groupTableViewBackgroundColor];
    myscroller.userInteractionEnabled=YES;
    myscroller.maximumZoomScale=2.5;
    myscroller.minimumZoomScale=1;
    myscroller.delegate=self;
    [self.view addSubview:myscroller];
    
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
        productdic=object;
        NSLog(@"%@",productdic);
        pagecontrol.numberOfPages=[[productdic objectForKey:@"data"] count];
        pagenumber=pagecontrol.numberOfPages;
        NSLog(@"共有%li页",(long)pagenumber);
        subscroller=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, mywidth, myheight-100)];
        subscroller.contentSize=CGSizeMake(mywidth*pagenumber, myheight-100);
        subscroller.pagingEnabled=YES;
        subscroller.delegate=self;
        subscroller.tag=1;
        [myscroller addSubview:subscroller];
        
        for (int i=0; i<pagenumber; i++) {
            UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(mywidth*i, 0, mywidth, myheight-100)];
            [imageview sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[[productdic objectForKey:@"data"] objectAtIndex:i] objectForKey:@"file"]]]];
            NSLog(@"%@",[NSString stringWithFormat:@"%@",[[[productdic objectForKey:@"data"] objectAtIndex:i] objectForKey:@"file"]]);
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
