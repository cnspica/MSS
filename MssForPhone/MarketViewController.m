//
//  MarketViewController.m
//  MssForPhone
//
//  Created by it-mobile on 14/11/1.
//  Copyright (c) 2014年 Paul. All rights reserved.
//

#import "MarketViewController.h"
#import "AppDelegate.h"
#import "Cell.h"
#import "ProductsDetailViewController.h"
#import "MovieorPictureViewController.h"
#import "API.h"
#import "ASIHTTPRequest.h"

#define mywidth self.view.bounds.size.width
#define myheight self.view.bounds.size.height

BOOL zhankai;

@interface MarketViewController ()
{
    UIScrollView *pickerScroll;
    UIScrollView *picturescroll;
    NSMutableArray *marketlist;
    UIView *selectview;
    UIButton *navbutton;
    UIImageView *jiantou;
    UILabel *myselectlabel;
    UIActivityIndicatorView *myactivityindicator;
    UIView *navcenter;
    
    ASIHTTPRequest *requestmarketlist;
    NSString *response;
    id object;
    NSDictionary *marketlistdic;
    NSString *apistring;
    NSString *api_language;

}
@end

@implementation MarketViewController
@synthesize myscroller;
@synthesize normal,normal2;
@synthesize markettable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.tabBarItem setImage:[UIImage imageNamed:@"market.png"]];
        self.tabBarItem.title=@"市场";
        zhankai=NO;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.navigationItem.titleView=navcenter;
    self.navigationController.navigationBar.hidden=NO;
    AppDelegate *delegate=[[UIApplication sharedApplication]delegate];
    delegate.Orientations=NO;
    self.tabBarController.navigationItem.rightBarButtonItem=nil;

}

-(void)viewDidAppear:(BOOL)animated
{
    }

- (void)viewDidLoad {
    [super viewDidLoad];
    
    api_language=@"cn";
    apistring=[NSString stringWithFormat:@"%@?lang=%@",HTTP_marketlist,api_language];
    requestmarketlist=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:apistring]];
    requestmarketlist.tag=1;
    [requestmarketlist setDelegate:self];
    [requestmarketlist setTimeOutSeconds:60];
    [requestmarketlist setDidFinishSelector:@selector(requestFinished:)];
    [requestmarketlist setDidFailSelector:@selector(requestFailed:)];
    [requestmarketlist startAsynchronous];

    marketlist=[[NSMutableArray alloc]init];
   
    
    
    myscroller=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, mywidth,myheight-64)];
    myscroller.contentSize=CGSizeMake(mywidth, 1000);
    myscroller.backgroundColor=[UIColor groupTableViewBackgroundColor];
    myscroller.userInteractionEnabled=YES;
    myscroller.delegate=self;
    [self.view addSubview:myscroller];
    
    selectview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, mywidth, 50)];
    selectview.backgroundColor=[UIColor clearColor];
    [self.view addSubview:selectview];
    
    pickerScroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, mywidth, 50)];
    pickerScroll.backgroundColor=[UIColor groupTableViewBackgroundColor];
    [selectview addSubview:pickerScroll];
    pickerScroll.showsHorizontalScrollIndicator=NO;
    
    picturescroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, mywidth, myheight-64-49)];
    picturescroll.backgroundColor=[UIColor clearColor];
    picturescroll.contentSize=CGSizeMake(mywidth*2,myheight-64-49);
    [myscroller addSubview:picturescroll];
    
    normal=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, mywidth, myheight-64-49)];
    normal.image=[UIImage imageNamed:@"page_01.jpg"];
    normal.userInteractionEnabled=YES;
    [picturescroll addSubview:normal];
    
    
    normal2=[[UIImageView alloc]initWithFrame:CGRectMake(mywidth, 0, mywidth, myheight-64-49)];
    normal2.image=[UIImage imageNamed:@"page_02.jpg"];
    normal2.userInteractionEnabled=YES;
    [picturescroll addSubview:normal2];
    
    markettable=[[UITableView alloc]initWithFrame:CGRectMake(0, myheight-49-64, mywidth, 400) style:UITableViewStyleGrouped];
    markettable.backgroundColor=[UIColor clearColor];
    markettable.delegate=self;
    markettable.dataSource=self;
    markettable.scrollEnabled=NO;
    [myscroller addSubview:markettable];
    
    navcenter=[[UIView alloc]initWithFrame:CGRectMake(0,0,160, 44)];
    navcenter.backgroundColor=[UIColor clearColor];
    myselectlabel=[[UILabel alloc]initWithFrame:CGRectMake(40, 0, 80, 44)];
    myselectlabel.text=@"汽车";
    myselectlabel.textAlignment=YES;
    myselectlabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:16];
    myselectlabel.backgroundColor=[UIColor clearColor];
    [navcenter addSubview:myselectlabel];
    
    myactivityindicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(20,12,20, 20)];
    myactivityindicator.color=[UIColor blackColor];
    [navcenter addSubview:myactivityindicator];
    [myactivityindicator startAnimating];
    myactivityindicator.hidesWhenStopped=YES;
    
    jiantou=[[UIImageView alloc]initWithFrame:CGRectMake(110, 7, 30, 30)];
    jiantou.image=[UIImage imageNamed:@"down.png"];
    [navcenter addSubview:jiantou];
    
    navbutton =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 160, 44)];
    navbutton.backgroundColor=[UIColor clearColor];
    [navcenter addSubview:navbutton];
    [navbutton addTarget:self action:@selector(selectmore) forControlEvents:UIControlEventTouchUpInside];
    
}

//-------------------------------------------------------------------------------------------------------------------------------------------------

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request.tag==1) {
        response=[request responseString];
        
        [self jsonStringToObject];
        marketlistdic=object;
        NSLog(@"%@",marketlistdic);
       
        for (int i=0; i<[[marketlistdic objectForKey:@"data"] count]; i++) {
            [marketlist addObject:[[[marketlistdic objectForKey:@"data"] objectAtIndex:i] objectForKey:@"title"]];
        }
        pickerScroll.contentSize=CGSizeMake(80*[marketlist count],50);
        [self initpickerscroll];
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

-(void)initpickerscroll
{
    for (int i=1; i<=[marketlist count]; i++) {
        int j=i-1;
        UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(j*80,0,80,50)];
        button.tag=i;
        button.backgroundColor=[UIColor clearColor];
        [pickerScroll addSubview:button];
        [self initpickerscrollbackground:button];
    }
}


-(void)initpickerscrollbackground:(UIButton *)button
{
    NSString *mytitle=[NSString stringWithFormat:@"%@",[marketlist objectAtIndex:((int)button.tag-1)]];
    [button setTitle:mytitle forState:UIControlStateNormal];
    button.titleLabel.font=[UIFont systemFontOfSize:15];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    [UIView animateWithDuration:0.2 animations:^{
        selectview.frame=CGRectMake(0, 0, 320, 64);
    }];
    zhankai=NO;
    jiantou.image=[UIImage imageNamed:@"down.png"];

}

-(void)click:(UIButton *)sender
{
    UIButton *bt=sender;
    switch (sender.tag) {
        case 1:
            bt.showsTouchWhenHighlighted=YES;
            break;
            
        case 2:
            bt.showsTouchWhenHighlighted=YES;

            break;
            
        case 3:
            bt.showsTouchWhenHighlighted=YES;

            break;
            
        case 4:
            bt.showsTouchWhenHighlighted=YES;

            break;
            
        case 5:
            bt.showsTouchWhenHighlighted=YES;

            break;
            
        case 6:
            bt.showsTouchWhenHighlighted=YES;

            break;
            
        case 7:
            bt.showsTouchWhenHighlighted=YES;

            break;
            
        case 8:
            bt.showsTouchWhenHighlighted=YES;
            
        case 9:
            bt.showsTouchWhenHighlighted=YES;

            break;
            
        default:
            break;
    }
    
    NSLog(@"%@",[marketlist objectAtIndex:sender.tag-1]);
    myselectlabel.text=[marketlist objectAtIndex:sender.tag-1];
    [UIView animateWithDuration:0.2 animations:^{
        selectview.frame=CGRectMake(0, 0, 320, 64);
    }];
    zhankai=NO;
    jiantou.image=[UIImage imageNamed:@"down.png"];

}

-(void)selectmore
{
    if (zhankai==NO) {
        [UIView animateWithDuration:0.2 animations:^{
            selectview.frame=CGRectMake(0, 64, 320, 64);
        }];
        zhankai=YES;
        jiantou.image=[UIImage imageNamed:@"up"];

        
    }else if(zhankai==YES)
    {
        [UIView animateWithDuration:0.2 animations:^{
            selectview.frame=CGRectMake(0, 0, 320, 64);
        }];
        zhankai=NO;
        jiantou.image=[UIImage imageNamed:@"down.png"];

    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 3;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 2;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
        if (section==0)
        {
            return @"系统";
        }else if (section==1)
        {
            return @"应用";
        }else
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
    
    static NSString *cellIdentifier = @"Cell";
    UINib *nib = [UINib nibWithNibName:@"Cell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (indexPath.section==0&&indexPath.row==0) {
        cell.mylabel.text=@"TINA AM";
       
    }
    if (indexPath.section==0&&indexPath.row==1) {
        cell.mylabel.text=@"TINA EP";
        
    }
    if (indexPath.section==0&&indexPath.row==2) {
        cell.mylabel.text=@"TINA GP";
        
    }
    if (indexPath.section==1&&indexPath.row==0) {
        cell.mylabel.text=@"后盖";
        
        
    }
    if (indexPath.section==1&&indexPath.row==1) {
        cell.mylabel.text=@"上盖";
        
    }
    if (indexPath.section==1&&indexPath.row==2) {
        cell.mylabel.text=@"键盘";
        
    }
    
    cell.backgroundColor=[UIColor whiteColor];
    cell.mylabel.font=[UIFont systemFontOfSize:15];
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
    if (indexPath.section==0&&indexPath.row==0) {
        NSLog(@"1");
        ProductsDetailViewController *productsdetailvc=[[ProductsDetailViewController alloc]initWithNibName:@"ProductsDetailViewController" bundle:nil];
        [self.navigationController pushViewController:productsdetailvc animated:YES];

    }
    if (indexPath.section==0&&indexPath.row==1) {
        NSLog(@"2");
        ProductsDetailViewController *productsdetailvc=[[ProductsDetailViewController alloc]initWithNibName:@"ProductsDetailViewController" bundle:nil];
        [self.navigationController pushViewController:productsdetailvc animated:YES];

    }
    if (indexPath.section==0&&indexPath.row==2) {
        NSLog(@"3");
        ProductsDetailViewController *productsdetailvc=[[ProductsDetailViewController alloc]initWithNibName:@"ProductsDetailViewController" bundle:nil];
        [self.navigationController pushViewController:productsdetailvc animated:YES];

    }
    if (indexPath.section==1&&indexPath.row==0) {
        NSLog(@"4");
        MovieorPictureViewController *mpvc=[[MovieorPictureViewController alloc]initWithNibName:@"MovieorPictureViewController" bundle:nil];
        [self.navigationController pushViewController:mpvc animated:YES];
    }
    if (indexPath.section==1&&indexPath.row==1) {
        NSLog(@"5");
        MovieorPictureViewController *mpvc=[[MovieorPictureViewController alloc]initWithNibName:@"MovieorPictureViewController" bundle:nil];
        [self.navigationController pushViewController:mpvc animated:YES];

        
    }
    if (indexPath.section==1&&indexPath.row==2) {
        NSLog(@"6");
        MovieorPictureViewController *mpvc=[[MovieorPictureViewController alloc]initWithNibName:@"MovieorPictureViewController" bundle:nil];
        [self.navigationController pushViewController:mpvc animated:YES];

        
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
