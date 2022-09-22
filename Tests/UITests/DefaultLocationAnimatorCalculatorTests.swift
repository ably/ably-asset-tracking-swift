import AblyAssetTrackingCore
@testable import AblyAssetTrackingUI
import XCTest

private struct LocationUpdateImpl: LocationUpdate {
    var location: Location
    var skippedLocations: [Location]
}

private func assertEqualResults(
    _ result1: DefaultLocationAnimatorCalculator.CalculationResult,
    _ result2: DefaultLocationAnimatorCalculator.CalculationResult,
    positionAccuracy: Double = 0,
    stepProportionAccuracy: Double = 0,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    assertEqualStates(
        result1.newState,
        result2.newState,
        stepProportionAccuracy: stepProportionAccuracy,
        file: file,
        line: line
    )
    assertEqualSubscriberUpdates(
        result1.subscriberUpdates,
        result2.subscriberUpdates,
        positionAccuracy: positionAccuracy,
        file: file,
        line: line
    )
}

private func assertEqualStates(
    _ state1: DefaultLocationAnimatorCalculator.Input.State,
    _ state2: DefaultLocationAnimatorCalculator.Input.State,
    stepProportionAccuracy: Double = 0,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssertEqual(
        state1.displayLinkLastFiredAt,
        state2.displayLinkLastFiredAt,
        "displayLinkLastFiredAt does not match",
        file: file,
        line: line
    )
    XCTAssertEqual(
        state1.locationsAwaitingAnimation,
        state2.locationsAwaitingAnimation,
        "locationsAwaitingAnimation does not match",
        file: file,
        line: line
    )

    if state1.proportionOfFirstStepAlreadyAnimated != nil, state2.proportionOfFirstStepAlreadyAnimated == nil {
        XCTFail(
            "proportionOfFirstStepAlreadyAnimated is non-nil in state1 and nil in state2",
            file: file,
            line: line
        )
    }
    if state1.proportionOfFirstStepAlreadyAnimated == nil, state2.proportionOfFirstStepAlreadyAnimated != nil {
        XCTFail(
            "proportionOfFirstStepAlreadyAnimated is nil in state1 and non-nil in state2",
            file: file,
            line: line
        )
    }
    if let proportionOfFirstStepAlreadyAnimated1 = state1.proportionOfFirstStepAlreadyAnimated,
       let proportionOfFirstStepAlreadyAnimated2 = state2.proportionOfFirstStepAlreadyAnimated
    {
        XCTAssertEqual(
            proportionOfFirstStepAlreadyAnimated1,
            proportionOfFirstStepAlreadyAnimated2,
            accuracy: stepProportionAccuracy,
            "proportionOfFirstStepAlreadyAnimated does not match",
            file: file,
            line: line
        )
    }

    XCTAssertEqual(
        state1.numberOfLocationsPoppedSinceLastCameraUpdate,
        state2.numberOfLocationsPoppedSinceLastCameraUpdate,
        "numberOfLocationsPoppedSinceLastCameraUpdate does not match",
        file: file,
        line: line
    )
}

private func assertEqualSubscriberUpdates(
    _ subscriberUpdates1: DefaultLocationAnimatorCalculator.CalculationResult.SubscriberUpdates?,
    _ subscriberUpdates2: DefaultLocationAnimatorCalculator.CalculationResult.SubscriberUpdates?,
    positionAccuracy: Double = 0,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    if subscriberUpdates1 != nil, subscriberUpdates2 == nil {
        XCTFail(
            "subscriberUpdates1 is non-nil and subscriberUpdates2 is nil",
            file: file,
            line: line
        )
    }
    if subscriberUpdates1 == nil, subscriberUpdates2 != nil {
        XCTFail(
            "subscriberUpdates1 is nil and subscriberUpdates2 is non-nil",
            file: file,
            line: line
        )
    }

    if let subscriberUpdates1 = subscriberUpdates1, let subscriberUpdates2 = subscriberUpdates2 {
        assertEqualPositions(
            subscriberUpdates1.positionToEmit,
            subscriberUpdates2.positionToEmit,
            accuracy: positionAccuracy,
            file: file,
            line: line
        )
        XCTAssertEqual(
            subscriberUpdates1.shouldEmitCameraPositionUpdate,
            subscriberUpdates2.shouldEmitCameraPositionUpdate,
            "shouldEmitCameraPositionUpdate does not match",
            file: file,
            line: line
        )
    }
}

private func assertEqualPositions(
    _ position1: Position,
    _ position2: Position,
    accuracy: Double,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    XCTAssertEqual(
        position1.longitude,
        position2.longitude,
        accuracy: accuracy,
        "longitude does not match",
        file: file,
        line: line
    )
    XCTAssertEqual(
        position1.latitude,
        position2.latitude,
        accuracy: accuracy,
        "latitude does not match",
        file: file,
        line: line
    )
    XCTAssertEqual(
        position1.accuracy,
        position2.accuracy,
        accuracy: accuracy,
        "accuracy does not match",
        file: file,
        line: line
    )
    XCTAssertEqual(
        position1.bearing,
        position2.bearing,
        accuracy: accuracy,
        "bearing does not match",
        file: file,
        line: line
    )
}

final class DefaultLocationAnimatorCalculatorTests: XCTestCase {
    func test_calculate_whenNextLocationUpdatePredictionIsNil_itReturnsANoOp() {
        let input = DefaultLocationAnimatorCalculator.Input(
            config: .init(
                animationStepsBetweenCameraUpdates: 5,
                intentionalAnimationDelay: 0
            ),
            context: .init(
                now: 5,
                nextLocationUpdatePrediction: nil
            ),
            state: .initial
        )
        let result = DefaultLocationAnimatorCalculator.calculate(input: input)

        assertEqualResults(result, .noOp(input: input))
    }

    func test_calculate_whenDisplayLinkHasNotFiredBefore_andThereAreNoLocationsAwaitingAnimation_itReturnsANoOp() {
        let input = DefaultLocationAnimatorCalculator.Input(
            config: .init(
                animationStepsBetweenCameraUpdates: 5,
                intentionalAnimationDelay: 0
            ),
            context: .init(
                now: 5,
                nextLocationUpdatePrediction: .init(receivedAt: 2.0, nextUpdateExpectedIn: 6)
            ),
            state: .initial
        )

        let result = DefaultLocationAnimatorCalculator.calculate(input: input)

        assertEqualResults(result, .noOp(input: input))
    }

    func test_calculate_whenDisplayLinkHasNotFiredBefore_andThereAreLocationsAwaitingAnimation_itEmitsTheFirstLocationAwaitingAnimation(
    ) {
        let input = DefaultLocationAnimatorCalculator.Input(
            config: .init(
                animationStepsBetweenCameraUpdates: 5,
                intentionalAnimationDelay: 0
            ),
            context: .init(
                now: 5,
                nextLocationUpdatePrediction: .init(
                    receivedAt: 2,
                    nextUpdateExpectedIn: 6
                )
            ),
            state: .init(
                displayLinkLastFiredAt: nil,
                locationsAwaitingAnimation: [
                    Location(coordinate: .init(latitude: 10, longitude: 20)),
                    Location(coordinate: .init(latitude: 10.5, longitude: 20.5)),
                ],
                proportionOfFirstStepAlreadyAnimated: nil,
                numberOfLocationsPoppedSinceLastCameraUpdate: nil
            )
        )

        let result = DefaultLocationAnimatorCalculator.calculate(input: input)

        let expectedResult = DefaultLocationAnimatorCalculator.CalculationResult(
            newState: .init(
                displayLinkLastFiredAt: 5,
                locationsAwaitingAnimation: [
                    Location(coordinate: .init(latitude: 10, longitude: 20)),
                    Location(coordinate: .init(latitude: 10.5, longitude: 20.5)),
                ],
                proportionOfFirstStepAlreadyAnimated: 0,
                numberOfLocationsPoppedSinceLastCameraUpdate: 0
            ),
            subscriberUpdates: .init(
                positionToEmit: input.state.locationsAwaitingAnimation[0].toPosition(),
                shouldEmitCameraPositionUpdate: true
            )
        )

        assertEqualResults(result, expectedResult)
    }

    func test_calculate_whenDisplayLinkHasFiredBefore_andThereIsOneLocationAwaitingAnimation_itReturnsANoOp() {
        let input = DefaultLocationAnimatorCalculator.Input(
            config: .init(
                animationStepsBetweenCameraUpdates: 5,
                intentionalAnimationDelay: 0
            ),
            context: .init(
                now: 5,
                nextLocationUpdatePrediction: .init(
                    receivedAt: 2,
                    nextUpdateExpectedIn: 6
                )
            ),
            state: .init(
                displayLinkLastFiredAt: 4.5,
                locationsAwaitingAnimation: [
                    Location(coordinate: .init(latitude: 10, longitude: 20)),
                ],
                proportionOfFirstStepAlreadyAnimated: nil,
                numberOfLocationsPoppedSinceLastCameraUpdate: nil
            )
        )

        let result = DefaultLocationAnimatorCalculator.calculate(input: input)

        assertEqualResults(result, .noOp(input: input))
    }

    func test_calculate_whenDisplayLinkHasFiredBefore_andThereAreLocationsAwaitingAnimation_andTheNextLocationToEmitLiesBetweenTheFirstTwoLocations_itInterpolatesBetweenTheFirstTwoLocations_andDoesNotPopAnyLocations(
    ) {
        let input = DefaultLocationAnimatorCalculator.Input(
            config: .init(
                animationStepsBetweenCameraUpdates: 5,
                intentionalAnimationDelay: 2
            ),
            context: .init(
                now: 5,
                nextLocationUpdatePrediction: .init(
                    receivedAt: 2,
                    nextUpdateExpectedIn: 6
                )
            ),
            state: .init(
                displayLinkLastFiredAt: 4.5,
                locationsAwaitingAnimation: [
                    Location(coordinate: .init(latitude: 10, longitude: 20)),
                    Location(coordinate: .init(latitude: 10.5, longitude: 20.5)),
                    Location(coordinate: .init(latitude: 11, longitude: 21)),
                ],
                proportionOfFirstStepAlreadyAnimated: nil,
                numberOfLocationsPoppedSinceLastCameraUpdate: 1
            )
        )

        let result = DefaultLocationAnimatorCalculator.calculate(input: input)

        /*
         The next location update is expected 3 seconds from now, so our aim is to animate through all of locationUpdates in (3 + intentionalAnimationDelay) = 5 seconds.

         It's been 0.5 seconds since the display link last fired. That means that, at this moment, we assume we'll be splitting our animation into 5 / 0.5 = 10 steps.

         That means that each step represents the transition between (3 - 1) / 10 = 0.2 location updates.

         So we want to emit a position that is 0.2 * 100 = 20% of the way between locationUpdates[0] and locationUpdates[1].
         */

        assertEqualResults(
            result,
            .init(
                newState: .init(
                    displayLinkLastFiredAt: 5,
                    locationsAwaitingAnimation: input.state.locationsAwaitingAnimation,
                    proportionOfFirstStepAlreadyAnimated: 0.2,
                    numberOfLocationsPoppedSinceLastCameraUpdate: 1
                ),
                subscriberUpdates: .init(
                    positionToEmit: .init(latitude: 10.1, longitude: 20.1, accuracy: 0, bearing: 0),
                    shouldEmitCameraPositionUpdate: false
                )
            )
        )
    }

    func test_calculate_whenDisplayLinkHasFiredBefore_andThereAreLocationsAwaitingAnimation_andTheNextLocationToEmitLiesBetweenTheSecondAndThirdLocations_itInterpolatesBetweenTheSecondAndThirdLocationUpdates_andPopsTheFirstLocation(
    ) {
        let input = DefaultLocationAnimatorCalculator.Input(
            config: .init(
                animationStepsBetweenCameraUpdates: 5,
                intentionalAnimationDelay: 2
            ),
            context: .init(
                now: 5,
                nextLocationUpdatePrediction: .init(
                    receivedAt: 2,
                    nextUpdateExpectedIn: 6
                )
            ),
            state: .init(
                displayLinkLastFiredAt: 1,
                locationsAwaitingAnimation: [
                    Location(coordinate: .init(latitude: 10, longitude: 20)),
                    Location(coordinate: .init(latitude: 10.5, longitude: 20.5)),
                    Location(coordinate: .init(latitude: 11, longitude: 21)),
                ],
                proportionOfFirstStepAlreadyAnimated: nil,
                numberOfLocationsPoppedSinceLastCameraUpdate: 1
            )
        )

        let result = DefaultLocationAnimatorCalculator.calculate(input: input)

        /*
         The next location update is expected 3 seconds from now, so our aim is to animate through all of locationUpdates in (3 + intentionalAnimationDelay) = 5 seconds.

         It's been 4 seconds since the display link last fired. That means that, at this moment, we assume we'll be splitting our animation into 5 / 4 = 1.25 steps.

         That means that each step represents the transition between (3 - 1) / 1.25 = 1.6 location updates.

         So we want to emit a position that is 0.6 * 100 = 60% of the way between locationUpdates[1] and locationUpdates[2]. And we no longer need locationUpdates[0] so we can pop that from the list.
         */

        assertEqualResults(
            result,
            .init(
                newState: .init(
                    displayLinkLastFiredAt: 5,
                    locationsAwaitingAnimation: [
                        Location(coordinate: .init(latitude: 10.5, longitude: 20.5)),
                        Location(coordinate: .init(latitude: 11, longitude: 21)),
                    ],
                    proportionOfFirstStepAlreadyAnimated: 0.6,
                    numberOfLocationsPoppedSinceLastCameraUpdate: 2
                ),
                subscriberUpdates: .init(
                    positionToEmit: .init(latitude: 10.8, longitude: 20.8, accuracy: 0, bearing: 0),
                    shouldEmitCameraPositionUpdate: false
                )
            ),
            stepProportionAccuracy: 0.001
        )
    }

    func test_calculate_whenDisplayLinkHasFiredBefore_andThereAreLocationsAwaitingAnimation_andSomeOfTheDistanceBetweenTheFirstTwoLocationsHasAlreadyBeenAnimated_andTheNextLocationToEmitLiesBetweenTheFirstTwoLocations_itInterpolatesTheRemainderOfTheDistanceBetweenTheFirstTwoLocations_andDoesNotPopAnyLocations(
    ) {
        let input = DefaultLocationAnimatorCalculator.Input(
            config: .init(animationStepsBetweenCameraUpdates: 5, intentionalAnimationDelay: 2),
            context: .init(now: 5, nextLocationUpdatePrediction: .init(
                receivedAt: 2,
                nextUpdateExpectedIn: 6
            )),
            state: .init(
                displayLinkLastFiredAt: 4.5,
                locationsAwaitingAnimation: [
                    Location(coordinate: .init(latitude: 10, longitude: 20)),
                    Location(coordinate: .init(latitude: 10.5, longitude: 20.5)),
                    Location(coordinate: .init(latitude: 11, longitude: 21)),
                ],
                proportionOfFirstStepAlreadyAnimated: 0.6,
                numberOfLocationsPoppedSinceLastCameraUpdate: 1
            )
        )

        let result = DefaultLocationAnimatorCalculator.calculate(input: input)

        /*
         The next location update is expected 3 seconds from now, so our aim is to animate through all of locationUpdates in (3 + intentionalAnimationDelay) = 5 seconds.

         It's been 0.5 seconds since the display link last fired. That means that, at this moment, we assume we'll be splitting our animation into 5 / 0.5 = 10 steps.

         That means that each step represents the transition between (3 - 0.6 - 1) / 10 = 0.14 location updates.

         So we want to emit a position that is (0.6 + 0.14) * 100 = 74% of the way between locationUpdates[0] and locationUpdates[1].
         */

        assertEqualResults(
            result,
            .init(
                newState: .init(
                    displayLinkLastFiredAt: 5,
                    locationsAwaitingAnimation: [
                        Location(coordinate: .init(latitude: 10, longitude: 20)),
                        Location(coordinate: .init(latitude: 10.5, longitude: 20.5)),
                        Location(coordinate: .init(latitude: 11, longitude: 21)),
                    ],
                    proportionOfFirstStepAlreadyAnimated: 0.74,
                    numberOfLocationsPoppedSinceLastCameraUpdate: 1
                ),
                subscriberUpdates: .init(
                    positionToEmit: .init(latitude: 10.37, longitude: 20.37, accuracy: 0, bearing: 0),
                    shouldEmitCameraPositionUpdate: false
                )
            )
        )
    }

    func test_calculate_whenDisplayLinkHasFiredBefore_andThereAreLocationsAwaitingAnimation_andSomeOfTheDistanceBetweenTheFirstTwoLocationsHasAlreadyBeenAnimated_andTheNextLocationToEmitLiesBetweenTheSecondAndThirdLocations_itInterpolatesBetweenTheSecondAndThirdLocations_andPopsTheFirstLocation(
    ) {
        let input = DefaultLocationAnimatorCalculator.Input(
            config: .init(animationStepsBetweenCameraUpdates: 5, intentionalAnimationDelay: 2),
            context: .init(now: 7, nextLocationUpdatePrediction: .init(
                receivedAt: 2,
                nextUpdateExpectedIn: 6
            )),
            state: .init(
                displayLinkLastFiredAt: 6,
                locationsAwaitingAnimation: [
                    Location(coordinate: .init(latitude: 10, longitude: 20)),
                    Location(coordinate: .init(latitude: 10.5, longitude: 20.5)),
                    Location(coordinate: .init(latitude: 11, longitude: 21)),
                ],
                proportionOfFirstStepAlreadyAnimated: 0.6,
                numberOfLocationsPoppedSinceLastCameraUpdate: 1
            )
        )

        let result = DefaultLocationAnimatorCalculator.calculate(input: input)

        /*
         The next location update is expected 1 second from now, so our aim is to animate through all of locationUpdates in (1 + intentionalAnimationDelay) = 3 seconds.

         It's been 1 second since the display link last fired. That means that, at this moment, we assume we'll be splitting our animation into 3 / 1 = 3 steps.

         That means that each step represents the transition between (3 - 0.6 - 1) / 3 = 0.46… location updates.

         So we want to emit a position that is (0.6 + 0.46… - 1) * 100 = 6.6…% of the way between locationUpdates[1] and locationUpdates[2].
         */

        assertEqualResults(
            result,
            .init(
                newState: .init(displayLinkLastFiredAt: 7, locationsAwaitingAnimation: [
                    Location(coordinate: .init(latitude: 10.5, longitude: 20.5)),
                    Location(coordinate: .init(latitude: 11, longitude: 21)),
                ], proportionOfFirstStepAlreadyAnimated: 0.066, numberOfLocationsPoppedSinceLastCameraUpdate: 2),
                subscriberUpdates: .init(
                    positionToEmit: .init(latitude: 10.533, longitude: 20.533, accuracy: 0, bearing: 0),
                    shouldEmitCameraPositionUpdate: false
                )
            ),
            positionAccuracy: 0.001,
            stepProportionAccuracy: 0.001
        )
    }

    func test_calculate_whenThePredictedTimeToNextLocationUpdateHasPassed_itJustUsesTheIntentionalAnimationDelay() {
        let input = DefaultLocationAnimatorCalculator.Input(
            config: .init(animationStepsBetweenCameraUpdates: 5, intentionalAnimationDelay: 2),
            context: .init(now: 5, nextLocationUpdatePrediction: .init(receivedAt: 1, nextUpdateExpectedIn: 3)),
            state: .init(
                displayLinkLastFiredAt: 4.5,
                locationsAwaitingAnimation: [
                    Location(coordinate: .init(latitude: 10, longitude: 20)),
                    Location(coordinate: .init(latitude: 10.5, longitude: 20.5)),
                    Location(coordinate: .init(latitude: 11, longitude: 21)),
                ],
                proportionOfFirstStepAlreadyAnimated: nil,
                numberOfLocationsPoppedSinceLastCameraUpdate: 1
            )
        )

        let result = DefaultLocationAnimatorCalculator.calculate(input: input)

        /*
         The next location update was expected 1 second ago, so our aim is to animate through all of locationUpdates in intentionalAnimationDelay = 2 seconds.

         It's been 0.5 seconds since the display link last fired. That means that, at this moment, we assume we'll be splitting our animation into 2 / 0.5 = 4 steps.

         That means that each step represents the transition between (3 - 1) / 4 = 0.5 location updates.

         So we want to emit a position that is 0.5 * 100 = 50% of the way between locationUpdates[0] and locationUpdates[1].
         */

        assertEqualResults(
            result,
            .init(
                newState: .init(
                    displayLinkLastFiredAt: 5,
                    locationsAwaitingAnimation: [
                        Location(coordinate: .init(latitude: 10, longitude: 20)),
                        Location(coordinate: .init(latitude: 10.5, longitude: 20.5)),
                        Location(coordinate: .init(latitude: 11, longitude: 21)),
                    ],
                    proportionOfFirstStepAlreadyAnimated: 0.5,
                    numberOfLocationsPoppedSinceLastCameraUpdate: 1
                ),
                subscriberUpdates: .init(
                    positionToEmit: .init(latitude: 10.25, longitude: 20.25, accuracy: 0, bearing: 0),
                    shouldEmitCameraPositionUpdate: false
                )
            )
        )
    }

    func test_calculate_whenNumberOfLocationsPoppedSinceLastCameraUpdateIsNil_andThereIsAPositionToEmit_itEmitsACameraPositionUpdate(
    ) {
        let input = DefaultLocationAnimatorCalculator.Input(
            config: .init(animationStepsBetweenCameraUpdates: 5, intentionalAnimationDelay: 0),
            context: .init(now: 5, nextLocationUpdatePrediction: .init(receivedAt: 2, nextUpdateExpectedIn: 6)),
            state: .init(
                displayLinkLastFiredAt: nil,
                locationsAwaitingAnimation: [
                    Location(coordinate: .init(latitude: 10, longitude: 20)),
                    Location(coordinate: .init(latitude: 10.5, longitude: 20.5)),
                ],
                proportionOfFirstStepAlreadyAnimated: nil,
                numberOfLocationsPoppedSinceLastCameraUpdate: nil
            )
        )

        let result = DefaultLocationAnimatorCalculator.calculate(input: input)

        XCTAssertEqual(result.subscriberUpdates?.shouldEmitCameraPositionUpdate, true)
        XCTAssertEqual(result.newState.numberOfLocationsPoppedSinceLastCameraUpdate, 0)
    }

    func test_calculate_whenNumberOfLocationsPoppedSinceLastCameraUpdateIsOneLessThanAnimationStepsBetweenCameraUpdates_andThereIsALocationToPop_itEmitsACameraPositionUpdate(
    ) {
        let input = DefaultLocationAnimatorCalculator.Input(
            config: .init(
                animationStepsBetweenCameraUpdates: 5,
                intentionalAnimationDelay: 2
            ),
            context: .init(
                now: 5,
                nextLocationUpdatePrediction: .init(
                    receivedAt: 2,
                    nextUpdateExpectedIn: 6
                )
            ),
            state: .init(
                displayLinkLastFiredAt: 1,
                locationsAwaitingAnimation: [
                    Location(coordinate: .init(latitude: 10, longitude: 20)),
                    Location(coordinate: .init(latitude: 10.5, longitude: 20.5)),
                    Location(coordinate: .init(latitude: 11, longitude: 21)),
                ],
                proportionOfFirstStepAlreadyAnimated: nil,
                numberOfLocationsPoppedSinceLastCameraUpdate: 4
            )
        )

        let result = DefaultLocationAnimatorCalculator.calculate(input: input)

        XCTAssertEqual(result.subscriberUpdates?.shouldEmitCameraPositionUpdate, true)
        XCTAssertEqual(result.newState.numberOfLocationsPoppedSinceLastCameraUpdate, 0)
    }
}
