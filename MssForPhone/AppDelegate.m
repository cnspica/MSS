//
//  AppDelegate.m
//  MssForPhone
//
//  Created by Paul on 14-11-1.
//  Copyright (c) 2014年 Paul. All rights reserved.
//

#import "AppDelegate.h"
#import "IntroductionViewController.h"
#import "ProductsViewController.h"
#import "MarketViewController.h"
#import "DataViewController.h"
#import "SDWebImageManager.h"
#import "ASIFormDataRequest.h"
#import "AlterViewController.h"
#import "ReferenceViewController.h"

@implementation AppDelegate
{
    NSDictionary *dic;
}
@synthesize tarbarcontroller;
@synthesize Orientations;
@synthesize myCache;
@synthesize selectlanguage;
@synthesize serviceuuid;
@synthesize getuuid;
@synthesize state;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    sleep(1);
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lan"]);
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"lan"]==nil) {
        selectlanguage=@"cn";
        [[NSUserDefaults standardUserDefaults]setObject:selectlanguage forKey:@"lan"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    IntroductionViewController *introductionvc=[[IntroductionViewController alloc]initWithNibName:@"IntroductionViewController" bundle:nil];
    ProductsViewController *productsvc=[[ProductsViewController alloc]initWithNibName:@"ProductsViewController" bundle:nil];
     MarketViewController *marketvc=[[MarketViewController alloc]initWithNibName:@"MarketViewController" bundle:nil];
    DataViewController *datavc=[[DataViewController alloc]initWithNibName:@"DataViewController" bundle:nil];
    ReferenceViewController *referencevc=[[ReferenceViewController alloc]initWithNibName:@"ReferenceViewController" bundle:nil];

    
    
    tarbarcontroller=[[UITabBarController alloc]init];
    tarbarcontroller.viewControllers=@[introductionvc,productsvc,marketvc,datavc,referencevc];
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:tarbarcontroller];
    
    ASIDownloadCache *cache = [[ASIDownloadCache alloc] init];
    self.myCache = cache;
    
    //设置缓存路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSLog(@"%@",path);
    [self.myCache setStoragePath:[path stringByAppendingPathComponent:@"Caches"]];
    [self.myCache setDefaultCachePolicy:ASIOnlyLoadIfNotCachedCachePolicy];
    
    //获取本机uuid
    UIDevice *device = [[UIDevice alloc]init];
    NSString *tmpudid =[NSString stringWithFormat:@"%@",device.identifierForVendor.UUIDString];
    serviceuuid = [tmpudid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSLog(@"%@",serviceuuid);
    
    
    
    //网络请求
    ASIFormDataRequest *requestuid=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://58.210.127.156/contact/api/checkUser"]];
    [requestuid setPostValue:serviceuuid forKey:@"uid"];
    [requestuid startSynchronous];
    NSData *data=[requestuid responseData];
    NSLog(@"%@",data);
    if (data==NULL) {
        self.window.rootViewController=nav;
        self.window.backgroundColor = [UIColor whiteColor];
        UIAlertView *alter=[[UIAlertView alloc]initWithTitle:@"提示" message:@"您的网络出问题了" delegate:self cancelButtonTitle:@"重试" otherButtonTitles: nil];
        [alter show];
        
    }else
    {
        dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"%@",dic);
        
        if ([[dic objectForKey:@"status"]intValue]==1) {
            NSLog(@"success");
            self.window.rootViewController=nav;
            self.window.backgroundColor = [UIColor whiteColor];
            
        }else
        {
            NSLog(@"failed");
            AlterViewController *altervc=[[AlterViewController alloc]initWithNibName:@"AlterViewController" bundle:nil];
            self.window.rootViewController=altervc;
            
        }
        
    }
    
    [self.window makeKeyAndVisible];
    return YES;

}


- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if(Orientations)
    {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskPortrait;

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
//-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
//{
//    SDWebImageManager *mgr=[SDWebImageManager sharedManager];
//    [mgr cancelAll];
//    [mgr.imageCache clearMemory];
//}

@end
