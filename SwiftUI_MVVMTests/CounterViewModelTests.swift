//
//  SwiftUI_MVVMTests.swift
//  SwiftUI_MVVMTests
//
//  Created by havi.log on 2023/10/30.
//

@testable import SwiftUI_MVVM
import XCTest
import Dependencies

@MainActor
final class CounterViewModelTests: XCTestCase {
    
    private var sut: CounterViewModel!

    override func setUpWithError() throws {
        sut = .init()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func test_incrementButtonTapped() throws {
        XCTAssertEqual(sut.count, .zero)
        sut.incrementButtonTapped()
        sut.incrementButtonTapped()
        XCTAssertEqual(sut.count, 2)
    }
    
    func test_decrementButtonTapped() throws {
        XCTAssertEqual(sut.count, .zero)
        sut.decrementButtonTapped()
        sut.decrementButtonTapped()
        XCTAssertEqual(sut.count, -2)
    }
    
    func test_decrement_and_increment() throws {
        XCTAssertEqual(sut.count, .zero)
        sut.decrementButtonTapped()
        sut.decrementButtonTapped()
        XCTAssertEqual(sut.count, -2)
        sut.incrementButtonTapped()
        sut.incrementButtonTapped()
        sut.incrementButtonTapped()
        sut.incrementButtonTapped()
        XCTAssertEqual(sut.count, 2)
        sut.incrementButtonTapped()
        sut.incrementButtonTapped()
        sut.incrementButtonTapped()
        XCTAssertEqual(sut.count, 5)
    }
    
    func test_timer() async {
        let clock = TestClock()
        sut = withDependencies {
            $0.continuousClock = clock
        } operation: {
            CounterViewModel()
        }
        XCTAssertEqual(sut.isTimerOn, false)
        XCTAssertEqual(sut.secondsElapsed, .zero)
        sut.startTimerButtonTapped()
        sut.startTimerButtonTapped()
        sut.startTimerButtonTapped()
        XCTAssertEqual(sut.isTimerOn, true)
        await clock.advance(by: .seconds(1))
        sut.stopTimerButtonTapped()
        XCTAssertEqual(sut.secondsElapsed, 1)
        XCTAssertEqual(sut.isTimerOn, false)
    }
    
    func test_network() async {
        sut = withDependencies {
            $0.homeAPI = .init(
                list: { _ in return [.testMock] },
                someAPI: { }
            )
        } operation: {
            CounterViewModel()
        }
        
        XCTAssertEqual(sut.homeList, [])
        await sut.networkButtonTapped()
        
        XCTAssertEqual(sut.homeList.count, 1)
        guard let result = sut.homeList.first else { XCTFail(); return }
        XCTAssertEqual(result.number, .zero)
    }
}
