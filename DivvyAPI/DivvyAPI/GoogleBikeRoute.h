//
//  GoogleBikeRoute.h
//  DivvyApp
//
//  Created by Adam Gluck on 7/7/13.
//  Copyright (c) 2013 BGL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@protocol GoogleBikeRouteDelegate <NSObject>

@optional
-(void) routeWithPolyline: (GMSPolyline *) polyline;
-(void) directionsFromServer: (NSDictionary *) directionsDictionary;

@end

@interface GoogleBikeRoute : NSObject

typedef enum transportationType {
    kTransportationTypeBiking,
    kTransportationTypeWalking,
    kTransportationTypePublicTransit,
} GoogleRouteTransportationType;

// takes an array of positionStrings formatted like below
// NSString *positionStringExample = [[NSString alloc] initWithFormat:@"%f,%f", coordinate.latitude,coordinate.longitude];
@property (strong, nonatomic) NSArray * waypoints;

// set to true if the app is using GPS
@property (assign, nonatomic) BOOL appDoesUseGPS;
@property (strong, nonatomic) id <GoogleBikeRouteDelegate> delegate;

// press once the waypoint are set
// calls both delegate methods
-(void) goWithTransportationType: (GoogleRouteTransportationType) type;

-(GoogleBikeRoute *) initWithWaypoints: (NSArray *) waypoints sensorStatus: (BOOL) sensorOn andDelegate: (id) delegate;

@end
