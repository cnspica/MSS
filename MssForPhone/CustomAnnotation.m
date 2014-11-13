//
//  CustomAnnotation.m
//  Map
//
//  Created by Paul on 13-10-9.
//  Copyright (c) 2013年 Paul. All rights reserved.
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation
- (id) initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates title:(NSString *)paramTitle
                  subTitle:(NSString *)paramSubTitle{
    self = [super init];
    if (self != nil){
        _coordinate = paramCoordinates;
        _title = paramTitle;
        _subtitle = paramSubTitle;
    }
    return(self); }

@end
