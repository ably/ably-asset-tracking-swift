#import "ViewController.h"
@import AblyAssetTrackingSubscriber;

@interface ViewController ()
    @property id<Subscriber> _Nullable subscriber;
@end

@implementation ViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    [self subscriberUsageExample];
    [self subscriberSendChangeRequestUsageExample];
    [self subscriberStopUsageExample];
}

- (void) subscriberUsageExample {
    id<SubscriberDelegate> delegate;
    
    ConnectionConfiguration *connectionConfiguration = [[ConnectionConfiguration alloc] initWithApiKey:@"API_KEY:API_KEY"
                                                                                              clientId:@"CLIENT_ID"];
    
    LogConfiguration *logConfiguration = [[LogConfiguration alloc] init];

    Resolution *resolution = [[Resolution alloc] initWithAccuracy:AccuracyBalanced
                                                  desiredInterval:500
                                              minimumDisplacement:500];
    
    self.subscriber = [[[[[[[SubscriberFactory subscribers]
                        trackingId:@"TRACKINGID"]
                        connection:connectionConfiguration]
                        log:logConfiguration]
                        resolution:resolution]
                        delegate:delegate]
                        startWithCompletion:^(AATResult * _Nonnull result) {
                            if (result.failure != nil) {
                                NSLog(@"Subscriber start ERROR: %@", result.failure.message);
                            } else if (result.success != nil) {
                                NSLog(@"Subscriber start SUCCESS");
                            }
    }];
    
    NSLog(@"Subscriber created: %s", self.subscriber == NULL ? "FALSE" : "TRUE");
}

- (void) subscriberSendChangeRequestUsageExample {
    Resolution *resolution = [[Resolution alloc] initWithAccuracy:AccuracyBalanced
                                                  desiredInterval:1000
                                              minimumDisplacement:1000];
    
    [self.subscriber
     resolutionPreferenceWithResolution:resolution
     completion:^(AATResult * _Nonnull result) {
        if (result.failure != nil) {
            NSLog(@"Send resolution preference ERROR: %@", result.failure.message);
        } else if (result.success != nil) {
            NSLog(@"Send resolution preference SUCCESS");
        }
    }];
}

- (void) subscriberStopUsageExample {
    [self.subscriber stopWithCompletion:^(AATResult * _Nonnull result) {
        if (result.failure != nil) {
            NSLog(@"Send resolution preference ERROR: %@", result.failure.message);
        } else if (result.success != nil) {
            NSLog(@"Subscriber stop SUCCESS");
        }
    }];
}

@end
