// Presentation/Views/DuoChallengeView.swift
import SwiftUI

struct DuoChallengeView: View {
    @StateObject var viewModel = DuoChallengeViewModel()
    var challengeId: String
    
    @State private var created: Bool = false
    @State private var joinCode: String = ""
    @State private var joinSuccess: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if created {
                    VStack(spacing: 8) {
                        Text("듀오 챌린지가 생성되었습니다!")
                            .font(.headline)
                        Text("초대 코드: \(viewModel.inviteCode)")
                            .font(.subheadline)
                        Text("친구에게 초대 코드를 전달하세요.")
                            .font(.caption)
                    }
                    
                    Divider()
                    
                    VStack(spacing: 16) {
                        TextField("초대 코드 입력", text: $joinCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        Button(action: {
                            viewModel.joinDuoChallenge(withCode: joinCode) { success in
                                if success {
                                    joinSuccess = true
                                }
                            }
                        }) {
                            Text("듀오 챌린지 참여")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        if joinSuccess {
                            Text("듀오 챌린지에 성공적으로 참여했습니다!")
                                .foregroundColor(.green)
                        }
                    }
                } else {
                    Button(action: {
                        viewModel.createDuoChallenge(for: challengeId) { success in
                            if success {
                                created = true
                            }
                        }
                    }) {
                        Text("듀오 챌린지 생성")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("듀오 챌린지")
        }
    }
}

struct DuoChallengeView_Previews: PreviewProvider {
    static var previews: some View {
        DuoChallengeView(challengeId: "exampleChallengeId")
    }
}
