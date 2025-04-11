// PremiumSubscriptionManager.swift
import Foundation
import StoreKit
import FirebaseFirestore
import FirebaseAuth

@MainActor
class PremiumSubscriptionManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchased: Bool = false
    @Published var errorMessage: String?
    
    private let productIDs: Set<String> = ["com.bemechallenge.premium"] // 실제 제품 ID로 교체
    
    init() {
        Task {
            await fetchProducts()
            await updateCustomerProductStatus()
        }
    }
    
    /// 제품 정보를 가져옵니다.
    func fetchProducts() async {
        do {
            products = try await Product.products(for: Array(productIDs))
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// 제품 구매를 시작합니다.
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            // 처리 결과: .success, .userCancelled, .pending 등
            if case .success(let verificationResult) = result {
                let transaction = try checkVerified(verificationResult)
                // 구매 성공 시, 프리미엄 상태 갱신 및 Firestore 업데이트
                purchased = true
                await updatePremiumStatusInFirestore(isPremium: true)
                await transaction.finish()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Transaction 검증 및 반환
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let signedType):
            return signedType
        }
    }
    
    /// 현재 사용자의 구매 내역을 확인하여 프리미엄 상태를 업데이트합니다.
    func updateCustomerProductStatus() async {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if productIDs.contains(transaction.productID) {
                    purchased = true
                    await updatePremiumStatusInFirestore(isPremium: true)
                    break
                }
            } catch {
                print("Transaction verification error: \(error)")
            }
        }
    }
    
    /// Firestore에서 해당 사용자 도큐먼트의 프리미엄 플래그를 업데이트합니다.
    private func updatePremiumStatusInFirestore(isPremium: Bool) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        do {
            try await db.collection("users").document(userId).updateData(["isPremium": isPremium])
        } catch {
            print("Failed to update premium status: \(error.localizedDescription)")
        }
    }
}
