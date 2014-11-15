//
//  MarketViewController.h
//  MssForPhone
//
//  Created by it-mobile on 14/11/1.
//  Copyright (c) 2014年 Paul. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MarketViewController : UIViewController<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,retain)UIScrollView *myscroller;
@property(nonatomic,retain)UITableView *markettable;

@end
