//
//  ReferenceViewController.m
//  MssForPhone
//
//  Created by it-mobile on 14/12/4.
//  Copyright (c) 2014年 Paul. All rights reserved.
//

#import "ReferenceViewController.h"
#import "AppDelegate.h"
#import "API.h"
#import "ASIHTTPRequest.h"
#import "Cell.h"
#import "ShowMovieViewController.h"

#define mywidth self.view.bounds.size.width
#define myheight self.view.bounds.size.height

@interface ReferenceViewController ()
{
    NSString *Reference;
    UILabel *mylabel;//标题
    UIActivityIndicatorView *activityindicator;
    UIView *navcenter;
    
    NSString *api_language;
    NSString *apistring;
    ASIHTTPRequest *requestreference;
    NSString *response;
    id object;
    NSDictionary *referencedic;
    
}
@end

@implementation ReferenceViewController
@synthesize referencetable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initlabel];
        [self.tabBarItem setImage:[UIImage imageNamed:@"reference.png"]];
        self.tabBarItem.title=Reference;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeitem) name:@"ChangeBaritemNotificaton" object:nil];
        
    }
    return self;
}

-(void)changeitem
{
    [self initlabel];
    self.tabBarItem.title=Reference;
}

-(void)initlabel
{
    NSBundle *bundle=[NSBundle mainBundle];
    NSURL *plistURL=[bundle URLForResource:@"Localization" withExtension:@"plist"];
    NSDictionary *root=[[NSDictionary alloc]initWithContentsOfURL:plistURL];
    NSDictionary *dic=[root objectForKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"lan"]];
    Reference=[dic objectForKey:@"reference"];
    mylabel.text=Reference;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self initlabel];
    self.tabBarController.title=Reference;
    self.tabBarController.navigationItem.titleView=navcenter;
    self.navigationController.navigationBar.hidden=NO;
    self.tabBarController.navigationItem.rightBarButtonItem=nil;
    
    AppDelegate *delegate=[[UIApplication sharedApplication]delegate];
    delegate.Orientations=NO;
    
    api_language=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lan"]];
    apistring=[NSString stringWithFormat:@"%@?lang=%@",HTTP_preferencelist,api_language];
    requestreference=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:apistring]];
    requestreference.tag=1;
    [requestreference setDelegate:self];
    [requestreference setTimeOutSeconds:60];
    [requestreference setDidFinishSelector:@selector(requestFinished:)];
    [requestreference setDidFailSelector:@selector(requestFailed:)];
    [requestreference startAsynchronous];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    navcenter=[[UIView alloc]initWithFrame:CGRectMake(0,0,200, 44)];
    navcenter.backgroundColor=[UIColor clearColor];
    mylabel=[[UILabel alloc]initWithFrame:CGRectMake(30, 0, 140, 44)];
    mylabel.text=Reference;
    mylabel.textAlignment=YES;
    mylabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:16];
    mylabel.backgroundColor=[UIColor clearColor];
    [navcenter addSubview:mylabel];
    
    activityindicator=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(30,12,20, 20)];
    activityindicator.color=[UIColor blackColor];
    [navcenter addSubview:activityindicator];
    [activityindicator startAnimating];
    activityindicator.hidesWhenStopped=YES;
    
    referencetable=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, mywidth, myheight-64-49)];
    referencetable.delegate=self;
    referencetable.dataSource=self;
    [self.view addSubview:referencetable];
    
    referencetable.hidden=YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request.tag==1) {
        response=[request responseString];
        
        [self jsonStringToObject];
        referencedic=object;
        NSLog(@"%@",referencedic);
        referencetable.hidden=NO;
        [referencetable reloadData];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UINib *nib = [UINib nibWithNibName:@"Cell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.mylabel.text=[[[referencedic objectForKey:@"data"]objectAtIndex:indexPath.row]objectForKey:@"preference"];
    cell.mylabel.font=[UIFont systemFontOfSize:15];
    cell.backgroundColor=[UIColor whiteColor];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShowMovieViewController *showmovievc=[[ShowMovieViewController alloc]initWithNibName:@"ShowMovieViewController" bundle:nil];
    showmovievc.videourl=[[[referencedic objectForKey:@"data"]objectAtIndex:indexPath.row]objectForKey:@"video"];
    showmovievc.navtitle=[[[referencedic objectForKey:@"data"]objectAtIndex:indexPath.row]objectForKey:@"preference"];
    [self.navigationController pushViewController:showmovievc animated:YES];
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
