//
//  BGLStationObject.h
//  DivvyApp
//
//  Created by Adam Gluck on 7/7/13.
//  Copyright (c) 2013 BGL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BGLStationObject : NSObject

@property (assign, nonatomic) CLLocationDegrees latitude;
@property (assign, nonatomic) CLLocationDegrees longitude;

@property (assign, nonatomic) NSInteger availableBikes;
@property (assign, nonatomic) NSInteger availableDocks;
@property (assign, nonatomic) NSInteger totalDocks;

@property (assign, nonatomic) NSInteger stationID;
@property (strong, nonatomic) NSString * stationName;

@property (strong, nonatomic) NSString * location;

@property (assign, nonatomic) NSInteger statusKey; // 1 indicates "In Service"
@property (strong, nonatomic) NSString * statusValue; // "In Service" indicates "In Service"

-(BGLStationObject *) initWithStationDictionary: (NSDictionary *) stationData;



@end
