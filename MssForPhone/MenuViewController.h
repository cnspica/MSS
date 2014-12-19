//
//  MenuViewController.h
//  MssForPhone
//
//  Created by it-mobile on 14/12/19.
//  Copyright (c) 2014年 Paul. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController<UISearchBarDelegate,UIScrollViewDelegate>

@property(nonatomic,retain)IBOutlet UIScrollView *productscroller;
@property(nonatomic,retain)IBOutlet UISearchBar *mysearchbar;
@property(nonatomic,retain)UIView *alphaview;

@end
