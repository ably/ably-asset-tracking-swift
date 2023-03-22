import AblyAssetTrackingInternalTesting
@testable import AblyAssetTrackingPublisher
import AblyAssetTrackingPublisherTesting
import CoreLocation
import XCTest

@available(iOS 13.4, *)
class PassiveLocationManagerHandlerTests: XCTestCase {
    var logger: InternalLogHandlerMockThreadSafe!
    var passiveLocationManagerHandler: PassiveLocationManagerHandler!
    var validCLLocation: CLLocation!
    var repairableCLLocation: CLLocation!
    var unrepairableTimestampCLLocation: CLLocation!
    var unrepairableAltitudeCLLocation: CLLocation!
    var unrepairableLongitudeCLLocation: CLLocation!
    var unrepairableLatitudeCLLocation: CLLocation!
    var date: Date!

    override func setUpWithError() throws {
        logger = InternalLogHandlerMockThreadSafe()
        passiveLocationManagerHandler = PassiveLocationManagerHandler(logHandler: logger)
        date = Date()

        validCLLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 1.234, longitude: 5.67),
            altitude: 100,
            horizontalAccuracy: 10,
            verticalAccuracy: 10,
            course: 10,
            courseAccuracy: 10,
            speed: 10,
            speedAccuracy: 10,
            timestamp: date
        )

        repairableCLLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 1.234, longitude: 5.67),
            altitude: 100,
            horizontalAccuracy: 100 / 0,
            verticalAccuracy: 100 / 0,
            course: 100 / 0,
            courseAccuracy: 100 / 0,
            speed: 100 / 0,
            speedAccuracy: 100 / 0,
            timestamp: date
        )

        unrepairableTimestampCLLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 1.234, longitude: 3.45),
            altitude: 100 / 0,
            horizontalAccuracy: 10,
            verticalAccuracy: 10,
            course: 10,
            courseAccuracy: 10,
            speed: 10,
            speedAccuracy: 10,
            timestamp: Date(timeIntervalSince1970: 0)
        )

        unrepairableAltitudeCLLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 1.234, longitude: 3.45),
            altitude: 100 / 0,
            horizontalAccuracy: 10,
            verticalAccuracy: 10,
            course: 10,
            courseAccuracy: 10,
            speed: 10,
            speedAccuracy: 10,
            timestamp: date
        )

        unrepairableLongitudeCLLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 1.234, longitude: 100 / 0),
            altitude: 100,
            horizontalAccuracy: 10,
            verticalAccuracy: 10,
            course: 10,
            courseAccuracy: 10,
            speed: 10,
            speedAccuracy: 10,
            timestamp: date
        )

        unrepairableLatitudeCLLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 100 / 0, longitude: 5.67),
            altitude: 100,
            horizontalAccuracy: 10,
            verticalAccuracy: 10,
            course: 10,
            courseAccuracy: 10,
            speed: 10,
            speedAccuracy: 10,
            timestamp: date
        )
    }

    func test_passiveLocationManagerHandler_handleEnhancedLocationUpdate_forwardsValidLocation() {
        let mockDelegate = MockPassiveLocationManagerHandlerDelegate()
        passiveLocationManagerHandler.delegate = mockDelegate
        passiveLocationManagerHandler.handleEnhancedLocationUpdate(location: validCLLocation)

        XCTAssertTrue(mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationCalled)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationParamLocation?.coordinate.latitude, validCLLocation.coordinate.latitude)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationParamLocation?.coordinate.longitude, validCLLocation.coordinate.longitude)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationParamLocation?.altitude, validCLLocation.altitude)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationParamLocation?.horizontalAccuracy, validCLLocation.horizontalAccuracy)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationParamLocation?.verticalAccuracy, validCLLocation.verticalAccuracy)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationParamLocation?.course, validCLLocation.course)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationParamLocation?.courseAccuracy, validCLLocation.courseAccuracy)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationParamLocation?.speed, validCLLocation.speed)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationParamLocation?.speedAccuracy, validCLLocation.speedAccuracy)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationParamLocation?.timestamp, date.timeIntervalSince1970)
        print()
    }

    func test_passiveLocationManagerHandler_handleRawLocationUpdate_forwardsValidLocation() {
        let mockDelegate = MockPassiveLocationManagerHandlerDelegate()
        passiveLocationManagerHandler.delegate = mockDelegate
        passiveLocationManagerHandler.handleRawLocationUpdate(location: validCLLocation)

        XCTAssertTrue(mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationCalled)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationParamLocation?.coordinate.latitude, validCLLocation.coordinate.latitude)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationParamLocation?.coordinate.longitude, validCLLocation.coordinate.longitude)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationParamLocation?.altitude, validCLLocation.altitude)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationParamLocation?.horizontalAccuracy, validCLLocation.horizontalAccuracy)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationParamLocation?.verticalAccuracy, validCLLocation.verticalAccuracy)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationParamLocation?.course, validCLLocation.course)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationParamLocation?.courseAccuracy, validCLLocation.courseAccuracy)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationParamLocation?.speed, validCLLocation.speed)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationParamLocation?.speedAccuracy, validCLLocation.speedAccuracy)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationParamLocation?.timestamp, date.timeIntervalSince1970)
        print()
    }

    func test_passiveLocationManagerHandler_handleEnhancedLocationUpdate_sanitizesRepairableLocation() {
        let mockDelegate = MockPassiveLocationManagerHandlerDelegate()
        passiveLocationManagerHandler.delegate = mockDelegate
        passiveLocationManagerHandler.handleEnhancedLocationUpdate(location: repairableCLLocation)

        XCTAssertTrue(mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationCalled)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationParamLocation?.coordinate.latitude, repairableCLLocation.coordinate.latitude)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationParamLocation?.coordinate.longitude, repairableCLLocation.coordinate.longitude)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationParamLocation?.altitude, repairableCLLocation.altitude)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationParamLocation?.horizontalAccuracy, -1)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationParamLocation?.verticalAccuracy, -1)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationParamLocation?.course, -1)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationParamLocation?.courseAccuracy, -1)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationParamLocation?.speed, -1)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationParamLocation?.speedAccuracy, -1)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationParamLocation?.timestamp, date.timeIntervalSince1970)
        print()
    }

    func test_passiveLocationManagerHandler_handleRawLocationUpdate_sanitizesRepairableLocation() {
        let mockDelegate = MockPassiveLocationManagerHandlerDelegate()
        passiveLocationManagerHandler.delegate = mockDelegate
        passiveLocationManagerHandler.handleRawLocationUpdate(location: repairableCLLocation)

        XCTAssertTrue(mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationCalled)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationParamLocation?.coordinate.latitude, repairableCLLocation.coordinate.latitude)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationParamLocation?.coordinate.longitude, repairableCLLocation.coordinate.longitude)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationParamLocation?.altitude, repairableCLLocation.altitude)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationParamLocation?.horizontalAccuracy, -1)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationParamLocation?.verticalAccuracy, -1)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationParamLocation?.course, -1)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationParamLocation?.courseAccuracy, -1)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationParamLocation?.speed, -1)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationParamLocation?.speedAccuracy, -1)
        XCTAssertEqual(mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationParamLocation?.timestamp, date.timeIntervalSince1970)
    }

    func test_passiveLocationManagerHandler_handleRawLocationUpdate_suppressesRawLocationUpdateWithInvalidLatitude() {
        let mockDelegate = MockPassiveLocationManagerHandlerDelegate()
        passiveLocationManagerHandler.delegate = mockDelegate
        passiveLocationManagerHandler.handleRawLocationUpdate(location: unrepairableLatitudeCLLocation)

        XCTAssertTrue(!mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationCalled)
    }

    func test_passiveLocationManagerHandler_handleRawLocationUpdate_suppressesRawLocationUpdateWithInvalidLongitude() {
        let mockDelegate = MockPassiveLocationManagerHandlerDelegate()
        passiveLocationManagerHandler.delegate = mockDelegate
        passiveLocationManagerHandler.handleRawLocationUpdate(location: unrepairableLongitudeCLLocation)

        XCTAssertTrue(!mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationCalled)
    }

    func test_passiveLocationManagerHandler_handleRawLocationUpdate_suppressesRawLocationUpdateWithInvalidAltitude() {
        let mockDelegate = MockPassiveLocationManagerHandlerDelegate()
        passiveLocationManagerHandler.delegate = mockDelegate
        passiveLocationManagerHandler.handleRawLocationUpdate(location: unrepairableAltitudeCLLocation)

        XCTAssertTrue(!mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationCalled)
    }

    func test_passiveLocationManagerHandler_handleRawLocationUpdate_suppressesRawLocationUpdateWithInvalidTimestamp() {
        let mockDelegate = MockPassiveLocationManagerHandlerDelegate()
        passiveLocationManagerHandler.delegate = mockDelegate
        passiveLocationManagerHandler.handleRawLocationUpdate(location: unrepairableTimestampCLLocation)

        XCTAssertTrue(!mockDelegate.passiveLocationManagerHandlerDidUpdateRawLocationCalled)
    }

    func test_passiveLocationManagerHandler_handleEnhancedLocationUpdate_suppressesEnhancedLocationUpdateWithInvalidLatitude() {
        let mockDelegate = MockPassiveLocationManagerHandlerDelegate()
        passiveLocationManagerHandler.delegate = mockDelegate
        passiveLocationManagerHandler.handleEnhancedLocationUpdate(location: unrepairableLatitudeCLLocation)

        XCTAssertTrue(!mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationCalled)
    }

    func test_passiveLocationManagerHandler_handleEnhancedLocationUpdate_suppressesEnhancedLocationUpdateWithInvalidLongitude() {
        let mockDelegate = MockPassiveLocationManagerHandlerDelegate()
        passiveLocationManagerHandler.delegate = mockDelegate
        passiveLocationManagerHandler.handleEnhancedLocationUpdate(location: unrepairableLongitudeCLLocation)

        XCTAssertTrue(!mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationCalled)
    }

    func test_passiveLocationManagerHandler_handleEnhancedLocationUpdate_suppressesEnhancedLocationUpdateWithInvalidAltitude() {
        let mockDelegate = MockPassiveLocationManagerHandlerDelegate()
        passiveLocationManagerHandler.delegate = mockDelegate
        passiveLocationManagerHandler.handleEnhancedLocationUpdate(location: unrepairableAltitudeCLLocation)

        XCTAssertTrue(!mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationCalled)
    }

    func test_passiveLocationManagerHandler_handleEnhancedLocationUpdate_suppressesEnhancedLocationUpdateWithInvalidTimestamp() {
        let mockDelegate = MockPassiveLocationManagerHandlerDelegate()
        passiveLocationManagerHandler.delegate = mockDelegate
        passiveLocationManagerHandler.handleEnhancedLocationUpdate(location: unrepairableTimestampCLLocation)

        XCTAssertTrue(!mockDelegate.passiveLocationManagerHandlerDidUpdateEnhancedLocationCalled)
    }
}
