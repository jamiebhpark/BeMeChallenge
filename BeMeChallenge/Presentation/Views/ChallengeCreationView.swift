// ChallengeCreationView.swift
import SwiftUI

struct ChallengeCreationView: View {
    @StateObject var viewModel = ChallengeCreationViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("챌린지 정보")) {
                    TextField("챌린지 제목", text: $viewModel.title)
                        .autocapitalization(.none)
                    TextField("챌린지 설명", text: $viewModel.description)
                        .autocapitalization(.none)
                    Picker("챌린지 유형", selection: $viewModel.type) {
                        Text("필수").tag("필수")
                        Text("오픈").tag("오픈")
                    }
                    DatePicker("종료 날짜", selection: $viewModel.endDate, displayedComponents: .date)
                }
                
                Section {
                    Button("챌린지 생성") {
                        viewModel.createChallenge { success in
                            if success {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
            }
            .navigationTitle("챌린지 생성")
            .alert(item: $viewModel.errorMessage) { errorMsg in
                Alert(title: Text("에러"), message: Text(errorMsg), dismissButton: .default(Text("확인")))
            }
        }
    }
}

struct ChallengeCreationView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengeCreationView()
    }
}
