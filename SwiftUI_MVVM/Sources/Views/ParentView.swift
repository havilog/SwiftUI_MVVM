//
//  ParentView.swift
//  SwiftUI_MVVM
//
//  Created by havi.log on 2023/10/31.
//

import SwiftUI
import XCTestDynamicOverlay

/// 기존에는 뷰에서 정의해주던 알럿 컨피규레이션을 뷰모델의 상태로 가지고 있게 함으로써 테스트 가능하게 하도록
struct AlertState: Equatable, Identifiable {
    let id: UUID = .init()
    let title: String
    // configurations
}

@MainActor
final class ParentViewModel: ObservableObject {
    
    @Published var destination: Destination?
    
    /// 해당 뷰가 Present할 수 있는 상태는 1개이기 때문에, enum으로 관리하도록
    ///
    /// e.g.
    /// presenting하는 상태값이 많아질 수록 관리하기 힘들어짐
    /// 알럿과 바텀시트는 동시에 뜰 수 없음
    /// 에러 알럿과 정보성 알럿도 동시에 뜰 수 없음
    /// ```swift
    /// @Published var alert: AlertState?
    /// @Published var sheet: SheetState?
    /// @Published var some: SomeState?
    /// @Published var error: ErrorState?
    /// ```
    enum Destination {
        case alert(AlertState)
        case sheet(SheetViewModel)
    }
    
    /// `unimplemented`
    /// 반드시 구현해줘야하는 closure의 경우, initialize injection을 해줘야하는 귀찮음을 해소할 수 있다.
    /// 테스트를 짤 경우, 테스트 되어야하지 않을 closure를 정의할 수 있다.
    /// 실행되면 안되거나, 주입되지 않은 closure의 경우 run time error를 발생시킨다.
    var onDetailButtonTapped: () -> Void = unimplemented("ParentViewModel.onDetailButtonTapped")

    /// push를 할 경우 Navigation을 관리하는 뷰에게 delegate를 쏘도록
    func detailButtonTapped() {
        self.onDetailButtonTapped()
    }
    
    func presentAlertButtonTapped(with title: String) {
        self.destination = .alert(AlertState(title: title))
    }
    
    func presentSheetButtonTapped(with title: String) {
        self.destination = .sheet(SheetViewModel(title: title))
    }
}

struct ParentView: View {
    @ObservedObject var viewModel: ParentViewModel
    
    var body: some View {
        bodyView
            .navigationTitle("Parent")
            // Binding<SheetViewModel?>
            .sheet(
                item: $viewModel.destination.case(/ParentViewModel.Destination.sheet),
                content: { sheetViewModel in
                    Text(sheetViewModel.id)
                        .presentationDetents([.height(500)])
                }
            )
            // Binding<AlertState?>
            .alert(
                item: $viewModel.destination.case(/ParentViewModel.Destination.alert),
                content: { alertState in
                    Alert(title: Text(alertState.title))
                }
            )
//            .fitAlert(
//                item: $viewModel.destination.case(/ParentViewModel.Destination.alert),
//                alert: { alertState in
//                    /// alertView
//                }
//            )
    }
    
    private var bodyView: some View {
        Form {
            Button {
                viewModel.detailButtonTapped()
            } label: {
                Text("Push to Detail")
            }
            
            Button {
                viewModel.presentAlertButtonTapped(with: "이것은 알럿입니다.")
            } label: {
                Text("Present Alert")
            }
            
            Button {
                viewModel.presentSheetButtonTapped(with: "이것은 바텀시트입니다.")
            } label: {
                Text("Present Sheet")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ParentView(viewModel: .init())
    }
}

import CasePaths

extension Binding {
    public func `case`<Enum, Case>(_ casePath: CasePath<Enum, Case>) -> Binding<Case?> where Value == Enum? {
        .init(
            get: { self.wrappedValue.flatMap(casePath.extract(from:)) },
            set: { newValue, transaction in
                self.transaction(transaction).wrappedValue = newValue.map(casePath.embed)
            }
        )
    }
}
