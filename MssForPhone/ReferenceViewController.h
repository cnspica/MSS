//
//  ReferenceViewController.h
//  MssForPhone
//
//  Created by it-mobile on 14/12/4.
//  Copyright (c) 2014年 Paul. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReferenceViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,retain)IBOutlet UITableView *referencetable;
@end
