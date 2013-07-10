//
//  BGLDataAccess.m
//  DivvyApp
//
//  Created by Adam Gluck on 7/2/13.
//  Given freely to be used on any project, commercial or, ideally, civic.
//

#import "BGLDivvyDataAccess.h"

@interface BGLDivvyDataAccess() <CLLocationManagerDelegate>

@property (strong, nonatomic) NSTimer * refreshTimer;
@property (strong, nonatomic) CLLocationManager * locationManager;
@property (assign, nonatomic) int selectedOption;

@end

@implementation BGLDivvyDataAccess

@synthesize stationData = _stationData;


#pragma mark - easy request functions

- (id) myGetRequest: (NSURL *) url{
    
    NSArray *json = [[NSArray alloc] init];
    
    NSError * dataGrabbingError;
    
    NSData* data = [NSData dataWithContentsOfURL:
                    url options: NSDataReadingUncached error:&dataGrabbingError];

    if (dataGrabbingError){
        [self performSelector:@selector(errorGrabbingData:) onThread:[NSThread mainThread] withObject:dataGrabbingError waitUntilDone:NO];
        return @{};
    }
    
    NSError *error;
        
    if (data)
        json = [NSJSONSerialization
                JSONObjectWithData:data
                options:kNilOptions
                error:&error];
        
    
    return json;
}

#pragma mark - getters

-(NSDictionary *) stationData{
    
    if (!_stationData){
        _stationData = [[NSDictionary alloc] init];
    }
    
    return _stationData;
}

#pragma mark - setters

-(void) setAutoRefresh: (BOOL) theBool{
    
    
    if (self.autoRefresh != theBool){
        
        _autoRefresh = theBool;
        
        if (theBool){
            self.refreshTimer = [[NSTimer alloc] init];
            self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
            [self fillStationDataASynchronously];
        } else {
            [self.refreshTimer invalidate];
            self.refreshTimer = nil;
        }
        
    }
    
    
}


#pragma mark - fill data methods

-(NSArray *) downloadedDataSetToStationList: (NSDictionary *) divvyDataDictionary{
    
    NSMutableArray * localStationList = [[NSMutableArray alloc] init];
    
    for (NSDictionary * stationDictionary in divvyDataDictionary[@"stationBeanList"]){
        BGLStationObject * station = [[BGLStationObject alloc] initWithStationDictionary:stationDictionary];
        [localStationList addObject:station];
    }
    
    return [localStationList copy];
}

-(void) fillStationDataSynchronously{
    NSString * requestString = [[NSString alloc] initWithFormat:@"https://divvybikes.com/stations/json"];
    NSURL * url = [[NSURL alloc] initWithString:requestString];
    self.stationData = [self myGetRequest:url];
    self.stationList = [self downloadedDataSetToStationList:self.stationData];
}

-(void) fillStationDataASynchronously{
    __block NSDictionary * blockStationData;
    __block NSArray * blockStationList = [[NSArray alloc] init];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("Grab Divvy Data", NULL);
    dispatch_async(downloadQueue, ^{
        
        NSURL * url = [[NSURL alloc] initWithString:@"http://divvybikes.com/stations/json"];
        blockStationData = [self myGetRequest:url];
        
        if ([[blockStationData allKeys] count] != 0){
            
            blockStationList = [self downloadedDataSetToStationList:blockStationData];
            
        } else {
            blockStationData = @{@"error": @"use error delegate method for more information"};
            blockStationList = @[@"Error: Use error delegate method for more information"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.stationData = blockStationData;
            self.stationList = blockStationList;
            
            if ([[blockStationData allKeys] count] != 0 && [self.delegate respondsToSelector:@selector(asynchronousFillRequestComplete:)]){
                [self.delegate asynchronousFillRequestComplete: self.stationList];
            }
            
        });
    });
}

#pragma mark - Timer Function

-(void) refresh{
    [self fillStationDataASynchronously];
}

#pragma mark - error selector

-(void) errorGrabbingData: (NSError *) error{
    if ([self.delegate respondsToSelector:@selector(requestFailedWithError:)])
        [self.delegate requestFailedWithError:error];
}

#pragma mark - location grabbing items


-(BGLStationObject *) grabNearestStationTo:(CLLocation *)location withOption: (BGLDivvyNearestStationOptions) option{
    
    BGLStationObject * nearestStation;
    CLLocationDistance shortestDistance = 0;
    
    for (BGLStationObject * station in self.stationList){
        
        CLLocation * stationLocation = [[CLLocation alloc] initWithLatitude: station.latitude longitude:station.longitude];
        CLLocationDistance distance = [location distanceFromLocation:stationLocation];
        
        bool optionBool = YES;
        
        if (option == kNearestStationWithBike){
            optionBool = station.availableBikes > 0;
        } else if (option == kNearestStationOpen){
            optionBool = station.availableDocks > 0;
        }
        
        if (((distance < shortestDistance) && optionBool) || !shortestDistance){
            shortestDistance = distance;
            nearestStation = station;
        } 
    }
    
    return nearestStation;
}

-(void) grabNearestStationToDeviceWithOption:(BGLDivvyNearestStationOptions)option{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    self.selectedOption = option;
    [self.locationManager startUpdatingLocation];
    
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    if ([self.delegate respondsToSelector:@selector(nearestStationToDeviceFoundWithStation:fromDeviceLocation:)])
        [self.delegate nearestStationToDeviceFoundWithStation:[self grabNearestStationTo:manager.location withOption:self.selectedOption] fromDeviceLocation:manager.location];
    
    [manager stopUpdatingLocation];
    
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(deviceLocationNotFoundWithError:)])
        [self.delegate deviceLocationNotFoundWithError:error];
    
    if (error.code == kCLErrorDenied)
        [manager stopUpdatingLocation];
    
}


@end


/*
 *** This is testing code that I am saving because it is a pain in the ass to type out ***
 for (BGLStationObject * station in self.stationList){
 NSLog(@"station.availableBikes == %i, station.availableDocks = %i, station.stationID = %i, station.latitude == %f, station.longitude == %f, station.location == %@, station.statusKey == %i, station.statusValue = %@, station.totalDocks = %i, station.stationName == %@", station.availableBikes, station.availableDocks, station.stationID, station.latitude, station.longitude, station.location, station.statusKey, station.statusValue, station.totalDocks, station.stationName);
 }
 */
