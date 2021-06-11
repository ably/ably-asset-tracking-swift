#import "ViewController.h"
#import <AblyAssetTrackingSubscriber-Swift.h>

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
                        startOnSuccess:^() {
                            NSLog(@"Subscriber start SUCCESS");
                        } onError:^(ErrorInformation * _Nonnull error) {
                            NSLog(@"Subscriber start ERROR: %@", error.message);
    }];
    
    NSLog(@"Subscriber created: %s", self.subscriber == NULL ? "FALSE" : "TRUE");
}

- (void) subscriberSendChangeRequestUsageExample {
    Resolution *resolution = [[Resolution alloc] initWithAccuracy:AccuracyBalanced
                                                  desiredInterval:1000
                                              minimumDisplacement:1000];
    
    [self.subscriber resolutionPreferenceWithResolution:resolution
                                              onSuccess:^() {
                                                NSLog(@"Send resolution preference SUCCESS");
                                              } onError:^(ErrorInformation * _Nonnull error) {
                                                NSLog(@"Send resolution preference ERROR: %@", error.message);
    }];
}

- (void) subscriberStopUsageExample {
    [self.subscriber stopOnSuccess:^() {
        NSLog(@"Subscriber stop SUCCESS");
    } onError:^(ErrorInformation * _Nonnull error) {
        NSLog(@"Subscriber stop ERROR: %@", error.message);
    }];
}

@end
