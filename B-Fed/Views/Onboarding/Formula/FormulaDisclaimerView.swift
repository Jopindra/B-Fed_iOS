import SwiftUI

// MARK: - Formula Disclaimer
struct FormulaDisclaimerView: View {
    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: "info.circle.fill")
                .font(AppFont.sans(12))
                .foregroundStyle(Color.orchidTintDark)
                .padding(.top, AppSpacing.xs)
            
            Text(FormulaGuidanceService.standardDisclaimer)
                .font(AppFont.sans(11))
                .foregroundStyle(Color.inkSecondary.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.md)
        .background(Color.lemonIcingLight.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
    }
}

// MARK: - Specialist Warning
struct SpecialistWarningView: View {
    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(AppFont.sans(12))
                .foregroundStyle(Color.peachDustDark)
                .padding(.top, 2)
            
            Text(FormulaGuidanceService.specialistWarning)
                .font(AppFont.sans(11, weight: .medium))
                .foregroundStyle(Color.peachDustDark)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.md)
        .background(Color.peachDustLight.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
    }
}

// MARK: - Gentle Guide Card
struct GentleGuideCard: View {
    let title: String
    let value: String
    let subtitle: String
    let tint: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(AppFont.serif(24))
                .foregroundStyle(Color.inkPrimary)
                .monospacedDigit()
            
            Text(title)
                .font(AppFont.sans(12, weight: .semibold))
                .foregroundStyle(Color.inkSecondary)
            
            Text(subtitle)
                .font(AppFont.caption)
                .foregroundStyle(tint.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
        .background(Color.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(Color.black.opacity(AppMetrics.borderOpacity), lineWidth: AppMetrics.borderWidth)
        )
    }
}

// MARK: - Formula Info Row
struct FormulaInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppFont.body)
                .foregroundStyle(Color.inkSecondary)
            Spacer()
            Text(value)
                .font(AppFont.body)
                .foregroundStyle(Color.inkPrimary)
        }
        .padding(.vertical, AppSpacing.sm)
    }
}
