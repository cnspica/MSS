//
//  AlterViewController.h
//  MssForPhone
//
//  Created by it-mobile on 14/12/2.
//  Copyright (c) 2014年 Paul. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlterViewController : UIViewController<UITextFieldDelegate>
@property(nonatomic,retain)NSString *uuid;
@property(nonatomic,retain)IBOutlet UITextField *reasontext;
@property(nonatomic,retain)NSString *str;
@property(nonatomic,retain)id object;
@property(nonatomic,retain)IBOutlet UIButton *checkin;


-(IBAction)request:(id)sender;
-(IBAction)hdkeyboard:(id)sender;
-(IBAction)clickbackground:(id)sender;
-(id)jsonStringToObject;

@end
