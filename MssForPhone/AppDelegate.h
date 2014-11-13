//
//  AppDelegate.h
//  MssForPhone
//
//  Created by Paul on 14-11-1.
//  Copyright (c) 2014年 Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIDownloadCache.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,retain)UITabBarController *tarbarcontroller;
@property(nonatomic,assign)BOOL Orientations;
@property (nonatomic,retain) ASIDownloadCache *myCache;

@end
