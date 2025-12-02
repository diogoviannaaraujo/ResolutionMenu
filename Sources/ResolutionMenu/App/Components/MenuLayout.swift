import SwiftUI

struct DetailHeaderView: View {
    let title: String
    let onBack: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
       
            Text(title)
                .font(.headline)
            
            Spacer()
        }
        .padding()
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct MenuHeaderView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            
            Text("ResolutionMenu")
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
        }
        .padding()
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct MenuFooterView: View {
    let onQuit: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: onQuit) {
                Image(systemName: "power")
                    .fontWeight(.semibold)
                    .contentShape(Rectangle())
            }
            .help("Quit")
            .keyboardShortcut("q")
            .buttonStyle(.plain)
            .padding()
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

