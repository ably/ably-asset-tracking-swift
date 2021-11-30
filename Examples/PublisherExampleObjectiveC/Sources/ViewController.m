#import "ViewController.h"
@import AblyAssetTrackingPublisher;

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
                            completion:^(ATResult * _Nonnull result) {
        if(result.failure != nil) {
            NSLog(@"Track trackable ERROR: %@", result.failure.message);
        } else if (result.success != nil) {
            NSLog(@"Track trackable SUCCESS");
        }
    }];
}

- (void) publisherAddUsageExample {
    Trackable *trackable = [[Trackable alloc]
                            initWithId:@"TRACKABLE_ID"
                            metadata:NULL
                            destination:CLLocationCoordinate2DMake(0.0, 0.0)
                            constraints:NULL];
    
    [self.publisher addWithTrackable:trackable
                          completion:^(ATResult * _Nonnull result) {
        if (result.failure != nil) {
            NSLog(@"Add trackable ERROR: %@", result.failure.message);
        } else if (result.success != nil) {
            NSLog(@"Add trackable SUCCESS");
        }
    }];
}

- (void) publisherChangeRoutingProfileUsageExample {
    [self.publisher changeRoutingProfileWithProfile:RoutingProfileWalking
                                         completion:^(ATResult * _Nonnull result) {
        if (result.failure != nil) {
            NSLog(@"Change routing profile ERROR: %@", result.failure.message);
        } else if (result.success != nil) {
            NSLog(@"Change routing profile SUCCESS");
        }
    }];
}

- (void) publisherRemoveUsageExample {
    Trackable *trackable = [[Trackable alloc]
                            initWithId:@"TRACKABLE_ID"
                            metadata:NULL
                            destination:CLLocationCoordinate2DMake(0.0, 0.0)
                            constraints:NULL];
    
    [self.publisher removeWithTrackable:trackable
                             completion:^(ATResult * _Nonnull result) {
        if (result.failure != nil) {
            NSLog(@"Remove trackable ERROR: %@", result.failure.message);
        } else if (result.success != nil) {
            NSLog(@"Remove trackable SUCCESS. WasPresent: %s", result.success ? "TRUE" : "FALSE");
        }
    }];
}

- (void) publisherStopUsageExample {
    // TODO: To be changeda after stop method update.
    //[self.publisher stop];
}

@end
