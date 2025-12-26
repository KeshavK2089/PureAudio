//
//  SubscriptionView.swift
//  AudioPure
//
//  Premium Paywall UI with glassmorphism styling
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var storeKit = StoreKitManager.shared
    
    @State private var selectedPlan: PlanType = .monthly
    @State private var isPurchasing = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var animateGradient = false
    
    enum PlanType: String, CaseIterable {
        case monthly = "Monthly"
        case yearly = "Yearly"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated gradient background
                AnimatedPremiumBackground(animate: $animateGradient)
                
                ScrollView {
                    VStack(spacing: 28) {
                        // Premium Header
                        premiumHeaderSection
                        
                        // Plan toggle with premium styling
                        premiumPlanToggle
                        
                        // Subscription options
                        if storeKit.isLoading {
                            loadingView
                        } else if storeKit.products.isEmpty {
                            noProductsView
                        } else {
                            premiumSubscriptionCards
                        }
                        
                        // Features comparison
                        premiumFeaturesSection
                        
                        // Restore purchases
                        restoreButton
                        
                        // Terms
                        termsSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Go Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.7))
                            .font(.title3)
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .disabled(isPurchasing)
            .overlay {
                if isPurchasing {
                    purchasingOverlay
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }
    
    // MARK: - Premium Header
    
    private var premiumHeaderSection: some View {
        VStack(spacing: 16) {
            // Animated crown with glow
            ZStack {
                // Glow effect
                Image(systemName: "crown.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blur(radius: 20)
                    .opacity(0.6)
                
                // Main crown
                Image(systemName: "crown.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .orange.opacity(0.5), radius: 10, x: 0, y: 5)
            }
            
            VStack(spacing: 8) {
                Text("Unlock AudioPure Pro")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Professional audio processing, unlimited creativity")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Premium Plan Toggle
    
    private var premiumPlanToggle: some View {
        HStack(spacing: 0) {
            ForEach(PlanType.allCases, id: \.self) { plan in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedPlan = plan
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text(plan.rawValue)
                            .font(.headline)
                        if plan == .yearly {
                            Text("Save 25%")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    }
                    .foregroundColor(selectedPlan == plan ? .white : .white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedPlan == plan ?
                        LinearGradient(colors: [.primaryPurple, .accentPink], startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(colors: [.clear, .clear], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(12)
                }
            }
        }
        .padding(4)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    // MARK: - Premium Subscription Cards
    
    private var premiumSubscriptionCards: some View {
        VStack(spacing: 16) {
            ForEach(currentProducts, id: \.id) { product in
                PremiumSubscriptionCard(
                    product: product,
                    isPopular: product.id.contains("pro"),
                    onPurchase: { purchaseProduct(product) }
                )
            }
        }
        .padding(.horizontal)
    }
    
    private var currentProducts: [Product] {
        selectedPlan == .monthly ? storeKit.monthlyProducts() : storeKit.yearlyProducts()
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.2)
            Text("Loading plans...")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 40)
    }
    
    // MARK: - No Products View
    
    private var noProductsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.yellow)
            
            Text("Subscriptions not available")
                .font(.headline)
                .foregroundColor(.white)
            
            if let error = storeKit.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            } else {
                Text("Products are pending App Store review.\nTest via TestFlight with a sandbox account.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            
            Button {
                Task { await storeKit.loadProducts() }
            } label: {
                Text("Retry")
                    .font(.headline)
                    .foregroundColor(.primaryPurple)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 40)
    }
    
    // MARK: - Premium Features Section
    
    private var premiumFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Compare Plans")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 0) {
                // Header row
                HStack {
                    Text("Feature")
                        .frame(width: 90, alignment: .leading)
                    Spacer()
                    Text("Free").frame(width: 45)
                    Text("Basic").frame(width: 45)
                    Text("Pro").frame(width: 45)
                        .foregroundColor(.accentPink)
                    Text("Max").frame(width: 45)
                }
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.8))
                .padding(.bottom, 12)
                
                Divider().background(.white.opacity(0.2))
                
                // Feature rows
                PremiumFeatureRow(feature: "Processes", free: "2", basic: "5", pro: "20", unlimited: "50")
                PremiumFeatureRow(feature: "Max length", free: "15s", basic: "30s", pro: "60s", unlimited: "2min")
                PremiumFeatureRow(feature: "Watermark", free: "Yes", basic: "No", pro: "No", unlimited: "No")
                PremiumFeatureRow(feature: "Priority", free: "—", basic: "—", pro: "✓", unlimited: "VIP")
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Restore Button
    
    private var restoreButton: some View {
        Button {
            Task {
                isPurchasing = true
                await storeKit.restorePurchases()
                isPurchasing = false
                if storeKit.hasActiveSubscription {
                    dismiss()
                }
            }
        } label: {
            HStack {
                Image(systemName: "arrow.clockwise")
                Text("Restore Purchases")
            }
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - Terms Section
    
    private var termsSection: some View {
        VStack(spacing: 8) {
            Text("Subscription auto-renews unless cancelled 24 hours before end of period. Cancel anytime in Settings.")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                Link("Terms", destination: URL(string: "https://keshavk2089.github.io/PureAudio/terms.html")!)
                Link("Privacy", destination: URL(string: "https://keshavk2089.github.io/PureAudio/privacy.html")!)
            }
            .font(.caption2)
            .foregroundColor(.white.opacity(0.6))
        }
        .padding()
    }
    
    // MARK: - Purchasing Overlay
    
    private var purchasingOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.3)
                Text("Processing...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(32)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
        }
    }
    
    // MARK: - Actions
    
    private func purchaseProduct(_ product: Product) {
        Task {
            isPurchasing = true
            do {
                if let _ = try await storeKit.purchase(product) {
                    dismiss()
                }
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
            isPurchasing = false
        }
    }
}

// MARK: - Animated Premium Background

struct AnimatedPremiumBackground: View {
    @Binding var animate: Bool
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.1, green: 0.05, blue: 0.2),
                Color(red: 0.2, green: 0.1, blue: 0.4),
                Color(red: 0.1, green: 0.05, blue: 0.3)
            ],
            startPoint: animate ? .topLeading : .bottomTrailing,
            endPoint: animate ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea()
        .overlay(
            // Floating orbs
            ZStack {
                Circle()
                    .fill(.purple.opacity(0.3))
                    .frame(width: 200, height: 200)
                    .blur(radius: 60)
                    .offset(x: animate ? 100 : -100, y: animate ? -150 : 150)
                
                Circle()
                    .fill(.pink.opacity(0.2))
                    .frame(width: 150, height: 150)
                    .blur(radius: 50)
                    .offset(x: animate ? -80 : 80, y: animate ? 200 : -100)
                
                Circle()
                    .fill(.blue.opacity(0.2))
                    .frame(width: 180, height: 180)
                    .blur(radius: 55)
                    .offset(x: animate ? 50 : -50, y: animate ? 100 : -200)
            }
        )
    }
}

// MARK: - Premium Subscription Card

struct PremiumSubscriptionCard: View {
    let product: Product
    let isPopular: Bool
    let onPurchase: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Popular badge
            if isPopular {
                HStack {
                    Spacer()
                    Text("MOST POPULAR")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                    Spacer()
                }
                .offset(y: -8)
            }
            
            // Tier name with icon
            HStack {
                Image(systemName: tierIcon)
                    .font(.title2)
                    .foregroundStyle(tierGradient)
                Text(tierName)
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
            
            // Features
            VStack(spacing: 8) {
                ForEach(tierFeatures, id: \.self) { feature in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text(feature)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                    }
                }
            }
            
            Divider().background(.white.opacity(0.2))
            
            // Price
            VStack(spacing: 4) {
                Text(product.displayPrice)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(periodText)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Trial info
            if let trial = product.subscription?.introductoryOffer {
                Text("Start with \(trial.period.value) \(trial.period.unit.localizedDescription) free")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.green.opacity(0.2))
                    .cornerRadius(8)
            }
            
            // Subscribe button
            Button(action: onPurchase) {
                Text(isPopular ? "Start Free Trial" : "Subscribe")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: isPopular ? [.orange, .pink] : [.primaryPurple, .accentPink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: isPopular ? .orange.opacity(0.4) : .purple.opacity(0.4), radius: 10, x: 0, y: 5)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isPopular ?
                            LinearGradient(colors: [.orange.opacity(0.5), .pink.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                            LinearGradient(colors: [.white.opacity(0.2), .white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: isPopular ? 2 : 1
                        )
                )
        )
        .scaleEffect(isPopular ? 1.02 : 1.0)
    }
    
    private var tierName: String {
        if product.id.contains("basic") { return "Basic" }
        if product.id.contains("pro") { return "Pro" }
        if product.id.contains("unlimited") { return "Unlimited" }
        return "Premium"
    }
    
    private var tierIcon: String {
        if product.id.contains("basic") { return "star" }
        if product.id.contains("pro") { return "star.fill" }
        if product.id.contains("unlimited") { return "sparkles" }
        return "crown"
    }
    
    private var tierGradient: LinearGradient {
        if product.id.contains("basic") {
            return LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        if product.id.contains("pro") {
            return LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        if product.id.contains("unlimited") {
            return LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        return LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    private var tierFeatures: [String] {
        if product.id.contains("basic") {
            return ["5 audio processes/month", "Up to 30 second clips", "No watermark"]
        } else if product.id.contains("pro") {
            return ["20 audio processes/month", "Up to 60 second clips", "Priority processing"]
        } else if product.id.contains("unlimited") {
            return ["50 audio processes/month", "Up to 2 minute clips", "VIP priority"]
        }
        return []
    }
    
    private var periodText: String {
        product.id.contains("yearly") ? "per year" : "per month"
    }
}

// MARK: - Premium Feature Row

struct PremiumFeatureRow: View {
    let feature: String
    let free: String
    let basic: String
    let pro: String
    let unlimited: String
    
    var body: some View {
        HStack {
            Text(feature)
                .frame(width: 90, alignment: .leading)
            Spacer()
            Text(free).frame(width: 45)
            Text(basic).frame(width: 45)
            Text(pro).frame(width: 45)
                .foregroundColor(.accentPink)
            Text(unlimited).frame(width: 45)
        }
        .font(.caption)
        .foregroundColor(.white.opacity(0.7))
        .padding(.vertical, 8)
    }
}

#Preview {
    SubscriptionView()
}
