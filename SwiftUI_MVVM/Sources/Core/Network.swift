//
//  Network.swift
//  SwiftUI_MVVM
//
//  Created by havi.log on 2023/10/31.
//

import Foundation
import Dependencies
import XCTestDynamicOverlay

/// `Identifiable`: ForEach 돌릴 때 유용
/// `Sendable`: async context에 넣을 때 유용, 붙여서 성능이나 귀찮음 손해보는 것보다, 안붙였다가 나중에 붙이려고 애먹는게 더 크다고 생각
/// `Equatable`: Testability
struct SomeNetworkModel: Decodable, Identifiable, Sendable, Equatable {
    var id: Int { number }
    let number: Int
}

#if DEBUG
extension SomeNetworkModel {
    static let previewMock: Self = .init(number: 123)
}

extension SomeNetworkModel {
    static let testMock: Self = .init(number: .zero)
}
#endif


/// namespace aka. API
struct Network { }

/// Dependency interface 정의
extension Network {
    struct Home {
        /// preview, test를 위해 의존성 주입해주기 위한 closure
        /// protocol로도 구현 가능하지만, 하비 스타일은 이게 더 편한 듯
        private var list: @Sendable (String) async throws -> [SomeNetworkModel]
        var someAPI: @Sendable () async throws -> Void
        
        init(
            list: @escaping @Sendable (String) async throws -> [SomeNetworkModel],
            someAPI: @escaping @Sendable () async throws -> Void
        ) {
            self.list = list
            self.someAPI = someAPI
        }
        
        /// closure에 아규먼트, 파라미터 이름을 달아주기 위한 래핑 함수
        func list(with parameter: String) async throws -> [SomeNetworkModel] {
            return try await self.list(parameter)
        }
    }
}

/// Dependency 구현부
extension Network.Home: DependencyKey {
    static let liveValue: Network.Home = .init(
        list: { id in
            try await Task.sleep(nanoseconds: NSEC_PER_SEC)
            return [
                .init(number: .random(in: 0...2)),
                .init(number: .random(in: 0...2))
            ]
        },
        someAPI: { print("hi~") }
    )
    
    /// 각 테스트에서 사용하는 함수만 구현
    /// 실제 앱 구현체에서 사용할 경우 run time error
    static let testValue: Network.Home = .init(
        list: unimplemented("\(Self.self).list"),
        someAPI: unimplemented("\(Self.self).someAPI")
    )
    
    /// 프리뷰에서 사용할 목데이터
    static let previewValue: Network.Home = .init(
        list: { _ in return [.previewMock, .previewMock, .previewMock] },
        someAPI: { }
    )
}

/// keyPath로 꺼내올 Dependency 등록
extension DependencyValues {
    var homeAPI: Network.Home {
        get { self[Network.Home.self] }
        set { self[Network.Home.self] = newValue }
    }
}
