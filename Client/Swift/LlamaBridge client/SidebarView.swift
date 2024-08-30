import SwiftUI

struct SidebarView: View {
    @ObservedObject var conversationManager: ConversationManager
    @Binding var selectedSessionId: String
    @State private var isRenaming = false
    @State private var newName = ""
    
    var body: some View {
        VStack {
            HStack {
                Button(action: createNewSession) {
                    HStack {
                        Image(systemName: "plus")
                        Text("New Chat")
                    }
                }
                Spacer()
                if !selectedSessionId.isEmpty {
                    Button(action: {
                        isRenaming = true
                        newName = conversationManager.getSessionName(for: selectedSessionId)
                    }) {
                        Image(systemName: "pencil")
                    }
                    .foregroundColor(.blue)
                    
                    Button(action: {
                        deleteChat(sessionId: selectedSessionId)
                    }) {
                        Image(systemName: "trash")
                    }
                    .foregroundColor(.red)
                }
            }
            .padding()
            
            List(selection: $selectedSessionId) {
                ForEach(conversationManager.conversations.keys.sorted(), id: \.self) { sessionId in
                    ChatRow(sessionId: sessionId, 
                            conversation: conversationManager.conversations[sessionId] ?? [],
                            sessionName: conversationManager.getSessionName(for: sessionId))
                        .tag(sessionId)
                }
            }
            .listStyle(SidebarListStyle())
        }
        .sheet(isPresented: $isRenaming) {
            RenameView(isPresented: $isRenaming, newName: $newName, onRename: {
                renameChat(sessionId: selectedSessionId, newName: newName)
            })
        }
    }
    
    func createNewSession() {
        let newSessionId = UUID().uuidString
        conversationManager.conversations[newSessionId] = []
        selectedSessionId = newSessionId
        conversationManager.saveConversations()
    }
    
    func deleteChat(sessionId: String) {
        conversationManager.conversations.removeValue(forKey: sessionId)
        if selectedSessionId == sessionId {
            selectedSessionId = conversationManager.conversations.keys.first ?? ""
        }
        conversationManager.saveConversations()
    }
    
    func renameChat(sessionId: String, newName: String) {
        conversationManager.renameSession(sessionId: sessionId, newName: newName)
    }
}

struct ChatRow: View {
    let sessionId: String
    let conversation: [ConversationEntry]
    let sessionName: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(sessionName)
                    .fontWeight(.medium)
                if let lastMessage = conversation.last {
                    Text(lastMessage.prompt)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .padding(.vertical, 4)
    }
}

struct RenameView: View {
    @Binding var isPresented: Bool
    @Binding var newName: String
    let onRename: () -> Void
    
    var body: some View {
        VStack {
            Text("Rename Chat")
                .font(.headline)
            TextField("New name", text: $newName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                Button("Rename") {
                    onRename()
                    isPresented = false
                }
            }
        }
        .padding()
        .frame(width: 300, height: 150)
    }
}
