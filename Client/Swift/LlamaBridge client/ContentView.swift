import SwiftUI

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
                markdownText(for: message)
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
    
    func markdownText(for text: String) -> some View {
        Text(try! AttributedString(markdown: text, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
            .textSelection(.enabled)
            .environment(\.openURL, OpenURLAction { url in
                NSWorkspace.shared.open(url)
                return .handled
            })
    }
}
