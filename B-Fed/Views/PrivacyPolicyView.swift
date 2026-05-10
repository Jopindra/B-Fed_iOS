import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        Text("Privacy Policy")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .foregroundColor(.primary)
                        
                        Text("Last updated: May 2026")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("B-Fed respects your privacy. This policy explains what data we collect and how we use it.")
                            .font(.body)
                        
                        Text("Data We Collect")
                            .font(.headline)
                        Text("We collect your baby's name, date of birth, weight, and feeding logs. We also collect your name and country to personalize the app experience. This data is stored only on your device and in your private iCloud account (if iCloud is enabled).")
                        
                        Text("How We Use Your Data")
                            .font(.headline)
                        Text("Your data is used solely to provide the app's core functionality: tracking feeds, showing statistics, and offering feeding guidance. We do not share your data with any third parties.")
                        
                        Text("Data Storage")
                            .font(.headline)
                        Text("All data is stored locally on your device using Apple's SwiftData framework. If you enable iCloud, your data is synced to your private iCloud account using CloudKit. No data is sent to our servers.")
                        
                        Text("Children's Privacy")
                            .font(.headline)
                        Text("This app is designed for parents to track their baby's feeding. We do not knowingly collect data directly from children.")
                        
                        Text("Data Deletion")
                            .font(.headline)
                        Text("You can delete all your data at any time from the Settings screen. This will remove all data from your device and iCloud.")
                        
                        Text("Contact Us")
                            .font(.headline)
                        Text("If you have any questions about this privacy policy, please contact us through the App Store.")
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
