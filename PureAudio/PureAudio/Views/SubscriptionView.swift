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
    
    @State private var isPurchasing = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var animateGradient = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated gradient background
                AnimatedPremiumBackground(animate: $animateGradient)
                
                ScrollView {
                    VStack(spacing: 28) {
                        // Premium Header
                        premiumHeaderSection
                        
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
            // Professional waveform icon
            ZStack {
                // Glow effect
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.primaryBlue, .skyBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blur(radius: 20)
                    .opacity(0.5)
                
                // Main icon
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.primaryBlue, .skyBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .primaryBlue.opacity(0.4), radius: 10, x: 0, y: 5)
            }
            
            VStack(spacing: 8) {
                Text("AudioPure Pro")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(.white)
                
                Text("Professional audio processing for creators")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 20)
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
        storeKit.monthlyProducts()  // Monthly subscriptions only
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
                PremiumFeatureRow(feature: "Processes", free: "3", basic: "10/mo", pro: "30/mo", unlimited: "∞")
                PremiumFeatureRow(feature: "Max length", free: "15s", basic: "1min", pro: "2.5min", unlimited: "5min")
                PremiumFeatureRow(feature: "High Quality", free: "—", basic: "—", pro: "✓", unlimited: "✓")
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
        VStack(spacing: 12) {
            // Subscription disclosure - required by Apple Guideline 3.1.2
            VStack(spacing: 6) {
                Text("Subscription Terms")
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.7))
                
                Text("• Subscriptions are billed monthly to your Apple ID")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
                
                Text("• Payment will be charged at confirmation of purchase")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
                
                Text("• Subscription auto-renews unless cancelled at least 24 hours before the end of the current period")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
                
                Text("• Manage subscriptions in Settings > Apple ID > Subscriptions")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            
            // Terms and Privacy links - required by Apple Guideline 3.1.2
            HStack(spacing: 20) {
                Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                    Text("Terms of Use (EULA)")
                        .font(.caption)
                        .underline()
                }
                
                Link(destination: URL(string: "https://www.audiopure.app/privacy.html")!) {
                    Text("Privacy Policy")
                        .font(.caption)
                        .underline()
                }
            }
            .foregroundColor(.white.opacity(0.7))
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
                Color(red: 0.02, green: 0.08, blue: 0.15),
                Color(red: 0.05, green: 0.12, blue: 0.22),
                Color(red: 0.03, green: 0.10, blue: 0.18)
            ],
            startPoint: animate ? .topLeading : .bottomTrailing,
            endPoint: animate ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea()
        .overlay(
            // Floating orbs - blue theme
            ZStack {
                Circle()
                    .fill(Color.primaryBlue.opacity(0.25))
                    .frame(width: 200, height: 200)
                    .blur(radius: 60)
                    .offset(x: animate ? 100 : -100, y: animate ? -150 : 150)
                
                Circle()
                    .fill(Color.skyBlue.opacity(0.2))
                    .frame(width: 150, height: 150)
                    .blur(radius: 50)
                    .offset(x: animate ? -80 : 80, y: animate ? 200 : -100)
                
                Circle()
                    .fill(Color.primaryBlue.opacity(0.15))
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
            // Recommended badge
            if isPopular {
                HStack {
                    Spacer()
                    Text("RECOMMENDED")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: [.primaryBlue, .skyBlue],
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
            
            // Subscription details - required by Apple Guideline 3.1.2
            VStack(spacing: 4) {
                Text(product.displayName)
                    .font(.subheadline.bold())
                    .foregroundColor(.white.opacity(0.8))
                
                Text(product.displayPrice)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(subscriptionPeriodText)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Subscribe button
            Button(action: onPurchase) {
                Text("Subscribe")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.primaryBlue, .skyBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                    .shadow(color: .primaryBlue.opacity(0.4), radius: 10, x: 0, y: 5)
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
                            LinearGradient(colors: [.primaryBlue.opacity(0.6), .skyBlue.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing) :
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
        if product.id.contains("basic") { return "waveform" }
        if product.id.contains("pro") { return "waveform.badge.plus" }
        if product.id.contains("unlimited") { return "waveform.badge.magnifyingglass" }
        return "waveform.circle"
    }
    
    private var tierGradient: LinearGradient {
        if product.id.contains("basic") {
            return LinearGradient(colors: [.skyBlue, .primaryBlue], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        if product.id.contains("pro") {
            return LinearGradient(colors: [.primaryBlue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        if product.id.contains("unlimited") {
            return LinearGradient(colors: [.indigo, .deepPurple], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        return LinearGradient(colors: [.primaryBlue, .skyBlue], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    private var tierFeatures: [String] {
        if product.id.contains("basic") {
            return ["10 audio processes/month", "Up to 1 minute clips", "No watermark"]
        } else if product.id.contains("pro") {
            return ["30 audio processes/month", "Up to 2.5 minute clips", "Priority processing"]
        } else if product.id.contains("unlimited") {
            return ["Unlimited audio processes", "Up to 5 minute clips", "VIP priority"]
        }
        return []
    }
    
    private var subscriptionPeriodText: String {
        guard let subscription = product.subscription else {
            return "per month"
        }
        
        let unit = subscription.subscriptionPeriod.unit
        let value = subscription.subscriptionPeriod.value
        
        switch unit {
        case .day:
            return value == 1 ? "per day" : "per \(value) days"
        case .week:
            return value == 1 ? "per week" : "per \(value) weeks"
        case .month:
            return value == 1 ? "per month" : "per \(value) months"
        case .year:
            return value == 1 ? "per year" : "per \(value) years"
        @unknown default:
            return "per period"
        }
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
                .foregroundColor(.primaryBlue)
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
