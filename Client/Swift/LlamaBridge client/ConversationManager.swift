import Foundation

struct ConversationEntry: Codable, Identifiable {
    let id = UUID()
    let prompt: String
    let response: String
}

class ConversationManager: ObservableObject {
    @Published var conversations: [String: [ConversationEntry]] = [:]
    private let filename = "conversations.json"
    
    init() {
        loadConversations()
    }
    
    func loadConversations() {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(filename) else { return }
        
        do {
            let data = try Data(contentsOf: url)
            conversations = try JSONDecoder().decode([String: [ConversationEntry]].self, from: data)
        } catch {
            print("Error loading conversations: \(error)")
        }
    }
    
    func saveConversations() {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(filename) else { return }
        
        do {
            let data = try JSONEncoder().encode(conversations)
            try data.write(to: url)
        } catch {
            print("Error saving conversations: \(error)")
        }
    }
    
    func formatConversation(conversation: [ConversationEntry]) -> String {
        return conversation.map { "User: \($0.prompt)\nAI: \($0.response)\n" }.joined()
    }
    
    func addToConversation(sessionId: String, prompt: String, response: String) {
        if conversations[sessionId] == nil {
            conversations[sessionId] = []
        }
        conversations[sessionId]?.append(ConversationEntry(prompt: prompt, response: response))
        saveConversations()
    }
}
