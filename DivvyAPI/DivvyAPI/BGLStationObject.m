//
//  BGLStationObject.m
//  DivvyApp
//
//  Created by Adam Gluck on 7/7/13.
//  Copyright (c) 2013 BGL. All rights reserved.
//

#import "BGLStationObject.h"

@implementation BGLStationObject

-(BGLStationObject *) initWithStationDictionary: (NSDictionary *) stationData{
    self = [super init];
    
    if (self){
        self.latitude = ((NSString *)stationData[@"latitude"]).doubleValue;
        self.longitude = ((NSString *)stationData[@"longitude"]).doubleValue;
        
        self.availableBikes = ((NSString *)stationData[@"availableBikes"]).integerValue;
        self.availableDocks = ((NSString *)stationData[@"availableDocks"]).integerValue;
        self.totalDocks = ((NSString *) stationData[@"totalDocks"]).integerValue;
        
        self.stationID = ((NSString *) stationData[@"id"]).integerValue;
        self.location = [stationData[@"location"] copy];
        self.stationName = [stationData[@"stationName"] copy];
        
        self.statusKey = ((NSString *) stationData[@"statusKey"]).integerValue;
        self.statusValue = [stationData[@"statusValue"] copy];
    }
    
    return self;
}
@end
