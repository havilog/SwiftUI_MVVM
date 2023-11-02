//
//  MainView.swift
//  SwiftUI_MVVM
//
//  Created by havi.log on 2023/10/30.
//

import SwiftUI

@MainActor
final class RootViewModel: ObservableObject {
    
    @Published var tab: Tab
    var counterViewModel: CounterViewModel
    var parentViewModel: ParentNavigationViewModel
    
    enum Tab: Hashable {
        case counter
        case parent
    }
    
    init(
        tab: Tab,
        counterViewModel: CounterViewModel,
        parentViewModel: ParentNavigationViewModel
    ) {
        self.tab = tab
        self.counterViewModel = counterViewModel
        self.parentViewModel = parentViewModel
    }
}

struct RootView: View {
    @ObservedObject var viewModel: RootViewModel
    
    var body: some View {
        bodyView
    }
    
    private var bodyView: some View {
        TabView(selection: self.$viewModel.tab) {
            counterView
            parentView
        }
    }
    
    private var counterView: some View {
        CounterView(viewModel: viewModel.counterViewModel)
            .tag(RootViewModel.Tab.counter)
            .tabItem {
                Image(systemName: "1.square.fill")
                Text("Counter")
            }
    }
    
    private var parentView: some View {
        ParentNavigationView(viewModel: viewModel.parentViewModel)
            .tag(RootViewModel.Tab.parent)
            .tabItem {
                Image(systemName: "2.square.fill")
                Text("Parent")
            }
    }
}
