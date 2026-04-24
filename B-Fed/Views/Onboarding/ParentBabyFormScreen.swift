import SwiftUI
import SwiftData

// MARK: - Screen 2: About You Form
struct ParentBabyFormScreen: View {
    @Binding var parentName: String
    @Binding var parentEmail: String
    @Binding var parentDOB: Date
    @Binding var country: String
    @Binding var babyName: String
    @Binding var babyDOB: Date
    @Binding var babyWeight: String
    @Binding var showingValidationErrors: Bool
    let onContinue: () -> Void
    let onBack: () -> Void
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case parentName, parentEmail
    }
    
    let countries = [
        "Australia", "Canada", "France", "Germany", "India",
        "Ireland", "Italy", "Japan", "Netherlands", "New Zealand",
        "Singapore", "Spain", "United Kingdom", "United States"
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "FAFAF8")
                    .ignoresSafeArea(.all)
                
                // Background blobs
                ZStack {
                    Ellipse()
                        .fill(Color.peachDust.opacity(0.40))
                        .frame(width: 180, height: 180)
                        .position(x: geometry.size.width, y: 0)
                    
                    Ellipse()
                        .fill(Color.lemonIcing.opacity(0.50))
                        .frame(width: 110, height: 110)
                        .position(x: geometry.size.width, y: 0)
                    
                    Ellipse()
                        .fill(Color.almostAquaLight.opacity(0.50))
                        .frame(width: 110, height: 110)
                        .position(x: 0, y: geometry.size.height)
                }
                .ignoresSafeArea(.all)
                
                // Content
                VStack(alignment: .leading, spacing: 0) {
                    // Header row
                    HStack {
                        Button(action: onBack) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .frame(width: 32, height: 32)
                                Text("‹")
                                    .font(AppFont.sans(18, weight: .medium))
                                    .foregroundColor(Color.inkPrimary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        // Progress indicator
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.inkPrimary)
                                .frame(width: 16, height: 6)
                            ForEach(0..<3) { _ in
                                Circle()
                                    .fill(Color.inkPrimary.opacity(0.20))
                                    .frame(width: 6, height: 6)
                            }
                        }
                    }
                    
                    // Title block
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About you")
                            .font(AppFont.serif(26))
                            .foregroundColor(Color.inkPrimary)
                        Text("Just a few details to get started")
                            .font(AppFont.sans(13, weight: .regular))
                            .foregroundColor(Color.inkSecondary)
                    }
                    .padding(.top, 32)
                    
                    // Form fields
                    VStack(alignment: .leading, spacing: 16) {
                        // Field 1: Your name
                        formField(
                            label: "Your name",
                            placeholder: "e.g. Sarah",
                            text: $parentName,
                            keyboard: .namePhonePad
                        )
                        .focused($focusedField, equals: .parentName)
                        
                        // Field 2: Email address
                        formField(
                            label: "Email address",
                            placeholder: "e.g. sarah@email.com",
                            text: $parentEmail,
                            keyboard: .emailAddress,
                            isRequired: true
                        )
                        .focused($focusedField, equals: .parentEmail)
                        
                        // Field 3: Country
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Country")
                                .font(AppFont.sans(12, weight: .semibold))
                                .foregroundColor(Color.inkPrimary)
                            
                            Menu {
                                ForEach(countries, id: \.self) { c in
                                    Button(c) {
                                        country = c
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(country.isEmpty ? "e.g. Australia" : country)
                                        .font(AppFont.sans(13, weight: .regular))
                                        .foregroundColor(country.isEmpty ? Color.orchidTint : Color.inkPrimary)
                                    Spacer()
                                    Text("⌄")
                                        .font(AppFont.sans(13, weight: .medium))
                                        .foregroundColor(Color.inkSecondary)
                                }
                                .padding(.horizontal, 16)
                                .frame(height: 48)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                                )
                            }
                        }
                    }
                    .padding(.top, 24)
                    
                    Spacer()
                    
                    // Button block
                    VStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.inkPrimary)
                                .frame(height: 54)
                            HStack {
                                Text("Continue")
                                    .font(AppFont.sans(15, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer()
                                Text("→")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18))
                                    .padding(.trailing, 22)
                            }
                            .padding(.horizontal, 24)
                        }
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            // Provide sensible defaults for fields no longer collected
                            if babyName.isEmpty { babyName = "Baby" }
                            if babyWeight.isEmpty { babyWeight = "3.5" }
                            onContinue()
                        }
                        
                        Text("You can update these anytime")
                            .font(AppFont.sans(11, weight: .regular))
                            .foregroundColor(Color(hex: "8A7E96"))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(.top, geometry.safeAreaInsets.top + 12)
                .padding(.bottom, geometry.safeAreaInsets.bottom + 24)
                .padding(.horizontal, 18)
            }
        }
    }
    
    private func formField(
        label: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        isRequired: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 2) {
                Text(label)
                    .font(AppFont.sans(12, weight: .semibold))
                    .foregroundColor(Color.inkPrimary)
                if isRequired {
                    Text("*")
                        .font(AppFont.sans(12, weight: .semibold))
                        .foregroundColor(Color.peachDustDark)
                }
            }
            
            TextField(placeholder, text: text)
                .font(AppFont.sans(13, weight: .regular))
                .foregroundColor(Color.inkPrimary)
                .keyboardType(keyboard)
                .autocapitalization(.words)
                .padding(.horizontal, 16)
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                )
        }
    }
}

#Preview {
    ParentBabyFormScreen(
        parentName: .constant(""),
        parentEmail: .constant(""),
        parentDOB: .constant(Date()),
        country: .constant(""),
        babyName: .constant(""),
        babyDOB: .constant(Date()),
        babyWeight: .constant(""),
        showingValidationErrors: .constant(false),
        onContinue: {},
        onBack: {}
    )
}
