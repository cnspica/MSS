//
//  IntroductionViewController.h
//  MssForPhone
//
//  Created by it-mobile on 14/11/1.
//  Copyright (c) 2014年 Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CustomAnnotation.h"

@interface IntroductionViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate,UIAlertViewDelegate,UIApplicationDelegate>
@property(nonatomic,retain)IBOutlet UIScrollView *myscroller;
@property(nonatomic,retain) UIImageView *myimageview1;

@property(nonatomic,retain) MKMapView *myMapview;
@property (nonatomic, strong) CLLocationManager *myLocationManager;

@end
