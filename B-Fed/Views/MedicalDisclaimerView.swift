import SwiftUI

struct MedicalDisclaimerView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasAcceptedMedicalDisclaimer") private var hasAcceptedDisclaimer = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "stethoscope")
                    .font(.system(size: 56))
                    .foregroundColor(.accent)
                    .padding(.top, 32)
                
                Text("Important Notice")
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(.primary)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("B-Fed is for informational purposes only and does not constitute medical advice.")
                            .font(.body.weight(.medium))
                        
                        Text("Always consult your pediatrician or qualified healthcare provider for personalized feeding guidance. Every baby is different, and professional medical advice should take precedence over any information provided by this app.")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Text("If you have concerns about your baby's feeding, weight, or health, please contact your healthcare provider immediately.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                Button {
                    hasAcceptedDisclaimer = true
                    dismiss()
                } label: {
                    Text("I Understand")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.accent)
                        .cornerRadius(16)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
    }
}
