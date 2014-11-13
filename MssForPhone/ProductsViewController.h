//
//  ProductsViewController.h
//  MssForPhone
//
//  Created by it-mobile on 14/11/1.
//  Copyright (c) 2014年 Paul. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductsViewController : UIViewController<UISearchBarDelegate,UIScrollViewDelegate>
@property(nonatomic,retain)IBOutlet UIScrollView *productscroller;
@property(nonatomic,retain)IBOutlet UISearchBar *mysearchbar;
@property(nonatomic,retain)UIView *alphaview;
@end
