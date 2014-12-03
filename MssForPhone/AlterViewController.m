//
//  AlterViewController.m
//  MssForPhone
//
//  Created by it-mobile on 14/12/2.
//  Copyright (c) 2014年 Paul. All rights reserved.
//

#import "AlterViewController.h"
#import "ASIFormDataRequest.h"

@interface AlterViewController ()
{
    NSString *response;
}
@end

@implementation AlterViewController

@synthesize uuid;
@synthesize reasontext;
@synthesize str;
@synthesize object;
@synthesize checkin;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIDevice *device = [[UIDevice alloc]init];
    NSString *tmpudid =[NSString stringWithFormat:@"%@",device.identifierForVendor.UUIDString];
    uuid= [tmpudid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    checkin.layer.masksToBounds=YES;
    checkin.layer.cornerRadius=5;
    
}

-(IBAction)request:(id)sender
{
    str=reasontext.text;
    NSLog(@"%@",reasontext.text);
    if (![str isEqualToString:@""]) {
        ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://58.210.127.156/contact/api/setUid"]];
        [request addPostValue:uuid forKey:@"uuid"];
        [request addPostValue:reasontext.text forKey:@"reason"];
        [request setDelegate:self];
        [request setTimeOutSeconds:10];
        [request setDidFinishSelector:@selector(requestFinished:)];
        [request setDidFailSelector:@selector(requestFailed:)];
        NSLog(@"%@",request);
        [request startAsynchronous];
        
        
    }
    else
    {
        UIAlertView *alter=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请正确填写理由（必填）" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alter show];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    response=[request responseString];
    
    //    str=[response substringWithRange:NSMakeRange(10,1)];
    //
    //    NSLog(@"%@",str);
    
    [self jsonStringToObject];
    NSLog(@"%@",object);
    
    if ([[object objectForKey:@"data"]intValue]==1) {
        
        UIAlertView *alter=[[UIAlertView alloc]initWithTitle:@"提示" message:@"已提交，请等待审核" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alter show];
    }
    if ([[object objectForKey:@"data"]intValue]==-1)
    {
        UIAlertView *alter=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请不要重复提交" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alter show];
    }
    
    
}

-(id)jsonStringToObject
{
    NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    
    object = [NSJSONSerialization JSONObjectWithData:data
              
                                             options:NSJSONReadingAllowFragments
              
                                               error:&error];
    
    return object;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            reasontext.text=nil;
            break;
            
        default:
            break;
    }
}

-(IBAction)hdkeyboard:(id)sender
{
    [reasontext resignFirstResponder];
}

-(IBAction)clickbackground:(id)sender
{
    [reasontext resignFirstResponder];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField

{
    
    [self animateTextField: textField up: YES];
    
}





- (void)textFieldDidEndEditing:(UITextField *)textField

{
    
    [self animateTextField: textField up: NO];
    
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up

{
    
    const int movementDistance =120; // tweak as needed
    
    const float movementDuration = 0.3f; // tweak as needed
    
    
    
    int movement = (up ? -movementDistance : movementDistance);
    
    
    
    [UIView beginAnimations: @"anim" context: nil];
    
    [UIView setAnimationBeginsFromCurrentState: YES];
    
    [UIView setAnimationDuration: movementDuration];
    
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    
    [UIView commitAnimations];
    
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
