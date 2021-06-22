#import "ViewController.h"
#import <AblyAssetTrackingPublisher-Swift.h>

@interface ViewController ()
    @property id<Publisher> _Nullable publisher;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self publisherUsageExample];
    [self publisherTrackUsageExample];
    [self publisherAddUsageExample];
    [self publisherChangeRoutingProfileUsageExample];
    [self publisherRemoveUsageExample];
    [self publisherStopUsageExample];
}

- (void) publisherUsageExample {
    id<PublisherDelegate> delegate;

    ConnectionConfiguration *connectionConfiguration = [[ConnectionConfiguration alloc] initWithApiKey:@"API_KEY:API_KEY"
                                                                                              clientId:@"CLIENT_ID"];

    MapboxConfiguration *mapboxConfiguartion = [[MapboxConfiguration alloc] initWithMapboxKey:@"MAPBOX_KEY"];

    LogConfiguration *logConfiguration = [[LogConfiguration alloc] init];

    Resolution *resolution = [[Resolution alloc] initWithAccuracy:AccuracyBalanced
                                                  desiredInterval:500
                                              minimumDisplacement:500];

    DefaultResolutionPolicyFactory *resolutionPolicy = [[DefaultResolutionPolicyFactory alloc] initWithDefaultResolution:resolution];

    self.publisher = [[[[[[[[PublisherFactory publishers]
                      connection: connectionConfiguration]
                      mapboxConfiguration:mapboxConfiguartion]
                      log:logConfiguration]
                      routingProfile:RoutingProfileDriving]
                      resolutionPolicyFactory:resolutionPolicy]
                      delegate:delegate]
                      startAndReturnError:NULL];
}

- (void) publisherTrackUsageExample {
    Trackable *trackable = [[Trackable alloc]
                            initWithId:@"TRACKABLE_ID"
                            metadata:NULL
                            destination:CLLocationCoordinate2DMake(0.0, 0.0)
                            constraints:NULL];

    [self.publisher trackWithTrackable:trackable
      onSuccess:^() {
        NSLog(@"Track trackable SUCCESS");
    } onError: ^(ErrorInformation * _Nonnull error) {
        NSLog(@"Track trackable ERROR: %@", error.message);
    }];
}

- (void) publisherAddUsageExample {
    Trackable *trackable = [[Trackable alloc]
                            initWithId:@"TRACKABLE_ID"
                            metadata:NULL
                            destination:CLLocationCoordinate2DMake(0.0, 0.0)
                            constraints:NULL];
    
    [self.publisher addWithTrackable:trackable
      onSuccess:^() {
        NSLog(@"Add trackable SUCCESS");
    } onError: ^(ErrorInformation * _Nonnull error) {
        NSLog(@"Add trackable ERROR: %@", error.message);
    }];
}

- (void) publisherChangeRoutingProfileUsageExample {
    [self.publisher changeRoutingProfileWithProfile:RoutingProfileWalking
      onSuccess:^() {
        NSLog(@"Change routing profile SUCCESS");
    } onError:^(ErrorInformation * _Nonnull error) {
        NSLog(@"Change routing profile ERROR: %@", error.message);
    }];
}

- (void) publisherRemoveUsageExample {
    Trackable *trackable = [[Trackable alloc]
                            initWithId:@"TRACKABLE_ID"
                            metadata:NULL
                            destination:CLLocationCoordinate2DMake(0.0, 0.0)
                            constraints:NULL];
    
    [self.publisher removeWithTrackable:trackable
      onSuccess:^(BOOL wasPresent) {
        NSLog(@"Remove trackable SUCCESS. WasPresent: %s", wasPresent ? "TRUE" : "FALSE");
    } onError:^(ErrorInformation * _Nonnull error) {
        NSLog(@"Remove trackable ERROR: %@", error.message);
    }];
}

- (void) publisherStopUsageExample {
    // TODO: To be changeda after stop method update.
    //[self.publisher stop];
}

@end
