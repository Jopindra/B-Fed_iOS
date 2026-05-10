import SwiftUI

struct FormulaDetailView: View {
    let formula: Formula
    let volumeMl: Double
    
    @Environment(\.dismiss) private var dismiss
    
    private var steps: [String] {
        FormulaService.preparationSteps(volumeMl: volumeMl, formula: formula)
    }
    
    private var scoopGuide: [(ml: Int, scoops: Int)] {
        FormulaService.quickScoopGuide(formula: formula)
    }
    
    private var storage: (roomTemp: String, fridge: String, warnings: [String]) {
        FormulaService.storageGuidance(formula: formula)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Preparation Guide
                    preparationCard
                    
                    // Quick Scoop Reference
                    scoopReferenceCard
                    
                    // Storage Guide
                    storageCard
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color.backgroundBase)
            .navigationTitle(formula.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
    
    // MARK: - Preparation Card
    private var preparationCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How to make a bottle")
                .font(AppFont.lead)
                .foregroundStyle(Color.inkPrimary)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(index + 1)")
                            .font(AppFont.sans(12, weight: .bold))
                            .foregroundStyle(Color.backgroundCard)
                            .frame(width: 22, height: 22)
                            .background(
                                Circle()
                                    .fill(Color.inkPrimary)
                            )
                        
                        Text(step)
                            .font(AppFont.sans(13, weight: .regular))
                            .foregroundStyle(Color.inkPrimary)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(Color.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .stroke(Color.inkPrimary.opacity(AppMetrics.borderOpacity), lineWidth: 0.5)
                )
        )
    }
    
    // MARK: - Scoop Reference Card
    private var scoopReferenceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Scoop guide")
                .font(AppFont.sans(11, weight: .semibold))
                .foregroundStyle(Color.inkSecondary)
                .tracking(0.3)
            
            HStack(spacing: 0) {
                ForEach(scoopGuide, id: \.ml) { item in
                    VStack(spacing: 4) {
                        Text("\(item.ml)ml")
                            .font(AppFont.sans(11, weight: .medium))
                            .foregroundStyle(Color.inkPrimary)
                        Text("\(item.scoops)")
                            .font(AppFont.sans(13, weight: .semibold))
                            .foregroundStyle(Color.almostAquaDark)
                    }
                    .frame(maxWidth: .infinity)
                    
                    if item.ml != scoopGuide.last?.ml {
                        Rectangle()
                            .fill(Color.inkPrimary.opacity(AppMetrics.borderOpacity))
                            .frame(width: 0.5, height: 24)
                    }
                }
            }
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.almostAquaLight.opacity(0.4))
            )
        }
    }
    
    // MARK: - Storage Card
    private var storageCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Made-up bottle guidance")
                .font(AppFont.sans(11, weight: .semibold))
                .foregroundStyle(Color.inkSecondary)
                .tracking(0.3)
            
            VStack(alignment: .leading, spacing: 14) {
                // Room temperature
                HStack(spacing: 12) {
                    roomTempIndicator
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("At room temperature")
                            .font(AppFont.sans(11, weight: .semibold))
                            .foregroundStyle(Color.inkPrimary)
                        Text(storage.roomTemp)
                            .font(AppFont.sans(13, weight: .regular))
                            .foregroundStyle(Color.inkPrimary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                    .background(Color.inkPrimary.opacity(AppMetrics.borderOpacity))
                
                // Fridge
                HStack(spacing: 12) {
                    fridgeIndicator
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("In fridge (2–4°C)")
                            .font(AppFont.sans(11, weight: .semibold))
                            .foregroundStyle(Color.inkPrimary)
                        Text(storage.fridge)
                            .font(AppFont.sans(13, weight: .regular))
                            .foregroundStyle(Color.inkPrimary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                    .background(Color.inkPrimary.opacity(AppMetrics.borderOpacity))
                
                // Warnings
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(storage.warnings, id: \.self) { warning in
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(AppFont.sans(10))
                                .foregroundStyle(Color.peachDustDark)
                            
                            Text(warning)
                                .font(AppFont.sans(13, weight: .regular))
                                .foregroundStyle(Color.inkPrimary)
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .fill(Color.almostAquaLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                            .stroke(Color.almostAqua.opacity(0.3), lineWidth: 0.5)
                    )
            )
        }
    }
    
    // MARK: - Room Temp Indicator
    private var roomTempIndicator: some View {
        ZStack {
            Circle()
                .stroke(Color.peachDustDark.opacity(0.3), lineWidth: 3)
                .frame(width: 36, height: 36)
            
            Circle()
                .trim(from: 0, to: 0.33)
                .stroke(Color.peachDustDark, lineWidth: 3)
                .frame(width: 36, height: 36)
                .rotationEffect(.degrees(-90))
            
            Text("2h")
                .font(AppFont.label)
                .foregroundStyle(Color.peachDustDark)
        }
        .frame(width: 36, height: 36)
    }
    
    // MARK: - Fridge Indicator
    private var fridgeIndicator: some View {
        ZStack {
            Circle()
                .stroke(Color.almostAquaDark.opacity(0.3), lineWidth: 3)
                .frame(width: 36, height: 36)
            
            Circle()
                .trim(from: 0, to: 1.0)
                .stroke(Color.almostAquaDark, lineWidth: 3)
                .frame(width: 36, height: 36)
                .rotationEffect(.degrees(-90))
            
            Text("24h")
                .font(AppFont.label)
                .foregroundStyle(Color.almostAquaDark)
        }
        .frame(width: 36, height: 36)
    }
}

#Preview {
    FormulaDetailView(
        formula: FormulaService.allFormulas[0],
        volumeMl: 120
    )
}
