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
#import "UIImageView+WebCache.h"

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
    ASIHTTPRequest *requestmarketinfo;
    ASIHTTPRequest *requestmarketinfo_re;


    NSString *response;
    id object;
    NSDictionary *marketlistdic;
    NSString *apistring;
    NSString *api_language;
    NSDictionary *marketinfodic;
    NSInteger marketid;
    NSInteger picturenumber;
    NSInteger applicationumber;
    NSInteger productsnumber;
    
    BOOL marketlist_finished;
    BOOL marketinfo_finished;
    BOOL marketinfo_re_finished;

    NSString *market;
    NSString *system;
    NSString *application;
}
@end

@implementation MarketViewController
@synthesize myscroller;
@synthesize markettable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        [self initlabel];
        [self.tabBarItem setImage:[UIImage imageNamed:@"market.png"]];
        self.tabBarItem.title=market;
        zhankai=NO;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeitem) name:@"ChangeBaritemNotificaton" object:nil];

    }
    return self;
}

-(void)changeitem
{
    [self initlabel];
    self.tabBarItem.title=market;
}

-(void)initlabel
{
    NSBundle *bundle=[NSBundle mainBundle];
    NSURL *plistURL=[bundle URLForResource:@"Localization" withExtension:@"plist"];
    NSDictionary *root=[[NSDictionary alloc]initWithContentsOfURL:plistURL];
//    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lan"]);
    NSDictionary *dic=[root objectForKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"lan"]];
    market=[dic objectForKey:@"market"];
    system=[dic objectForKey:@"system"];
    application=[dic objectForKey:@"application"];
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [self initlabel];
    self.tabBarItem.title=market;
    
    api_language=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lan"]];
    apistring=[NSString stringWithFormat:@"%@?lang=%@",HTTP_marketlist,api_language];
    requestmarketlist=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:apistring]];
    requestmarketlist.tag=1;
    [requestmarketlist setDelegate:self];
    [requestmarketlist setTimeOutSeconds:60];
    [requestmarketlist setDidFinishSelector:@selector(requestFinished:)];
    [requestmarketlist setDidFailSelector:@selector(requestFailed:)];
    [requestmarketlist startAsynchronous];

    self.tabBarController.title=market;
    self.tabBarController.navigationItem.titleView=navcenter;
    self.navigationController.navigationBar.hidden=NO;
    self.tabBarController.navigationItem.rightBarButtonItem=nil;
    self.tabBarController.navigationItem.leftBarButtonItem=nil;
    
    AppDelegate *delegate=[[UIApplication sharedApplication]delegate];
    delegate.Orientations=NO;
    
    [pickerScroll setContentOffset:CGPointMake(0, 0)];
    selectview.frame=CGRectMake(0, 0, mywidth, 50);
    zhankai=NO;
    jiantou.image=[UIImage imageNamed:@"down.png"];

    api_language=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lan"]];
//    NSLog(@"%@",api_language);
    apistring=[NSString stringWithFormat:@"%@?lang=%@&id=%li",HTTP_marketinfo,api_language,(long)marketid];
    requestmarketinfo=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:apistring]];
    requestmarketinfo.tag=2;
    [requestmarketinfo setDelegate:self];
    [requestmarketinfo setTimeOutSeconds:60];
    [requestmarketinfo setDidFinishSelector:@selector(requestFinished:)];
    [requestmarketinfo setDidFailSelector:@selector(requestFailed:)];
    [requestmarketinfo startAsynchronous];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    marketid=1;

    marketlist=[[NSMutableArray alloc]init];
    
    myscroller=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, mywidth, myheight-64-49)];
    myscroller.backgroundColor=[UIColor groupTableViewBackgroundColor];
    myscroller.userInteractionEnabled=YES;
    myscroller.delegate=self;
    [self.view addSubview:myscroller];

    picturescroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, mywidth, myheight-64-49)];
    picturescroll.pagingEnabled=YES;
    picturescroll.backgroundColor=[UIColor clearColor];
    [myscroller addSubview:picturescroll];
    
    markettable=[[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    markettable.backgroundColor=[UIColor clearColor];
    markettable.delegate=self;
    markettable.dataSource=self;
    markettable.scrollEnabled=NO;
    [myscroller addSubview:markettable];

    
    selectview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, mywidth, 50)];
    selectview.backgroundColor=[UIColor clearColor];
    [self.view addSubview:selectview];
    
    navcenter=[[UIView alloc]initWithFrame:CGRectMake(0,0,160, 44)];
    navcenter.backgroundColor=[UIColor clearColor];
    myselectlabel=[[UILabel alloc]initWithFrame:CGRectMake(40, 0, 80, 44)];
    myselectlabel.textAlignment=YES;
    myselectlabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:16];
    myselectlabel.backgroundColor=[UIColor clearColor];
    [navcenter addSubview:myselectlabel];
    
    
    myactivityindicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(10,12,20, 20)];
    myactivityindicator.color=[UIColor blackColor];
    [navcenter addSubview:myactivityindicator];
    [myactivityindicator startAnimating];
    myactivityindicator.hidesWhenStopped=YES;
    
    jiantou=[[UIImageView alloc]initWithFrame:CGRectMake(125, 7, 30, 30)];
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
        
        [pickerScroll removeFromSuperview];
        pickerScroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, mywidth, 50)];
        pickerScroll.backgroundColor=[UIColor groupTableViewBackgroundColor];
        pickerScroll.showsHorizontalScrollIndicator=NO;
        [selectview addSubview:pickerScroll];

        
        [marketlist removeAllObjects];
        
        for (int i=0; i<[[marketlistdic objectForKey:@"data"] count]; i++) {
            [marketlist addObject:[[[marketlistdic objectForKey:@"data"] objectAtIndex:i] objectForKey:@"market"]];
        }
        
        
        //---------------------------12.10修复顺序----------------------------
        for (int i=0; i<[marketlist count]; i++) {
            if ([[[[marketlistdic objectForKey:@"data"] objectAtIndex:i]objectForKey:@"id"]integerValue]==marketid) {
                myselectlabel.text=[[[marketlistdic objectForKey:@"data"] objectAtIndex:i]objectForKey:@"market"];
            }
        }
        
        pickerScroll.contentSize=CGSizeMake(160*[marketlist count],50);
        [self initpickerscroll];
        marketlist_finished=YES;
    }
    
    if (request.tag==2) {
        response=[request responseString];
        
        [self jsonStringToObject];
        marketinfodic=object;
//        NSLog(@"%@",marketinfodic);
        picturenumber=[[[marketinfodic objectForKey:@"data"] objectForKey:@"top_images"]
                       count];
//        NSLog(@"top picture数量＝%li张",(long)picturenumber);
        
        [picturescroll removeFromSuperview];
        picturescroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, mywidth, myheight-64-49)];
        picturescroll.pagingEnabled=YES;
        picturescroll.backgroundColor=[UIColor clearColor];
        picturescroll.contentSize=CGSizeMake(mywidth*picturenumber,myheight-64-49);
        [myscroller addSubview:picturescroll];
        
        for (int i=0; i<picturenumber; i++) {
            UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(mywidth*i, 0, mywidth, myheight-64-49)];
            [imageview sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[[[marketinfodic objectForKey:@"data"] objectForKey:@"top_images"] objectAtIndex:i] objectForKey:@"file"]]]];
//            NSLog(@"%@",[NSString stringWithFormat:@"%@",[[[[marketinfodic objectForKey:@"data"] objectForKey:@"top_images"] objectAtIndex:i] objectForKey:@"file"]]);
            [picturescroll addSubview:imageview];
        }
        
        applicationumber=[[[marketinfodic objectForKey:@"data"] objectForKey:@"application"]
                          count];
        productsnumber=[[[marketinfodic objectForKey:@"data"] objectForKey:@"products"]
                        count];
        
        myscroller.contentSize=CGSizeMake(mywidth, myheight-64-49+64*2+44*(applicationumber+productsnumber));
        
        [markettable setFrame:CGRectMake(0, myheight-49-64, mywidth, 64*2+44*(applicationumber+productsnumber))];

        [markettable reloadData];
        marketinfo_finished=YES;
    }
    if (request.tag==3) {
        response=[request responseString];
        
        [self jsonStringToObject];
        marketinfodic=object;
//        NSLog(@"%@",marketinfodic);
        picturenumber=[[[marketinfodic objectForKey:@"data"] objectForKey:@"top_images"]
                       count];
        NSLog(@"top picture数量＝%li张",(long)picturenumber);
        
        
       [picturescroll removeFromSuperview];
        picturescroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, mywidth, myheight-64-49)];
        picturescroll.pagingEnabled=YES;
        picturescroll.backgroundColor=[UIColor clearColor];
        picturescroll.contentSize=CGSizeMake(mywidth*picturenumber,myheight-64-49);
        [myscroller addSubview:picturescroll];
        
        for (int i=0; i<picturenumber; i++) {
            UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(mywidth*i, 0, mywidth, myheight-64-49)];
            [imageview sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[[[marketinfodic objectForKey:@"data"] objectForKey:@"top_images"] objectAtIndex:i] objectForKey:@"file"]]]];
//            NSLog(@"%@",[NSString stringWithFormat:@"%@",[[[[marketinfodic objectForKey:@"data"] objectForKey:@"top_images"] objectAtIndex:i] objectForKey:@"file"]]);
            [picturescroll addSubview:imageview];
        }
        
        applicationumber=[[[marketinfodic objectForKey:@"data"] objectForKey:@"application"]
                          count];
        productsnumber=[[[marketinfodic objectForKey:@"data"] objectForKey:@"products"]
                        count];
        
        myscroller.contentSize=CGSizeMake(mywidth, myheight-64-49+64*2+44*(applicationumber+productsnumber));
        
        [markettable setFrame:CGRectMake(0, myheight-49-64, mywidth, 64*2+44*(applicationumber+productsnumber))];
        
        [markettable reloadData];
        marketinfo_re_finished=YES;
    }

    if (marketlist_finished&&marketinfo_finished) {
        [myactivityindicator stopAnimating];
    }
    if (marketinfo_re_finished) {
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
        UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(j*160,0,160,50)];
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
    button.titleLabel.font=[UIFont fontWithName:@"Heiti TC" size:15];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    [UIView animateWithDuration:0.2 animations:^{
        selectview.frame=CGRectMake(0, 0, mywidth, 50);
    }];
    zhankai=NO;
    jiantou.image=[UIImage imageNamed:@"down.png"];

}

-(void)click:(UIButton *)sender
{
    UIButton *bt=sender;
    bt.showsTouchWhenHighlighted=YES;
    
    NSLog(@"%@",[marketlist objectAtIndex:sender.tag-1]);
    myselectlabel.text=[marketlist objectAtIndex:sender.tag-1];
    [UIView animateWithDuration:0.2 animations:^{
        selectview.frame=CGRectMake(0, 0, mywidth, 50);
    }];
    zhankai=NO;
    jiantou.image=[UIImage imageNamed:@"down.png"];
    marketid=[[[[marketlistdic objectForKey:@"data"] objectAtIndex:(bt.tag-1)] objectForKey:@"id"]integerValue];
    [self changemarket];
    [myactivityindicator startAnimating];

}

//再次请求并刷新列表
-(void)changemarket
{
    api_language=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lan"]];
    apistring=[NSString stringWithFormat:@"%@?lang=%@&id=%ld",HTTP_marketinfo,api_language,(long)marketid];
    requestmarketinfo_re=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:apistring]];
    requestmarketinfo_re.tag=3;
    [requestmarketinfo_re setDelegate:self];
    [requestmarketinfo_re setTimeOutSeconds:60];
    [requestmarketinfo_re setDidFinishSelector:@selector(requestFinished:)];
    [requestmarketinfo_re setDidFailSelector:@selector(requestFailed:)];
    [requestmarketinfo_re startAsynchronous];

}

-(void)selectmore
{
    if (zhankai==NO) {
        [UIView animateWithDuration:0.2 animations:^{
            selectview.frame=CGRectMake(0, 64, mywidth, 50);
        }];
        zhankai=YES;
        jiantou.image=[UIImage imageNamed:@"up"];

        
    }else if(zhankai==YES)
    {
        [UIView animateWithDuration:0.2 animations:^{
            selectview.frame=CGRectMake(0, 0, mywidth, 50);
        }];
        zhankai=NO;
        jiantou.image=[UIImage imageNamed:@"down.png"];

    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (section==0) {
        return productsnumber;
    }else if(section==1)
    {
        return applicationumber;
    }
    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 2;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
        if (section==0)
        {
            return system;
        }else if (section==1)
        {
            return application;
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
    
    for (int i=0; i<productsnumber; i++) {
        if (indexPath.section==0&&indexPath.row==i) {
            cell.mylabel.text=[[[[marketinfodic objectForKey:@"data"] objectForKey:@"products"]objectAtIndex:i] objectForKey:@"product"];
        }

    }
    for (int j=0; j<applicationumber; j++) {
        if (indexPath.section==1&&indexPath.row==j) {
             cell.mylabel.text=[[[[marketinfodic objectForKey:@"data"] objectForKey:@"application"]objectAtIndex:j]objectForKey:@"app"];
        }

    }
    
    cell.backgroundColor=[UIColor whiteColor];
    cell.mylabel.font=[UIFont fontWithName:@"Heiti TC" size:15];
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
    for (int m=0; m<productsnumber; m++) {
        if (indexPath.section==0&&indexPath.row==m) {
            ProductsDetailViewController *productdetailvc=[[ProductsDetailViewController alloc]initWithNibName:@"ProductsDetailViewController" bundle:nil];
            productdetailvc.idstring=[[[[marketinfodic objectForKey:@"data"] objectForKey:@"products"] objectAtIndex:m] objectForKey:@"id"];
            productdetailvc.navtitle=[[[[marketinfodic objectForKey:@"data"] objectForKey:@"products"] objectAtIndex:m] objectForKey:@"product"];
            productdetailvc.api_language=api_language;
            [self.navigationController pushViewController:productdetailvc animated:YES];
        }
        
    }
    for (int n=0; n<applicationumber; n++) {
        if (indexPath.section==1&&indexPath.row==n) {
            MovieorPictureViewController *mpvc=[[MovieorPictureViewController alloc]initWithNibName:@"MovieorPictureViewController" bundle:nil];
            mpvc.api_language=api_language;
            mpvc.idstring=[[[[marketinfodic objectForKey:@"data"] objectForKey:@"application"] objectAtIndex:n] objectForKey:@"id"];
            [self.navigationController pushViewController:mpvc animated:YES];
        }
        
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
