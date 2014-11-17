//
//  MovieorPictureViewController.h
//  MssForPhone
//
//  Created by it-mobile on 14/11/7.
//  Copyright (c) 2014年 Paul. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieorPictureViewController : UIViewController<UIScrollViewDelegate>
@property(nonatomic,retain)IBOutlet UIView *pdfview;
@property(nonatomic,retain)IBOutlet UIView *videoview;

@property(nonatomic,retain) UIScrollView *myscroller;
@property(nonatomic,retain) UIScrollView *subscroller;
@property(nonatomic,retain)UIActivityIndicatorView *myactivityindicator;

@property(nonatomic,retain)IBOutlet UIPageControl *pagecontrol;
@property(nonatomic,retain)NSString *idstring;
@property(nonatomic,retain)NSString *api_language;

@end
