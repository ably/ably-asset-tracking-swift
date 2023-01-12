import XCTest
@testable import AblyAssetTrackingPublisher
import CoreLocation
import AblyAssetTrackingInternalTesting
import AblyAssetTrackingPublisherTesting

@available(iOS 13.4, *)
class LocationManagerHandlerTests: XCTestCase {
    var logger: InternalLogHandlerMock!
    var locationManagerHandler: LocationManagerHandler!
    var validCLLocation: CLLocation!
    var repairableCLLocation: CLLocation!
    var unrepairableTimestampCLLocation: CLLocation!
    var unrepairableAltitudeCLLocation: CLLocation!
    var unrepairableLongitudeCLLocation: CLLocation!
    var unrepairableLatitudeCLLocation: CLLocation!
    var date: Date!
    
    override func setUpWithError() throws {
        logger = InternalLogHandlerMock.configured
        locationManagerHandler = LocationManagerHandler(logHandler: logger)
        date = Date()
        
        validCLLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 1.234, longitude: 5.67),
                                             altitude: 100,
                                             horizontalAccuracy: 10,
                                             verticalAccuracy: 10,
                                             course: 10,
                                             courseAccuracy: 10,
                                             speed: 10,
                                             speedAccuracy: 10,
                                             timestamp: date)
        
        repairableCLLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 1.234, longitude: 5.67),
                                             altitude: 100,
                                             horizontalAccuracy: 100/0,
                                             verticalAccuracy: 100/0,
                                             course: 100/0,
                                             courseAccuracy: 100/0,
                                             speed: 100/0,
                                             speedAccuracy: 100/0,
                                             timestamp: date)
        
        unrepairableTimestampCLLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 1.234, longitude: 3.45),
                                             altitude: 100/0,
                                             horizontalAccuracy: 10,
                                             verticalAccuracy: 10,
                                             course: 10,
                                             courseAccuracy: 10,
                                             speed: 10,
                                             speedAccuracy: 10,
                                             timestamp: Date(timeIntervalSince1970: 0))
        
        unrepairableAltitudeCLLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 1.234, longitude: 3.45),
                                             altitude: 100/0,
                                             horizontalAccuracy: 10,
                                             verticalAccuracy: 10,
                                             course: 10,
                                             courseAccuracy: 10,
                                             speed: 10,
                                             speedAccuracy: 10,
                                             timestamp: date)
        
        unrepairableLongitudeCLLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 1.234, longitude: 100/0),
                                             altitude: 100,
                                             horizontalAccuracy: 10,
                                             verticalAccuracy: 10,
                                             course: 10,
                                             courseAccuracy: 10,
                                             speed: 10,
                                             speedAccuracy: 10,
                                             timestamp: date)
        
        unrepairableLatitudeCLLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 100/0, longitude: 5.67),
                                             altitude: 100,
                                             horizontalAccuracy: 10,
                                             verticalAccuracy: 10,
                                             course: 10,
                                             courseAccuracy: 10,
                                             speed: 10,
                                             speedAccuracy: 10,
                                             timestamp: date)
    }
    
    func test_locationManagerHandler_handleEnhancedLocationUpdate_forwardsValidLocation() {
        let mockDelegate = MockLocationManagerHandlerDelegate()
        locationManagerHandler.delegate = mockDelegate
        locationManagerHandler.handleEnhancedLocationUpdate(location: validCLLocation)
        
        XCTAssertTrue(mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationCalled)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationParamLocation?.coordinate.latitude, validCLLocation.coordinate.latitude)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationParamLocation?.coordinate.longitude, validCLLocation.coordinate.longitude)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationParamLocation?.altitude, validCLLocation.altitude)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationParamLocation?.horizontalAccuracy, validCLLocation.horizontalAccuracy)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationParamLocation?.verticalAccuracy, validCLLocation.verticalAccuracy)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationParamLocation?.course, validCLLocation.course)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationParamLocation?.courseAccuracy, validCLLocation.courseAccuracy)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationParamLocation?.speed, validCLLocation.speed)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationParamLocation?.speedAccuracy, validCLLocation.speedAccuracy)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationParamLocation?.timestamp, date.timeIntervalSince1970)
        print();
    }
    
    func test_locationManagerHandler_handleRawLocationUpdate_forwardsValidLocation() {
        let mockDelegate = MockLocationManagerHandlerDelegate()
        locationManagerHandler.delegate = mockDelegate
        locationManagerHandler.handleRawLocationUpdate(location: validCLLocation)
        
        XCTAssertTrue(mockDelegate.locationManagerHandlerDidUpdateRawLocationCalled)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateRawLocationParamLocation?.coordinate.latitude, validCLLocation.coordinate.latitude)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateRawLocationParamLocation?.coordinate.longitude, validCLLocation.coordinate.longitude)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateRawLocationParamLocation?.altitude, validCLLocation.altitude)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateRawLocationParamLocation?.horizontalAccuracy, validCLLocation.horizontalAccuracy)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateRawLocationParamLocation?.verticalAccuracy, validCLLocation.verticalAccuracy)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateRawLocationParamLocation?.course, validCLLocation.course)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateRawLocationParamLocation?.courseAccuracy, validCLLocation.courseAccuracy)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateRawLocationParamLocation?.speed, validCLLocation.speed)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateRawLocationParamLocation?.speedAccuracy, validCLLocation.speedAccuracy)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateRawLocationParamLocation?.timestamp, date.timeIntervalSince1970)
        print();
    }
    
    func test_locationManagerHandler_handleEnhancedLocationUpdate_sanitizesRepairableLocation() {
        let mockDelegate = MockLocationManagerHandlerDelegate()
        locationManagerHandler.delegate = mockDelegate
        locationManagerHandler.handleEnhancedLocationUpdate(location: repairableCLLocation)
        
        XCTAssertTrue(mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationCalled)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationParamLocation?.coordinate.latitude, repairableCLLocation.coordinate.latitude)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationParamLocation?.coordinate.longitude, repairableCLLocation.coordinate.longitude)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationParamLocation?.altitude, repairableCLLocation.altitude)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationParamLocation?.horizontalAccuracy, -1)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationParamLocation?.verticalAccuracy, -1)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationParamLocation?.course, -1)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationParamLocation?.courseAccuracy, -1)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationParamLocation?.speed, -1)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationParamLocation?.speedAccuracy, -1)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationParamLocation?.timestamp, date.timeIntervalSince1970)
        print();
    }
    
    func test_locationManagerHandler_handleRawLocationUpdate_sanitizesRepairableLocation() {
        let mockDelegate = MockLocationManagerHandlerDelegate()
        locationManagerHandler.delegate = mockDelegate
        locationManagerHandler.handleRawLocationUpdate(location: repairableCLLocation)
        
        XCTAssertTrue(mockDelegate.locationManagerHandlerDidUpdateRawLocationCalled)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateRawLocationParamLocation?.coordinate.latitude, repairableCLLocation.coordinate.latitude)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateRawLocationParamLocation?.coordinate.longitude, repairableCLLocation.coordinate.longitude)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateRawLocationParamLocation?.altitude, repairableCLLocation.altitude)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateRawLocationParamLocation?.horizontalAccuracy, -1)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateRawLocationParamLocation?.verticalAccuracy, -1)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateRawLocationParamLocation?.course, -1)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateRawLocationParamLocation?.courseAccuracy, -1)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateRawLocationParamLocation?.speed, -1)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateRawLocationParamLocation?.speedAccuracy, -1)
        XCTAssertEqual(mockDelegate.locationManagerHandlerDidUpdateRawLocationParamLocation?.timestamp, date.timeIntervalSince1970)
    }
    
    func test_locationManagerHandler_handleRawLocationUpdate_suppressesRawLocationUpdateWithInvalidLatitude() {
        let mockDelegate = MockLocationManagerHandlerDelegate()
        locationManagerHandler.delegate = mockDelegate
        locationManagerHandler.handleRawLocationUpdate(location: unrepairableLatitudeCLLocation)
        
        XCTAssertTrue(!mockDelegate.locationManagerHandlerDidUpdateRawLocationCalled)
    }
    
    func test_locationManagerHandler_handleRawLocationUpdate_suppressesRawLocationUpdateWithInvalidLongitude() {
        let mockDelegate = MockLocationManagerHandlerDelegate()
        locationManagerHandler.delegate = mockDelegate
        locationManagerHandler.handleRawLocationUpdate(location: unrepairableLongitudeCLLocation)
        
        XCTAssertTrue(!mockDelegate.locationManagerHandlerDidUpdateRawLocationCalled)
    }
    
    func test_locationManagerHandler_handleRawLocationUpdate_suppressesRawLocationUpdateWithInvalidAltitude() {
        let mockDelegate = MockLocationManagerHandlerDelegate()
        locationManagerHandler.delegate = mockDelegate
        locationManagerHandler.handleRawLocationUpdate(location: unrepairableAltitudeCLLocation)
        
        XCTAssertTrue(!mockDelegate.locationManagerHandlerDidUpdateRawLocationCalled)
    }
    
    func test_locationManagerHandler_handleRawLocationUpdate_suppressesRawLocationUpdateWithInvalidTimestamp() {
        let mockDelegate = MockLocationManagerHandlerDelegate()
        locationManagerHandler.delegate = mockDelegate
        locationManagerHandler.handleRawLocationUpdate(location: unrepairableTimestampCLLocation)
        
        XCTAssertTrue(!mockDelegate.locationManagerHandlerDidUpdateRawLocationCalled)
    }
    
    func test_locationManagerHandler_handleEnhancedLocationUpdate_suppressesEnhancedLocationUpdateWithInvalidLatitude() {
        let mockDelegate = MockLocationManagerHandlerDelegate()
        locationManagerHandler.delegate = mockDelegate
        locationManagerHandler.handleEnhancedLocationUpdate(location: unrepairableLatitudeCLLocation)
        
        XCTAssertTrue(!mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationCalled)
    }
    
    func test_locationManagerHandler_handleEnhancedLocationUpdate_suppressesEnhancedLocationUpdateWithInvalidLongitude() {
        let mockDelegate = MockLocationManagerHandlerDelegate()
        locationManagerHandler.delegate = mockDelegate
        locationManagerHandler.handleEnhancedLocationUpdate(location: unrepairableLongitudeCLLocation)
        
        XCTAssertTrue(!mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationCalled)
    }
    
    func test_locationManagerHandler_handleEnhancedLocationUpdate_suppressesEnhancedLocationUpdateWithInvalidAltitude() {
        let mockDelegate = MockLocationManagerHandlerDelegate()
        locationManagerHandler.delegate = mockDelegate
        locationManagerHandler.handleEnhancedLocationUpdate(location: unrepairableAltitudeCLLocation)
        
        XCTAssertTrue(!mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationCalled)
    }
    
    func test_locationManagerHandler_handleEnhancedLocationUpdate_suppressesEnhancedLocationUpdateWithInvalidTimestamp() {
        let mockDelegate = MockLocationManagerHandlerDelegate()
        locationManagerHandler.delegate = mockDelegate
        locationManagerHandler.handleEnhancedLocationUpdate(location: unrepairableTimestampCLLocation)
        
        XCTAssertTrue(!mockDelegate.locationManagerHandlerDidUpdateEnhancedLocationCalled)
    }
}
