//
//  ParentViewModelTests.swift
//  SwiftUI_MVVMTests
//
//  Created by havi.log on 2023/11/01.
//

@testable import SwiftUI_MVVM
import XCTest
import CasePaths

@MainActor
final class ParentViewModelTests: XCTestCase {
    
    private var sut: ParentViewModel!

    override func setUpWithError() throws {
        sut = .init()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func test_presentAlertButtonTapped() async throws {
        sut.presentAlertButtonTapped(with: "이것은 알럿입니다.")
        let alert = try XCTUnwrap(
            sut.destination,
            case: /ParentViewModel.Destination.alert
        )
        XCTAssertEqual(alert.title, "이것은 알럿입니다.")
    }
    
    func test_presentSheetButtonTapped() async throws {
        sut.presentSheetButtonTapped(with: "이것은 바텀시트입니다.")
        let alert = try XCTUnwrap(
            sut.destination,
            case: /ParentViewModel.Destination.sheet
        )
        XCTAssertEqual(alert.title, "이것은 바텀시트입니다.")
    }
}

@MainActor
final class ParentNavigationViewModelTests: XCTestCase {
    
    private var sut: ParentNavigationViewModel!

    override func setUpWithError() throws {
        sut = .init(parentViewModel: ParentViewModel())
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func test_pushToDetail() async throws {
        let parentViewModel = ParentViewModel()
        sut = .init(parentViewModel: parentViewModel)
        parentViewModel.detailButtonTapped()
        XCTAssertEqual(sut.path.count, 1)
        let detailViewModel = try XCTUnwrap(
            sut.path[.zero],
            case: /ParentNavigationViewModel.Destination.detailChild
        )
        XCTAssertEqual(sut.path, [.detailChild(detailViewModel)])
    }
    
    func test_pushTwoDepth() async throws {
        let parentViewModel = ParentViewModel()
        sut = .init(parentViewModel: parentViewModel)
        
        parentViewModel.detailButtonTapped()
        XCTAssertEqual(sut.path.count, 1)
        let detailViewModel = try XCTUnwrap(
            sut.path[.zero],
            case: /ParentNavigationViewModel.Destination.detailChild
        )
        XCTAssertEqual(sut.path, [.detailChild(detailViewModel)])
        
        detailViewModel.onTwoDepthButtonTapped()
        XCTAssertEqual(sut.path.count, 2)
        XCTAssertEqual(sut.path, [.detailChild(detailViewModel), .twoDepthChild])
    }
}
