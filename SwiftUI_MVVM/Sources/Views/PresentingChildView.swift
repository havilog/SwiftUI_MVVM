//
//  PresentingChildView.swift
//  SwiftUI_MVVM
//
//  Created by havi.log on 2023/10/31.
//

import SwiftUI
import XCTestDynamicOverlay

struct SomeChildModel { }

@MainActor
final class SheetViewModel: ObservableObject, Identifiable {
    private let onSomeButtonTapped: (String) -> Void = unimplemented("SheetViewModel.onSomeButtonTapped")
    
    nonisolated var id: String { title }
    let title: String
    
    init(title: String) {
        self.title = title
    }

    func someButtonTapped(model: String) {
        onSomeButtonTapped(model)
    }
}

@MainActor
final class ChildViewModel1: ObservableObject {
    private let someDelegate: (SomeChildModel) -> Void
    
    /// `NOTE2`
    /// Is this the best way to communicate?
    /// It's so annoying when there's a lot of closures
    init(
        someDelegate: @escaping @Sendable (SomeChildModel) -> Void
    ) {
        self.someDelegate = someDelegate
    }
    
    /// `NOTE3`
    /// and I think this way is ambiguous to define input
    func someButtonTapped(model: SomeChildModel) {
        someDelegate(model)
    }
}

final class ChildViewModel2: ObservableObject {
    private let model: SomeChildModel
    private let someDelegate2: (String) -> Void
    
    init(
        with model: SomeChildModel,
        someDelegate2: @escaping @Sendable (String) -> Void
    ) {
        self.model = model
        self.someDelegate2 = someDelegate2
    }
}

struct ChildView1: View {
    @ObservedObject var viewModel: ChildViewModel2
    
    var body: some View {
        Text("child1")
    }
}

struct ChildView2: View {
    var body: some View {
        Text("child2")
    }
}


#Preview {
    ChildView2()
}
