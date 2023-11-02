//
//  DetailChildView.swift
//  SwiftUI_MVVM
//
//  Created by havi.log on 2023/10/31.
//

import SwiftUI
import XCTestDynamicOverlay

@MainActor
final class DetailChildViewModel: ObservableObject {
    var onTwoDepthButtonTapped: () -> Void = unimplemented("DetailChildViewModel.onTwoDepthButtonTapped")
}

extension DetailChildViewModel: Hashable {
    nonisolated static func == (lhs: DetailChildViewModel, rhs: DetailChildViewModel) -> Bool {
        lhs === rhs
    }
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

struct DetailChildView: View {
    @ObservedObject var viewModel: DetailChildViewModel
    
    var body: some View {
        Button {
            viewModel.onTwoDepthButtonTapped()
        } label: {
            Text("push 2 Depth")
        }
    }
}

struct TwoDepthChildView: View {
    var body: some View {
        Text("Two Depth")
    }
}

#Preview {
    DetailChildView(viewModel: .init())
}
