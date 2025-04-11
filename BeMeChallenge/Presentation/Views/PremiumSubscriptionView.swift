// PremiumSubscriptionView.swift
import SwiftUI
import StoreKit

struct PremiumSubscriptionView: View {
    @StateObject var subscriptionManager = PremiumSubscriptionManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if subscriptionManager.purchased {
                    Text("Premium 구독이 활성화되었습니다!")
                        .foregroundColor(.green)
                        .font(.headline)
                } else {
                    Text("Premium 구독을 통해 추가 기능을 이용해보세요.")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    List(subscriptionManager.products, id: \.id) { product in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.displayName)
                                .font(.headline)
                            Text(product.description)
                                .font(.subheadline)
                        }
                        .onTapGesture {
                            Task {
                                await subscriptionManager.purchase(product)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                if let error = subscriptionManager.errorMessage {
                    Text("에러: \(error)")
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
            .navigationTitle("Premium 구독")
            .padding()
        }
    }
}

struct PremiumSubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        PremiumSubscriptionView()
    }
}
