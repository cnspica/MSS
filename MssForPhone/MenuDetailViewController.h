//
//  MenuDetailViewController.h
//  MssForPhone
//
//  Created by it-mobile on 14/12/19.
//  Copyright (c) 2014年 Paul. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuDetailViewController : UIViewController<UIScrollViewDelegate>

@property(nonatomic,retain) UIScrollView *myscroller;
@property(nonatomic,retain) UIScrollView *subscroller;

@property(nonatomic,retain)IBOutlet UIPageControl *pagecontrol;
@property(nonatomic,retain)NSString *idstring;
@property(nonatomic,retain)UIActivityIndicatorView *myactivityindicator;
@property(nonatomic,retain)NSString *navtitle;
@property(nonatomic,retain)NSString *api_language;

@end
