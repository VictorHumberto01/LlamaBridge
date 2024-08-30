import SwiftUI
import Highlightr

struct ContentView: View {
    @State private var serverIp: String = ""
    @State private var currentPrompt: String = ""
    @State private var showSettings: Bool = true
    @State private var selectedSessionId: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    @ObservedObject var conversationManager = ConversationManager()
    let networkManager = NetworkManager()
    
    var body: some View {
        NavigationView {
            SidebarView(conversationManager: conversationManager, selectedSessionId: $selectedSessionId)
                .frame(minWidth: 200)            
            if showSettings {
                settingsView
            } else if !selectedSessionId.isEmpty {
                chatView
                    .navigationTitle("Session: \(selectedSessionId)")
            } else {
                Text("Select a session from the sidebar or create a new one.")
                    .font(.headline)
            }
        }
        .onAppear {
            if conversationManager.conversations.isEmpty {
                // Create a default session if none exist
                let defaultSessionId = UUID().uuidString
                conversationManager.conversations[defaultSessionId] = []
                selectedSessionId = defaultSessionId
                conversationManager.saveConversations()
            }
        }
    }
    
    var settingsView: some View {
        VStack {
            TextField("Enter server IP", text: $serverIp)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom)
            
            Button("Start Chat") {
                if selectedSessionId.isEmpty, let firstSession = conversationManager.conversations.keys.sorted().first {
                    selectedSessionId = firstSession
                }
                showSettings = false
            }
            .padding()
        }
        .padding()
    }
    
    var chatView: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(conversationManager.conversations[selectedSessionId] ?? []) { entry in
                            ChatMessageView(message: entry.prompt, isUser: true)
                            ChatMessageView(message: entry.response, isUser: false)
                        }
                    }
                }
                .onChange(of: conversationManager.conversations[selectedSessionId]?.count) { _ in
                    if let lastId = conversationManager.conversations[selectedSessionId]?.last?.id {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
            .background(Color(NSColor.textBackgroundColor))
            
            VStack {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top)
                }
                
                HStack {
                    TextField("Enter your prompt", text: $currentPrompt, onCommit: sendMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                    }
                    .disabled(isLoading)
                    
                    if isLoading {
                        ProgressView()
                    }
                }
                .padding()
            }
            .background(Color(NSColor.controlBackgroundColor))
        }
    }
    
    func sendMessage() {
        guard !currentPrompt.isEmpty, !serverIp.isEmpty, !selectedSessionId.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        let formattedHistory = conversationManager.formatConversation(conversation: conversationManager.conversations[selectedSessionId] ?? [])
        let fullPrompt = "\(formattedHistory)User: \(currentPrompt)\nAI:"
        
        networkManager.sendRequest(sessionId: selectedSessionId, prompt: fullPrompt, serverIp: serverIp) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let responseText):
                    conversationManager.addToConversation(sessionId: selectedSessionId, prompt: currentPrompt, response: responseText)
                    currentPrompt = ""
                case .failure(let error):
                    errorMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct ChatMessageView: View {
    let message: String
    let isUser: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if isUser {
                Spacer()
            } else {
                Image(systemName: "brain")
                    .foregroundColor(.gray)
                    .frame(width: 30)
            }
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(isUser ? "You" : "AI")
                    .font(.headline)
                    .foregroundColor(isUser ? .blue : .gray)
                FormattedMessageView(message: message)
                    .frame(maxWidth: 600, alignment: isUser ? .trailing : .leading) // Limit width and align
            }
            if !isUser {
                Spacer()
            } else {
                Image(systemName: "person")
                    .foregroundColor(.blue)
                    .frame(width: 30)
            }
        }
        .padding()
        .background(isUser ? Color(NSColor.controlBackgroundColor) : Color(NSColor.textBackgroundColor))
    }
}

struct FormattedMessageView: View {
    let message: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) { // Increased spacing
            ForEach(splitMessage(), id: \.self) { part in
                if part.starts(with: "```") {
                    CodeBlockView(codeBlock: part)
                } else {
                    markdownText(for: part)
                }
            }
        }
    }
    
    private func splitMessage() -> [String] {
        let parts = message.components(separatedBy: "```")
        return parts.enumerated().map { index, part in
            if index % 2 == 1 {
                return "```\(part)```"
            } else {
                return part
            }
        }
    }
    
    func markdownText(for text: String) -> some View {
        Text(try! AttributedString(markdown: text, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
            .textSelection(.enabled)
            .environment(\.openURL, OpenURLAction { url in
                NSWorkspace.shared.open(url)
                return .handled
            })
    }
}

struct CodeBlockView: View {
    let codeBlock: String
    @State private var highlightedCode: NSAttributedString?
    
    var body: some View {
        VStack(alignment: .leading) {
            if let highlightedCode = highlightedCode {
                ScrollView(.horizontal, showsIndicators: false) {
                    AttributedText(attributedString: highlightedCode)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
            } else {
                Text(processedCode)
                    .font(.system(.body, design: .monospaced))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
        }
        .background(Color(NSColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0))) // 
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .padding(.vertical, 8)
        .onAppear(perform: highlightCode)
    }
    
    private var processedCode: String {
        let lines = codeBlock.split(separator: "\n")
        if lines.count > 1 && lines[0].contains(":") {
            // Remove the language identifier line
            return lines.dropFirst().joined(separator: "\n")
        }
        return codeBlock.trimmingCharacters(in: CharacterSet(charactersIn: "`"))
    }
    
    private func highlightCode() {
        let code = processedCode
        let attributedString = NSMutableAttributedString(string: code)
        
        // Define VSCode-like colors
        let defaultColor = NSColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0) // Light gray for default text
        let keywordColor = NSColor(red: 0.8, green: 0.47, blue: 0.2, alpha: 1.0) // Orange for keywords
        let stringColor = NSColor(red: 0.8, green: 0.8, blue: 0.0, alpha: 1.0) // Yellow for strings
        let commentColor = NSColor(red: 0.4, green: 0.8, blue: 0.4, alpha: 1.0) // Green for comments
        
        // Basic syntax highlighting
        let keywords = ["func", "let", "var", "if", "else", "for", "while", "struct", "class", "enum", "switch", "case", "return"]
        let keywordPattern = "\\b(" + keywords.joined(separator: "|") + ")\\b"
        let patterns: [(String, NSColor)] = [
            ("\".*?\"", stringColor), // Strings
            ("//.+", commentColor),   // Single-line comments
            ("/\\*[\\s\\S]*?\\*/", commentColor), // Multi-line comments
            (keywordPattern, keywordColor) // Keywords
        ]
        
        // Apply default color
        attributedString.addAttribute(.foregroundColor, value: defaultColor, range: NSRange(location: 0, length: code.count))
        
        // Apply syntax highlighting
        for (pattern, color) in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let matches = regex.matches(in: code, options: [], range: NSRange(location: 0, length: code.count))
                for match in matches {
                    attributedString.addAttribute(.foregroundColor, value: color, range: match.range)
                }
            } catch {
                print("Error creating regex: \(error)")
            }
        }
        
        // Set font
        attributedString.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular), range: NSRange(location: 0, length: code.count))
        
        highlightedCode = attributedString
    }
}

struct AttributedText: NSViewRepresentable {
    let attributedString: NSAttributedString

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField(labelWithAttributedString: attributedString)
        textField.isEditable = false
        textField.isSelectable = true
        textField.drawsBackground = false
        textField.isBordered = false
        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        nsView.attributedStringValue = attributedString
    }
}
