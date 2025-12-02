import SwiftUI
import AppKit

struct SettingsView: View {
    @Bindable var viewModel: AppViewModel
    
    var body: some View {
        Form {
            Section {
                Toggle("Start on Boot", isOn: $viewModel.startOnBoot)
            }
            
            Section {
                HStack(alignment: .top, spacing: 12) {
                    Image(nsImage: NSApplication.shared.applicationIconImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64, height: 64)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Resolution Menu")
                            .font(.headline)
                        
                        Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("Because life is too short for the wrong aspect ratio. 🖥️✨")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .frame(width: 350)
        .onAppear {
            NSApp.setActivationPolicy(.regular)
            // Use a slight delay to ensure the window is ready to be activated
            DispatchQueue.main.async {
                NSApp.activate(ignoringOtherApps: true)
                // Find the settings window and bring it to front specifically if needed
            }
        }
        .onDisappear {
            NSApp.setActivationPolicy(.accessory)
        }
    }
}

