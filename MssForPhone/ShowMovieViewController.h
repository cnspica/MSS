//
//  ShowMovieViewController.h
//  MssForPhone
//
//  Created by it-mobile on 14/11/4.
//  Copyright (c) 2014年 Paul. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowMovieViewController : UIViewController
@property(nonatomic,retain)NSString *videourl;
@property(nonatomic,retain)NSString *navtitle;
@property(nonatomic,retain)IBOutlet UILabel *cachelabel;
@property(nonatomic,retain)IBOutlet UIActivityIndicatorView *myactivityindicator;
@property(nonatomic,retain)IBOutlet UIProgressView *progressview;

@end
