//
//  ContentView.swift
//  SwiftUI_MVVM
//
//  Created by havi.log on 2023/10/30.
//

import SwiftUI
import Dependencies

/// `@Observable` macro는... 1년 뒤에 고민 ..
/// `final`, `@MainActor` == default
/// output -> dependency -> init -> input -> private
/// TODO: Input에 대한 interface통일, Output(ViewState), DataStream를 만들지 안만들지는 고민 및 논의 필요
@MainActor
final class CounterViewModel: ObservableObject {
    
    // MARK: Output
    
    @Published private(set) var count: Int = 0
    @Published private(set) var secondsElapsed: Int = 0
    @Published private(set) var timerTask: Task<Void, Error>?
    @Published private(set) var homeList: [SomeNetworkModel] = []

    var isTimerOn: Bool { self.timerTask != nil }
    
    // MARK: Dependencies
    
    @Dependency(\.continuousClock) private var clock
    @Dependency(\.homeAPI) private var homeAPI
    
    // MARK: Input
    
    func onAppear() { } // no-op
    
    func onTask() async {
        try? await homeAPI.someAPI()
    }
    
    func incrementButtonTapped() {
        self.count += 1
    }
    
    func decrementButtonTapped() {
        self.count -= 1
    }
    
    func startTimerButtonTapped() {
        self.timerTask?.cancel()
        self.timerTask = Task { [clock] in
            while true {
                try await clock.sleep(for: .seconds(1))
                // 다른 곳에서 secondsElapsed에 접근한다거나 하면
                // actor data store 같은거 만들어주던가 해야할 듯?
                self.secondsElapsed += 1
                print("secondsElapsed", self.secondsElapsed)
            }
        }
    }
    
    func stopTimerButtonTapped() {
        self.timerTask?.cancel()
        self.timerTask = nil
    }
    
    func networkButtonTapped() async {
        do {
            let homeList = try await homeAPI.list(with: "with some parameter")
            self.homeList = homeList
        }
        catch {
            self.homeList = []
        }
    }
}

extension CounterViewModel: Hashable {
    nonisolated static func == (lhs: CounterViewModel, rhs: CounterViewModel) -> Bool {
        lhs === rhs
    }
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

struct CounterView: View {
    /// `@State`
    ///     - 뷰가 자기 자신의 상태를 가지고 있고, 어떠한 외부적인 관계가 없을 때
    /// `@Binding`
    ///     - 외부에서 단순히 read/write만 바인딩 해주는 간단한 뷰일 때
    ///
    /// `@StateObject`
    ///     - 뷰 자체가 object와 생명주기를 같이 하는 owner일 때
    /// `@ObservedObject`
    ///     - data를 외부에서 주입받는 경우
    @ObservedObject var viewModel: CounterViewModel
    
    /// body에는 웬만하면 bodyView로 빼고
    /// bodyView에 presenting할 view modifier(alert), onAppear 등을 붙이면 좋을 것 같아요
    /// onFirstAppear나 onFirstTask를 쓸 때에는 View의 structural identity를 잘 고려해서 두 번 안 불리도록.
    var body: some View {
        let _ = Self._printChanges()
        bodyView
            .onAppear { viewModel.onAppear() }
            .task { await viewModel.onTask() }
    }
    
    private var bodyView: some View {
        Form {
            counterSection
            timerSection
            networkSection
        }
    }
    /// 2뎁스 이상의 뷰들은 private property로 빼면 좋을 것 같아요
    private var counterSection: some View {
        Section {
            Text("\(viewModel.count)")
            Button { viewModel.incrementButtonTapped() } label: {
                Text("increment")
            }
            Button { viewModel.decrementButtonTapped() } label: {
                Text("decrement")
            }
        } header: {
            Text("counter")
        }
    }
    
    private var timerSection: some View {
        Section {
            Text("Seconds elapsed: \(self.viewModel.secondsElapsed)")
            timerButton
        } header: {
            Text("Timer")
        }
    }
    
    @ViewBuilder
    private var timerButton: some View {
        if viewModel.isTimerOn == false {
            Button { viewModel.startTimerButtonTapped() } label: {
                Text("Start Timer")
            }
        } else {
            Button { viewModel.stopTimerButtonTapped() } label: {
                HStack {
                    Text("Stop Timer")
                    Spacer()
                    ProgressView().id(UUID()) // id 안주면 버그 있음
                }
            }
        }
    }
    
    private var networkSection: some View {
        Section {
            /// Task의 생명주기를 관리 안해도 될 경우
            /// ViewModel에서 structed concurrency를 사용할 수 있게
            /// 뷰에서 Task를 주도록
            Button {
                Task { await viewModel.networkButtonTapped() }
            } label: {
                Text("Network")
            }
            
            ForEach(viewModel.homeList) { model in
                Text("\(model.number)")
            }
        }
    }
}

/// 프리뷰 간단해진거 기가 맥히네
#Preview { CounterView(viewModel: .init()) }
