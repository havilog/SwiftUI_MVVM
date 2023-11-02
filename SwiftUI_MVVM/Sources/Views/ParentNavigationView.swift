//
//  ParentNavigationView.swift
//  SwiftUI_MVVM
//
//  Created by havi.log on 2023/10/31.
//

import SwiftUI

@MainActor
final class ParentNavigationViewModel: ObservableObject {
    @Published var path: [Destination] { didSet { bind() } }
    @Published var parentViewModel: ParentViewModel { didSet { bind() } }
    
    enum Destination: Hashable {
        case detailChild(DetailChildViewModel)
        case twoDepthChild
    }
    
    init(
        path: [Destination] = [],
        parentViewModel: ParentViewModel
    ) {
        self.path = path
        self.parentViewModel = parentViewModel
        /// didSet은 initial시점에 안불려서 한 번 찔러줘야함
        bind()
    }
    
    private func bind() {
        self.parentViewModel.onDetailButtonTapped = { [weak self] in
            self?.path.append(.detailChild(.init()))
        }
        
        for destination in self.path {
            switch destination {
            case let .detailChild(detailChildViewModel):
                detailChildViewModel.onTwoDepthButtonTapped = { [weak self] in
                    self?.path.append(.twoDepthChild)
                }
                
            case .twoDepthChild:
                break
            }
        }
    }
}

/// Destination에 들어가려면 Hashable해야함
extension ParentNavigationViewModel: Hashable {
    nonisolated static func == (lhs: ParentNavigationViewModel, rhs: ParentNavigationViewModel) -> Bool {
        lhs === rhs
    }
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

struct ParentNavigationView: View {
    @ObservedObject var viewModel: ParentNavigationViewModel
    
    var body: some View {
        /// NavigationLink는 버그 있어서 쓰면 안 됨
        /// Stack을 뷰모델에서 배열로 관리하도록
        NavigationStack(path: self.$viewModel.path) {
            ParentView(viewModel: viewModel.parentViewModel)
                .navigationDestination(for: ParentNavigationViewModel.Destination.self) { destination in
                    switch destination {
                    case let .detailChild(viewModel):
                        DetailChildView(viewModel: viewModel)
                        
                    case .twoDepthChild:
                        TwoDepthChildView()
                    }
                }
        }
    }
}

#Preview {
    ParentNavigationView(viewModel: .init(path: [], parentViewModel: .init()))
}
