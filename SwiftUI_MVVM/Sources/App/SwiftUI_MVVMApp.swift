//
//  SwiftUI_MVVMApp.swift
//  SwiftUI_MVVM
//
//  Created by havi.log on 2023/10/30.
//

import SwiftUI

@main
struct SwiftUI_MVVMApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(
                viewModel: RootViewModel(tab: .counter, counterViewModel: .init(), parentViewModel: .init(parentViewModel: .init()))
            )
        }
    }
}
