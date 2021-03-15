#import "ViewController.h"
#import <AblyAssetTracking-Swift.h>

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
                        startAndReturnError:NULL];
    
    NSLog(@"Subscriber created: %s", self.subscriber == NULL ? "FALSE" : "TRUE");
}

- (void) subscriberSendChangeRequestUsageExample {
    Resolution *resolution = [[Resolution alloc] initWithAccuracy:AccuracyBalanced
                                                  desiredInterval:1000
                                              minimumDisplacement:1000];
    
    [self.subscriber sendChangeRequestWithResolution:resolution
      onSuccess:^() {
        NSLog(@"Send change request SUCCESS");
    } onError:^(ErrorInformation * _Nonnull error) {
        NSLog(@"Send change request ERROR: %@", error.message);
    }];
}

- (void) subscriberStopUsageExample {
    // TODO: To be changeda after stop method update.
    [self.subscriber stop];
}

@end
