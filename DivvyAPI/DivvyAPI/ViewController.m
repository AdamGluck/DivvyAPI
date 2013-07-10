//
//  ViewController.m
//  DivvyApp
//
//  Created by Adam Gluck on 7/2/13.
//  Given freely to be used on any project, commercial or, ideally, civic.
//

#import "ViewController.h"
#import "BGLDivvyDataAccess.h"
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface ViewController () <BGLDivvyDataAccessDelegate>{
    int count;
}

@property (strong, nonatomic) BGLDivvyDataAccess * dataAccess;
@property (strong, nonatomic) IBOutlet UITextField *nearestLocationText;
@property (strong, nonatomic) IBOutlet UIView *mapViewContainer;

@end

@implementation ViewController {
    GMSMapView *mapView_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.dataAccess = [[BGLDivvyDataAccess alloc] init];
    
    self.dataAccess.delegate = self;
    // for testing
    // "latitude":41.8739580629,"longitude":-87.6277394859 should be the station on State St & Harrison St

    [self loadMap];
    


    [self.dataAccess fillStationDataASynchronously];

}

- (void)loadMap
{
    NSLog(@"Loading map view");
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:41.8739580629 longitude:-87.6277394859 zoom:10]; // Chicago (zoomed out)
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, 200, 200) camera:camera];
    mapView_.myLocationEnabled = YES;
    [self.mapViewContainer addSubview:mapView_];
}

- (void)addMarkerForStation:(BGLStationObject *)station
{
    GMSMarker *marker = [[GMSMarker alloc] init];
    CLLocationDegrees latitude = station.latitude;
    CLLocationDegrees longitude = station.longitude;
    marker.position = CLLocationCoordinate2DMake(latitude, longitude);
    marker.title = station.stationName;
    marker.map = mapView_;
}

-(void) asynchronousFillRequestComplete: (NSArray *) data{
    NSLog(@"this means that your fill request is complete");
}

-(void) requestFailedWithError:(NSError *)error{
    NSLog(@"ERROR!!!");
}

-(void) nearestStationToDeviceFoundWithStation:(BGLStationObject *)station{
    self.nearestLocationText.text = station.stationName;
    [self addMarkerForStation:station];
}

-(void) deviceLocationFoundAtLocation: (CLLocation *) location{
    //NSLog(@"device location %@", location);
}

- (IBAction)nearestLocationButtonPressed:(id)sender {
    [self.dataAccess grabNearestStationToDeviceWithOption:kNearestStationAny];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
