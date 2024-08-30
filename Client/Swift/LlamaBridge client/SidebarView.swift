import SwiftUI

struct SidebarView: View {
    @ObservedObject var conversationManager: ConversationManager
    @Binding var selectedSessionId: String
    
    var body: some View {
        VStack {
            Button(action: createNewSession) {
                HStack {
                    Image(systemName: "plus")
                    Text("New Session")
                }
            }
            .padding()
            
            List {
                ForEach(conversationManager.conversations.keys.sorted(), id: \.self) { sessionId in
                    HStack {
                        Text(sessionId)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedSessionId = sessionId
                    }
                }
            }
            .listStyle(SidebarListStyle())
        }
    }
    
    func createNewSession() {
        let newSessionId = UUID().uuidString
        conversationManager.conversations[newSessionId] = []
        selectedSessionId = newSessionId
        conversationManager.saveConversations()
    }
}
